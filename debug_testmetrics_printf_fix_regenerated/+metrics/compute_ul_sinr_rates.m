function out = compute_ul_sinr_rates(cfg, ul)
out.noise = cfg.noise_power_W * ones(size(ul.desired));
out.den = ul.intra + ul.inter + ul.rsi + out.noise;
out.sinr = ul.desired ./ max(out.den, 1e-15);
out.rate = cfg.W * log2(1 + out.sinr);
out.mean_desired = mean(ul.desired(:));
out.mean_intra = mean(ul.intra(:));
out.mean_inter = mean(ul.inter(:));
out.mean_rsi = mean(ul.rsi(:));
out.mean_noise = mean(out.noise(:));
out.desired_to_interference = out.mean_desired / max(out.mean_intra + out.mean_inter + out.mean_rsi, 1e-15);
out.desired_to_noise = out.mean_desired / max(out.mean_noise, 1e-15);
end
