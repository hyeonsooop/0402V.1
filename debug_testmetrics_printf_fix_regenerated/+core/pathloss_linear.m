function pl = pathloss_linear(cfg, d, is_double_hop)
pl_single = ((4*pi*cfg.fc*d)/cfg.c)^2 * exp(cfg.k_abs * d);
if is_double_hop
    pl = (pl_single.^2) * 10^(cfg.reflection_penalty_dB/10);
else
    pl = pl_single;
end
end
