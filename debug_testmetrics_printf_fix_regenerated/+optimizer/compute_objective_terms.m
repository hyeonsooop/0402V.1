function obj = compute_objective_terms(cfg, metrics)
obj.ee_term = -(metrics.Rsum / max(metrics.Ptot,1e-12)) / max(cfg.ee_scale,1e-12);
obj.penalty_term = metrics.penalty_power + metrics.penalty_qos_dl + metrics.penalty_qos_ul;
obj.total = obj.ee_term + obj.penalty_term;
end
