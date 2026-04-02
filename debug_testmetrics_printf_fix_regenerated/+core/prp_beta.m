function beta = prp_beta(grad, prev_grad, prev_dir)
if isempty(prev_grad) || isempty(prev_dir)
    beta = 0;
    return;
end
g = [grad.theta(:); grad.p(:)];
gp = [prev_grad.theta(:); prev_grad.p(:)];
diff = g - gp;
beta = max(real((g' * diff) / max(gp' * gp, 1e-12)), 0);
end
