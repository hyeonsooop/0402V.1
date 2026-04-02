function cfg = update_penalties(cfg, metrics)
pwr_v = max(metrics.power_ratio - 1, 0);
dl_v = max(1 - metrics.qos_dl_ratio, 0);
ul_v = max(1 - metrics.qos_ul_ratio, 0);

cfg.lambda_penalty = min(cfg.lambda_penalty .* (1 + 0.05 * pwr_v), 50);
cfg.tau_d = min(cfg.tau_d .* (1 + 0.05 * dl_v), 50);
cfg.tau_u = min(cfg.tau_u .* (1 + 0.05 * ul_v), 50);
cfg.kappa = min(cfg.kappa * 1.005, 20);
end
