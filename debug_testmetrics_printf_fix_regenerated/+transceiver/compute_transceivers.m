function txrx = compute_transceivers(cfg, net, assoc, ris_assign, state)
%COMPUTE_TRANSCEIVERS Compute DL precoders and UL receivers together.
txrx.precoders = transceiver.design_dl_precoders(cfg, net, assoc, ris_assign, state.theta);
txrx.ul_receivers = transceiver.design_ul_receivers(cfg, net, assoc, ris_assign, state.theta);
end
