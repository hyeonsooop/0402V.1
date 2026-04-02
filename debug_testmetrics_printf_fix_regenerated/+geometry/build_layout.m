function net = build_layout(cfg)
%BUILD_LAYOUT Geometry and channel wrapper for scenario generation.
%   Keeps the original network generator but exposes a stable geometry entry
%   point for future papers and alternative channel models.
net = core.generate_network(cfg);
end
