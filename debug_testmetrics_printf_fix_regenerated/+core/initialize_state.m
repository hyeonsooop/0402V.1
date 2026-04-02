function state = initialize_state(cfg, net, assoc, ris_assign)
X = cfg.R * cfg.Ns * cfg.N0;
state.theta = exp(1j * 2*pi * rand(X,1));

state.p = zeros(cfg.B, cfg.K);
for b = 1:cfg.B
    Ptot_b = 0.35 * net.Pmax_W(b);
    state.p(b,:) = Ptot_b / cfg.K;
end

if cfg.Nc == 2
    state.user_power_split = repmat([0.7 0.3], cfg.K, 1);
else
    state.user_power_split = repmat((1/cfg.Nc) * ones(1,cfg.Nc), cfg.K, 1);
end
state.assoc = assoc;
state.ris_assign = ris_assign;
state.txrx = transceiver.compute_transceivers(cfg, net, assoc, ris_assign, state);
state = core.apply_beam_support_mask(state, state.txrx);
state.precoders = state.txrx.precoders;
state.ul_receivers = state.txrx.ul_receivers;
end
