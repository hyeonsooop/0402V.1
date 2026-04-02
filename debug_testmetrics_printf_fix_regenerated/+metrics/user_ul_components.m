function [gdir, gref] = user_ul_components(cfg, net, ris_assign, assoc, phi, u, b)
% Backward-compatible helper used by older code paths.
gdir = net.ch.ue_bs{u,b};
gref = zeros(size(gdir));
passive_gain = max(1, cfg.ris_surface_gain);
[k_idx, i_idx] = metrics.find_assignment_index(assoc, u);
for r = 1:cfg.R
    for ns = 1:cfg.Ns
        if ris_assign.U(r,ns,k_idx,i_idx)
            gref = gref + passive_gain * (net.ch.ris_bs{r,b} * diag(phi(:,ns,r)) * net.ch.ue_ris{u,r});
        end
    end
end
end
