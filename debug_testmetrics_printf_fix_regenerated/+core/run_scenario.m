function out = run_scenario(cfg)
rng(cfg.seed + cfg.R + cfg.Ns + cfg.N0);

net = geometry.build_layout(cfg);
[assoc, ris_assign] = association.run_association(cfg, net);
state = core.initialize_state(cfg, net, assoc, ris_assign);
state.assoc = assoc;
state.ris_assign = ris_assign;
state.txrx = transceiver.compute_transceivers(cfg, net, assoc, ris_assign, state);
state.precoders = state.txrx.precoders;
state.ul_receivers = state.txrx.ul_receivers;

hist = core.init_history(cfg.max_iter);
prev_cost = inf;
prev_dir = [];
prev_grad = [];

for it = 1:cfg.max_iter
    state.txrx = transceiver.compute_transceivers(cfg, net, assoc, ris_assign, state);
    state.precoders = state.txrx.precoders;
    state.ul_receivers = state.txrx.ul_receivers;
    metrics_now = metrics.evaluate_state_modular(cfg, net, assoc, ris_assign, state, state.txrx);
    [cost, grad] = optimizer.objective_and_gradient(cfg, net, state, ris_assign, metrics_now);

    if it == 1
        dir.theta = -grad.theta;
        dir.p = -grad.p;
    else
        beta_prp = core.prp_beta(grad, prev_grad, prev_dir);
        tr_prev = core.transport_direction(state, prev_state, prev_dir);
        dir.theta = -grad.theta + beta_prp * tr_prev.theta;
        dir.p = -grad.p + beta_prp * tr_prev.p;
    end

    [state_new, ls_info] = core.armijo_update(cfg, net, assoc, ris_assign, state, dir, cost, grad);
    metrics_new = metrics.evaluate_state_modular(cfg, net, assoc, ris_assign, state_new, state_new.txrx);
    [cost_new, grad_new] = optimizer.objective_and_gradient(cfg, net, state_new, ris_assign, metrics_new);

    hist.iter(it) = it;
    hist.EE(it) = metrics_new.EE;
    hist.Rsum(it) = metrics_new.Rsum;
    hist.Ptot(it) = metrics_new.Ptot;
    hist.cost(it) = cost_new;
    hist.grad_theta_norm(it) = norm(grad_new.theta(:));
    hist.grad_p_norm(it) = norm(grad_new.p(:));
    hist.penalty_power(it) = metrics_new.penalty_power;
    hist.penalty_qos_dl(it) = metrics_new.penalty_qos_dl;
    hist.penalty_qos_ul(it) = metrics_new.penalty_qos_ul;
    hist.mean_sinr_dl_db(it) = utils.safe_db(mean(metrics_new.sinr_dl(:)));
    hist.mean_sinr_ul_db(it) = utils.safe_db(mean(metrics_new.sinr_ul(:)));
    hist.mean_direct(it) = metrics_new.mean_direct;
    hist.mean_reflect(it) = metrics_new.mean_reflect;
    hist.reflect_direct_ratio(it) = metrics_new.mean_reflect / max(metrics_new.mean_direct,1e-15);
    hist.dl_desired_to_interference(it) = metrics_new.breakdown.dl.desired_to_interference;
    hist.dl_desired_to_noise(it) = metrics_new.breakdown.dl.desired_to_noise;
    hist.ul_desired_to_interference(it) = metrics_new.breakdown.ul.desired_to_interference;
    hist.ul_desired_to_noise(it) = metrics_new.breakdown.ul.desired_to_noise;
    hist.active_bs_per_user(it) = mean(sum(assoc.C,2));
    tmp_load = sum(sum(ris_assign.U,4),3);
    hist.avg_ris_load(it) = mean(tmp_load(:));
    hist.step_mu(it) = ls_info.mu;
    hist.accepted_ls_trials(it) = ls_info.trials;
    hist.phase_change_norm(it) = norm(state_new.theta(:) - state.theta(:));
    hist.power_change_norm(it) = norm(state_new.p(:) - state.p(:));

    if mod(it, cfg.log_every) == 0 || it == 1
        fprintf(['it=%3d | EE=%.4e | Rsum=%.4e | Ptot=%.4e | cost=%.4e | ' ...
                 'gth=%.3e | gp=%.3e | SINRdl=%.2f dB | SINRul=%.2f dB | ' ...
                 'pen=[%.2e %.2e %.2e]\n'], ...
                 it, metrics_new.EE, metrics_new.Rsum, metrics_new.Ptot, cost_new, ...
                 hist.grad_theta_norm(it), hist.grad_p_norm(it), ...
                 hist.mean_sinr_dl_db(it), hist.mean_sinr_ul_db(it), ...
                 hist.penalty_power(it), hist.penalty_qos_dl(it), hist.penalty_qos_ul(it));
        fprintf('          dl[D/I=%.3e D/N=%.3e] | ul[D/I=%.3e D/N=%.3e]\n', ...
                 hist.dl_desired_to_interference(it), hist.dl_desired_to_noise(it), ...
                 hist.ul_desired_to_interference(it), hist.ul_desired_to_noise(it));
    end

    relchg = abs(cost_new - prev_cost) / max(abs(cost_new), 1e-12);
    prev_cost = cost_new;
    prev_grad = grad_new;
    prev_dir = dir;
    prev_state = state;
    state = state_new;

    cfg = core.update_penalties(cfg, metrics_new);

    if it > 5 && relchg <= cfg.delta
        hist = core.trim_history(hist, it);
        fprintf('Converged at iteration %d (relative cost change %.3e).\n', it, relchg);
        break;
    end

    if it == cfg.max_iter
        hist = core.trim_history(hist, it);
    end
end

if ~exist('logs','dir'), mkdir('logs'); end
logbase = fullfile('logs', cfg.run_name);
out.cfg = cfg;
out.net = net;
out.assoc = assoc;
out.ris_assign = ris_assign;
out.state = state;
out.history = hist;
save([logbase '.mat'], 'out', '-v7.3');
utils.history_to_csv([logbase '.csv'], hist);
end
