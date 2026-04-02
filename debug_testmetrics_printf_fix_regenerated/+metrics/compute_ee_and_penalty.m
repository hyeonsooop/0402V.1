function m = compute_ee_and_penalty(cfg, net, dl_rate, ul_rate, power)
Rsum = sum(dl_rate(:)) + sum(ul_rate(:));
EE = Rsum / max(power.total,1e-12);
power_violation = max(power.per_bs_tx - net.Pmax_W, 0) ./ max(net.Pmax_W,1e-12);
qos_dl_violation = max(cfg.Rd_Q - dl_rate, 0) ./ max(cfg.Rd_Q,1e-12);
qos_ul_violation = max(cfg.Ru_Q - ul_rate, 0) ./ max(cfg.Ru_Q,1e-12);
penalty_power = sum(cfg.lambda_penalty(:) .* utils.softplus_stable(cfg.kappa * power_violation(:)));
penalty_qos_dl = sum(cfg.tau_d(:) .* utils.softplus_stable(cfg.kappa * qos_dl_violation(:)));
penalty_qos_ul = sum(cfg.tau_u(:) .* utils.softplus_stable(cfg.kappa * qos_ul_violation(:)));

m.Rsum = Rsum;
m.Ptot = power.total;
m.EE = EE;
m.PTP_j = power.per_bs_tx;
m.power_ratio = power.per_bs_tx ./ max(net.Pmax_W,1e-12);
m.qos_dl_ratio = dl_rate ./ max(cfg.Rd_Q,1e-12);
m.qos_ul_ratio = ul_rate ./ max(cfg.Ru_Q,1e-12);
m.penalty_power = penalty_power;
m.penalty_qos_dl = penalty_qos_dl;
m.penalty_qos_ul = penalty_qos_ul;
m.penalty_components = [penalty_power, penalty_qos_dl, penalty_qos_ul];
end
