function [state_new, info] = armijo_update(cfg, net, assoc, ris_assign, state, dir, cost, grad)
mu = 1.0;
info.trials = 0;
state_new = state;
inner = real([grad.theta(:); grad.p(:)]' * [dir.theta(:); dir.p(:)]);
if ~isfinite(inner) || inner >= 0
    dir.theta = -grad.theta;
    dir.p = -grad.p;
    inner = real([grad.theta(:); grad.p(:)]' * [dir.theta(:); dir.p(:)]);
end

for t = 1:cfg.armijo_max_trials
    cand = state;
    cand.theta = core.retract_theta(state.theta + mu * cfg.step_theta * dir.theta);
    cand.p = max(state.p + mu * cfg.step_p * dir.p, 0);
    for b = 1:cfg.B
        s = sum(cand.p(b,:));
        if s > net.Pmax_W(b)
            cand.p(b,:) = cand.p(b,:) * (net.Pmax_W(b) / max(s,1e-12));
        end
    end
    cand.txrx = transceiver.compute_transceivers(cfg, net, assoc, ris_assign, cand);
    cand = core.apply_beam_support_mask(cand, cand.txrx);
    cand.precoders = cand.txrx.precoders;
    cand.ul_receivers = cand.txrx.ul_receivers;

    metrics_c = metrics.evaluate_state_modular(cfg, net, assoc, ris_assign, cand, cand.txrx);
    [cost_c, ~] = optimizer.objective_and_gradient(cfg, net, cand, ris_assign, metrics_c);
    rhs = cost + cfg.armijo_c1 * mu * inner;
    if isfinite(cost_c) && cost_c <= rhs
        state_new = cand;
        info.trials = t;
        break;
    end
    mu = mu * cfg.armijo_backtrack;
    info.trials = t;
end
info.mu = mu;
end
