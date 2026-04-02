function dl = effective_dl_terms(cfg, net, assoc, ris_assign, state, txrx)
K = cfg.K; Nc = cfg.Nc;
phi = reshape(state.theta, cfg.N0, cfg.Ns, cfg.R);
passive_gain = max(1, cfg.ris_surface_gain);

dl.desired = zeros(K,Nc);
dl.intra = zeros(K,Nc);
dl.inter = zeros(K,Nc);
dl.cci = zeros(K,Nc);
dl.sum_direct = 0;
dl.sum_reflect = 0;
dl.nlinks = 0;

for k = 1:K
    ordered_users = assoc.order(k,:);
    for i = 1:Nc
        u = ordered_users(i);
        coop_bs = find(assoc.C(u,:));
        for b = coop_bs
            if ~txrx.precoders.cluster_supported(b,k)
                continue;
            end
            A = txrx.precoders.A{b};
            D = txrx.precoders.d{b};
            gbeam = txrx.precoders.cluster_to_beam(b,k);
            if gbeam <= 0 || gbeam > size(D,2)
                continue;
            end
            wbk = A * D(:,gbeam);

            hdir = net.ch.bs_ue{b,u};
            href = zeros(size(hdir));
            for r = 1:cfg.R
                for ns = 1:cfg.Ns
                    if ris_assign.U(r,ns,k,i)
                        href = href + passive_gain * (net.ch.ris_ue{r,u} * diag(phi(:,ns,r)) * net.ch.bs_ris{b,r});
                    end
                end
            end
            h_eff = hdir + href;
            p_sig = sum(abs(h_eff * wbk).^2, 'all');
            dl.desired(k,i) = dl.desired(k,i) + p_sig * state.user_power_split(k,i) * state.p(b,k);
            dl.sum_direct = dl.sum_direct + sum(abs(hdir * wbk).^2, 'all');
            dl.sum_reflect = dl.sum_reflect + sum(abs(href * wbk).^2, 'all');
            dl.nlinks = dl.nlinks + 1;

            for ip = 1:i-1
                dl.intra(k,i) = dl.intra(k,i) + p_sig * state.user_power_split(k,ip) * state.p(b,k);
            end
            for kp = 1:K
                if kp == k, continue; end
                if ~txrx.precoders.cluster_supported(b,kp)
                    continue;
                end
                gbeam_p = txrx.precoders.cluster_to_beam(b,kp);
                if gbeam_p <= 0 || gbeam_p > size(D,2)
                    continue;
                end
                wbkp = A * D(:,gbeam_p);
                dl.inter(k,i) = dl.inter(k,i) + sum(abs(h_eff * wbkp).^2, 'all') * sum(state.user_power_split(kp,:)) * state.p(b,kp);
            end
        end
        for up = 1:cfg.U
            if up == u, continue; end
            dl.cci(k,i) = dl.cci(k,i) + cfg.ue_tx_W * abs(net.ch.ue_ue{up,u})^2;
        end
    end
end
end
