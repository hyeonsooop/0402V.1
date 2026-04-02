function gt = compute_theta_gradient(cfg, net, state, ris_assign)
gt = zeros(size(state.theta));
phi = reshape(state.theta, cfg.N0, cfg.Ns, cfg.R);
passive_gain = max(1, cfg.ris_surface_gain);
for r = 1:cfg.R
    for ns = 1:cfg.Ns
        [pairs_k,pairs_i] = find(squeeze(ris_assign.U(r,ns,:,:)));
        if isempty(pairs_k), continue; end
        acc = zeros(cfg.N0,1);
        for idx = 1:numel(pairs_k)
            kk = pairs_k(idx); ii = pairs_i(idx);
            u = state.assoc.order(kk,ii);
            bslist = find(state.assoc.C(u,:));
            for bb = 1:numel(bslist)
                b = bslist(bb);
                br = net.ch.bs_ris{b,r};
                ru = net.ch.ris_ue{r,u};
                gbeam = min(kk, size(state.txrx.precoders.d{b},2));
                wbk = state.txrx.precoders.A{b} * state.txrx.precoders.d{b}(:,gbeam);
                acc = acc + passive_gain * (conj(ru(:)) .* (br * wbk) * state.p(b,kk));
            end
        end
        idxs = sub2ind([cfg.N0,cfg.Ns,cfg.R], (1:cfg.N0)', ns*ones(cfg.N0,1), r*ones(cfg.N0,1));
        gt(idxs) = -(1j) * conj(acc) .* phi(:,ns,r);
    end
end
ng = norm(gt);
if ng > cfg.gth_clip
    gt = cfg.gth_clip * gt / ng;
end
end
