function gp = compute_power_gradient(cfg, net, metrics, state)
Pmax_mat = repmat(net.Pmax_W(:),1,cfg.K);
load_ratio = state.p ./ max(Pmax_mat,1e-12);
qos_gap = 0.5 * (mean(max(1 - metrics.qos_dl_ratio, 0),'all') + mean(max(1 - metrics.qos_ul_ratio, 0),'all'));
target_load = min(0.20 + 0.55*qos_gap, 0.75);
rate_drive = 0.20 * (target_load - load_ratio);
power_push = 1.25 * max(load_ratio - 1, 0) + 0.08*load_ratio;
gp = power_push - rate_drive;
end
