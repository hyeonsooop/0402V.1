function blk = generate_blockages(cfg, n)
area = cfg.area_xy;
blk.centers = rand(n,2) .* area;
blk.lengths = max(5, cfg.blockage_mean_len + cfg.blockage_len_span * (rand(n,1) - 0.5));
blk.angles = 2*pi*rand(n,1);
blk.ends1 = blk.centers + 0.5 * blk.lengths .* [cos(blk.angles), sin(blk.angles)];
blk.ends2 = blk.centers - 0.5 * blk.lengths .* [cos(blk.angles), sin(blk.angles)];
end
