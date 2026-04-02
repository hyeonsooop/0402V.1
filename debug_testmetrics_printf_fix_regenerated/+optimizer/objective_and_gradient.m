function [cost, grad] = objective_and_gradient(cfg, net, state, ris_assign, metrics)
obj = optimizer.compute_objective_terms(cfg, metrics);
gp = optimizer.compute_power_gradient(cfg, net, metrics, state);
gtheta = optimizer.compute_theta_gradient(cfg, net, state, ris_assign);
grad = optimizer.merge_gradients(gtheta, gp);
cost = obj.total;
end
