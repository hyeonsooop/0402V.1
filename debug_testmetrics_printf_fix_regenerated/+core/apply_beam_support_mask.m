function state = apply_beam_support_mask(state, txrx)
mask = txrx.precoders.cluster_supported;
if isempty(mask), return; end
state.p(~mask) = 0;
end
