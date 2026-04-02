function H = sample_sparse_mimo(cfg, Nt, Nr)
Np = cfg.Np;
H = zeros(Nr, Nt);
for l = 1:Np
    beta = (randn + 1j*randn) / sqrt(2*Np);
    at = utils.steering_upa(Nt, rand*2*pi, rand*pi/2, cfg.lambda, cfg.D);
    ar = utils.steering_upa(Nr, rand*2*pi, rand*pi/2, cfg.lambda, cfg.D);
    H = H + beta * (ar * at');
end
H = sqrt(Nt*Nr/max(Np,1)) * H;
