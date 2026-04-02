function prec = design_hybrid_precoders(cfg, net, assoc, ris_assign, theta)
% Two-stage hybrid precoder inspired by reference [21].
% Implementation note: a BS with G RF chains can serve at most G clusters.
% Earlier code incorrectly mapped all k>G clusters to the last beam via
% min(k,G), which is a genuine implementation bug and creates excessive IUI.
phi = reshape(theta, cfg.N0, cfg.Ns, cfg.R);
prec.A = cell(cfg.B,1);
prec.d = cell(cfg.B,1);
prec.rep_users = zeros(cfg.B, cfg.K);
prec.cluster_to_beam = zeros(cfg.B, cfg.K);
prec.cluster_supported = false(cfg.B, cfg.K);
passive_gain = max(1, cfg.ris_surface_gain);

for b = 1:cfg.B
    Nt = net.bs_params.Nt(b);
    NRF = net.bs_params.NRF(b);
    G = min(NRF, cfg.K);

    % candidate clusters for BS b: at least one cluster member is coordinated with b
    cand_clusters = [];
    cand_score = [];
    for k = 1:cfg.K
        users_k = assoc.order(k,:);
        if any(arrayfun(@(u) assoc.C(u,b), users_k))
            score_k = 0;
            for i = 1:numel(users_k)
                u = users_k(i);
                heff = net.ch.bs_ue{b,u};
                [k_idx, i_idx] = metrics.find_assignment_index(assoc, u);
                for r = 1:cfg.R
                    for ns = 1:cfg.Ns
                        if ris_assign.U(r,ns,k_idx,i_idx)
                            heff = heff + passive_gain * (net.ch.ris_ue{r,u} * diag(phi(:,ns,r)) * net.ch.bs_ris{b,r});
                        end
                    end
                end
                score_k = max(score_k, norm(heff)^2);
            end
            cand_clusters(end+1) = k; %#ok<AGROW>
            cand_score(end+1) = score_k; %#ok<AGROW>
        end
    end
    if isempty(cand_clusters)
        prec.A{b} = zeros(Nt, G);
        prec.d{b} = zeros(G, G);
        continue;
    end
    [~,ord] = sort(cand_score, 'descend');
    served_clusters = cand_clusters(ord(1:min(G,numel(ord))));
    served_clusters = served_clusters(:).';
    prec.cluster_supported(b, served_clusters) = true;
    for g = 1:numel(served_clusters)
        prec.cluster_to_beam(b, served_clusters(g)) = g;
    end

    reps = zeros(1, numel(served_clusters));
    for gg = 1:numel(served_clusters)
        k = served_clusters(gg);
        users = assoc.order(k,:);
        best_u = users(1); best_gain = -inf;
        for i = 1:numel(users)
            u = users(i);
            heff = net.ch.bs_ue{b,u};
            [k_idx, i_idx] = metrics.find_assignment_index(assoc, u);
            for r = 1:cfg.R
                for ns = 1:cfg.Ns
                    if ris_assign.U(r,ns,k_idx,i_idx)
                        heff = heff + passive_gain * (net.ch.ris_ue{r,u} * diag(phi(:,ns,r)) * net.ch.bs_ris{b,r});
                    end
                end
            end
            gain = norm(heff)^2;
            if gain > best_gain
                best_gain = gain; best_u = u;
            end
        end
        reps(gg) = best_u;
        prec.rep_users(b,k) = best_u;
    end

    A = zeros(Nt,G);
    for gg = 1:numel(served_clusters)
        u = reps(gg);
        h = net.ch.bs_ue{b,u};
        href = zeros(size(h));
        [k_idx, i_idx] = metrics.find_assignment_index(assoc, u);
        for r = 1:cfg.R
            for ns = 1:cfg.Ns
                if ris_assign.U(r,ns,k_idx,i_idx)
                    href = href + passive_gain * (net.ch.ris_ue{r,u} * diag(phi(:,ns,r)) * net.ch.bs_ris{b,r});
                end
            end
        end
        h = (h + href).';
        phs = angle(h);
        if cfg.quant_bits > 0
            L = 2^cfg.quant_bits;
            grid = (0:L-1) * 2*pi/L;
            idx = 1 + mod(round(phs/(2*pi/L)), L);
            phs = grid(idx);
        end
        A(:,gg) = exp(1j*phs) / sqrt(Nt);
    end
    prec.A{b} = A;

    Hbar = zeros(numel(served_clusters), numel(served_clusters));
    for gg = 1:numel(served_clusters)
        u = reps(gg);
        h = net.ch.bs_ue{b,u};
        href = zeros(size(h));
        [k_idx, i_idx] = metrics.find_assignment_index(assoc, u);
        for r = 1:cfg.R
            for ns = 1:cfg.Ns
                if ris_assign.U(r,ns,k_idx,i_idx)
                    href = href + passive_gain * (net.ch.ris_ue{r,u} * diag(phi(:,ns,r)) * net.ch.bs_ris{b,r});
                end
            end
        end
        Hbar(gg,1:numel(served_clusters)) = (h + href) * A(:,1:numel(served_clusters));
    end
    Gram = Hbar*Hbar' + 1e-4*eye(size(Hbar,1));
    Dsmall = Hbar' / Gram;
    D = zeros(G,G);
    D(1:size(Dsmall,1),1:size(Dsmall,2)) = Dsmall;

    % total BS precoder normalization to avoid artificially large IUI
    total_norm = 0;
    for gg = 1:numel(served_clusters)
        total_norm = total_norm + norm(A * D(:,gg))^2;
    end
    if total_norm > 0
        D = D / sqrt(total_norm);
    end
    prec.d{b} = D;
end
end
