function ul = effective_ul_terms(cfg, net, assoc, ris_assign, state, txrx)
K = cfg.K; Nc = cfg.Nc;
phi = reshape(state.theta, cfg.N0, cfg.Ns, cfg.R);
passive_gain = max(1, cfg.ris_surface_gain);

ul.desired = zeros(K,Nc);
ul.intra = zeros(K,Nc);
ul.inter = zeros(K,Nc);
ul.rsi = zeros(K,Nc);

for k = 1:K
    ordered_users = assoc.order(k,:);
    for i = 1:Nc
        u = ordered_users(i);
        coop_bs = txrx.ul_receivers.user_coop_bs{u};
        if isempty(coop_bs)
            coop_bs = find(assoc.C(u,:));
        end
        if isempty(coop_bs)
            continue;
        end

        v = txrx.ul_receivers.user_combiner{u};
        if isempty(v)
            v = ones(numel(coop_bs),1) / sqrt(numel(coop_bs));
        end

        users_same = txrx.ul_receivers.users_same{u};
        if isempty(users_same)
            users_same = find(any(assoc.C(:,coop_bs),2)).';
        end

        target_stack = local_stack_channel(u, coop_bs, assoc, ris_assign, phi, passive_gain, net);
        ul.desired(k,i) = abs(v' * target_stack).^2 * cfg.ue_tx_W;

        for idx = 1:numel(users_same)
            up = users_same(idx);
            if up == u
                continue;
            end
            up_stack = local_stack_channel(up, coop_bs, assoc, ris_assign, phi, passive_gain, net);
            pwr = abs(v' * up_stack).^2 * cfg.ue_tx_W;
            [kp, ip] = metrics.find_assignment_index(assoc, up);
            if kp == k && ip < i
                ul.intra(k,i) = ul.intra(k,i) + pwr;
            else
                ul.inter(k,i) = ul.inter(k,i) + pwr;
            end
        end

        % Residual self-interference only from the serving BSs involved in the combiner.
        ul.rsi(k,i) = 10^(cfg.rho_rsi_dB/10) * sum(sum(state.p(coop_bs,:),2));
    end
end
end

function gstack = local_stack_channel(u, coop_bs, assoc, ris_assign, phi, passive_gain, net)
[k_idx,i_idx] = metrics.find_assignment_index(assoc, u);
gstack = zeros(numel(coop_bs),1);
for bi = 1:numel(coop_bs)
    b = coop_bs(bi);
    geff = net.ch.ue_bs{u,b};
    for r = 1:size(phi,3)
        for ns = 1:size(phi,2)
            if ris_assign.U(r,ns,k_idx,i_idx)
                geff = geff + passive_gain * (net.ch.ris_bs{r,b} * diag(phi(:,ns,r)) * net.ch.ue_ris{u,r});
            end
        end
    end
    gstack(bi) = geff;
end
end
