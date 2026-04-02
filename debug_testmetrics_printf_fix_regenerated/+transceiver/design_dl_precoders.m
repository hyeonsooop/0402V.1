function prec = design_dl_precoders(cfg, net, assoc, ris_assign, theta)
%DESIGN_DL_PRECODERS Wrapper around the current two-stage HP implementation.
prec = core.design_hybrid_precoders(cfg, net, assoc, ris_assign, theta);
end
