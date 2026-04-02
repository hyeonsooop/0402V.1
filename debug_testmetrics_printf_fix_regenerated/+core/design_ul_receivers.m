function ul = design_ul_receivers(cfg, net, assoc, ris_assign, theta)
% Cooperative UL combiner across the UE's coordinated BSs.
% Uses a stacked MMSE-like combiner over only the users that share at least
% one serving BS with the target UE. This avoids over-counting far-away
% users that never enter the same CPU-combined observation.
phi = reshape(theta, cfg.N0, cfg.Ns, cfg.R);
passive_gain = max(1, cfg.ris_surface_gain);
ul.V = cell(cfg.B,1);
ul.user_combiner = cell(cfg.U,1);
ul.user_coop_bs = cell(cfg.U,1);
ul.users_same = cell(cfg.U,1);
for b = 1:cfg.B
    ul.V{b} = containers.Map('KeyType','double','ValueType','any');
end

for u = 1:cfg.U
    coop_bs = find(assoc.C(u,:));
    ul.user_coop_bs{u} = coop_bs(:).';
    if isempty(coop_bs), continue; end

    users_same = find(any(assoc.C(:,coop_bs),2)).';
    ul.users_same{u} = users_same;
    H = zeros(numel(coop_bs), numel(users_same));
    target_col = 1;

    for col = 1:numel(users_same)
        uu = users_same(col);
        if uu == u, target_col = col; end
        [k_idx,i_idx] = metrics.find_assignment_index(assoc, uu);
        for bi = 1:numel(coop_bs)
            b = coop_bs(bi);
            geff = net.ch.ue_bs{uu,b};
            for r = 1:cfg.R
                for ns = 1:cfg.Ns
                    if ris_assign.U(r,ns,k_idx,i_idx)
                        geff = geff + passive_gain * (net.ch.ris_bs{r,b} * diag(phi(:,ns,r)) * net.ch.ue_ris{uu,r});
                    end
                end
            end
            H(bi,col) = geff;
        end
    end

    hu = H(:,target_col);
    reg = (cfg.noise_power_W + 10^(cfg.rho_rsi_dB/10)) * eye(size(H,1));
    v = (H*H' + reg) \ hu;
    nv = norm(v);
    if nv > 0, v = v / nv; end

    ul.user_combiner{u} = v;
    for bi = 1:numel(coop_bs)
        b = coop_bs(bi);
        ul.V{b}(u) = conj(v(bi));
    end
end
end
