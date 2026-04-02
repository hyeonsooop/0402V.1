function [cost, grad] = compute_cost_and_gradient(cfg, net, metrics_in, state, ris_assign)
% Backward-compatible wrapper to the modular optimizer stack.
[cost, grad] = optimizer.objective_and_gradient(cfg, net, state, ris_assign, metrics_in);
end
