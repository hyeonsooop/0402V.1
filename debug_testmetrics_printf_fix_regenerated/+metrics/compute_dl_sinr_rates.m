function out = compute_dl_sinr_rates(cfg, dl)
out.noise = cfg.noise_power_W * ones(size(dl.desired));
out.den = dl.intra + dl.inter + dl.cci + out.noise;
out.sinr = dl.desired ./ max(out.den, 1e-15);
out.rate = cfg.W * log2(1 + out.sinr);
out.mean_direct = dl.sum_direct / max(dl.nlinks,1);
out.mean_reflect = dl.sum_reflect / max(dl.nlinks,1);
out.mean_desired = mean(dl.desired(:));
out.mean_intra = mean(dl.intra(:));
out.mean_inter = mean(dl.inter(:));
out.mean_cci = mean(dl.cci(:));
out.mean_noise = mean(out.noise(:));
out.desired_to_interference = out.mean_desired / max(out.mean_intra + out.mean_inter + out.mean_cci, 1e-15);
out.desired_to_noise = out.mean_desired / max(out.mean_noise, 1e-15);
end
