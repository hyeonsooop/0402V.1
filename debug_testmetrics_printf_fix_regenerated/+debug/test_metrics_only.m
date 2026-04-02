function report = test_metrics_only(cfg)
if nargin < 1 || isempty(cfg)
    cfg = core.default_config();
end
if ~isfield(cfg, 'num_ris'), cfg.num_ris = cfg.R; end
if ~isfield(cfg, 'num_ssf'), cfg.num_ssf = cfg.Ns; end
if ~isfield(cfg, 'scenario_name'), cfg.scenario_name = 'debug_default'; end

net = geometry.build_layout(cfg);
[assoc, ris_assign] = association.run_association(cfg, net);
state = core.initialize_state(cfg, net, assoc, ris_assign);
state.txrx = transceiver.compute_transceivers(cfg, net, assoc, ris_assign, state);
mod_metrics = metrics.evaluate_state_modular(cfg, net, assoc, ris_assign, state, state.txrx);

report = struct();
report.EE = mod_metrics.EE;
report.Rsum = mod_metrics.Rsum;
report.Ptot = mod_metrics.Ptot;
report.mean_direct = mod_metrics.mean_direct;
report.mean_reflect = mod_metrics.mean_reflect;
report.reflect_direct_ratio = mod_metrics.mean_reflect / max(mod_metrics.mean_direct, eps);
report.mean_sinr_dl_db = utils.safe_db(mean(mod_metrics.sinr_dl(:)));
report.mean_sinr_ul_db = utils.safe_db(mean(mod_metrics.sinr_ul(:)));
if isfield(mod_metrics, 'penalty_components')
    report.penalty = mod_metrics.penalty_components;
else
    report.penalty = [mod_metrics.penalty_power, mod_metrics.penalty_qos_dl, mod_metrics.penalty_qos_ul];
end
report.dl_desired_to_interference = mod_metrics.breakdown.dl.desired_to_interference;
report.dl_desired_to_noise = mod_metrics.breakdown.dl.desired_to_noise;
report.ul_desired_to_interference = mod_metrics.breakdown.ul.desired_to_interference;
report.ul_desired_to_noise = mod_metrics.breakdown.ul.desired_to_noise;

fprintf('=== test_metrics_only ===\n');
fprintf('scenario   : %s\n', cfg.scenario_name);
fprintf('EE         : %.4e\n', report.EE);
fprintf('Rsum       : %.4e\n', report.Rsum);
fprintf('Ptot       : %.4e\n', report.Ptot);
fprintf('SINR DL    : %.2f dB\n', report.mean_sinr_dl_db);
fprintf('SINR UL    : %.2f dB\n', report.mean_sinr_ul_db);
fprintf('Direct     : %.4e\n', report.mean_direct);
fprintf('Reflect    : %.4e\n', report.mean_reflect);
fprintf('Refl/Dir   : %.4e\n', report.reflect_direct_ratio);
fprintf('DL D/I     : %.4e | DL D/N : %.4e\n', report.dl_desired_to_interference, report.dl_desired_to_noise);
fprintf('UL D/I     : %.4e | UL D/N : %.4e\n', report.ul_desired_to_interference, report.ul_desired_to_noise);
end
