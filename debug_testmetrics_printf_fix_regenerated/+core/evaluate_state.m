function m = evaluate_state(cfg, net, assoc, ris_assign, state)
% Backward-compatible wrapper to the modular metrics stack.
if isfield(state, 'txrx')
    txrx = state.txrx;
else
    txrx.precoders = state.precoders;
    txrx.ul_receivers = state.ul_receivers;
end
m = metrics.evaluate_state_modular(cfg, net, assoc, ris_assign, state, txrx);
end
