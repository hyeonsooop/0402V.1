function p = compute_power_consumption(cfg, net, state, rates)
PTP_j = sum(state.p,2);
PBS = sum((1 ./ net.bs_params.mu) .* PTP_j + net.bs_params.PAB + cfg.PBB + net.bs_params.PSB + cfg.PPS);
PUE = cfg.U * ((1/0.5) * cfg.ue_tx_W + cfg.ue_circuit_W);
PRIS = cfg.R * cfg.Ns * cfg.N0 * 10.^((cfg.Pn_b_dBm - 30)/10);
PBH = cfg.pbh * (rates.Rsum/1e9) + cfg.p0;
p.total = PBS + PUE + PRIS + PBH;
p.per_bs_tx = PTP_j;
p.PBS = PBS; p.PUE = PUE; p.PRIS = PRIS; p.PBH = PBH;
end
