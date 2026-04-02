function net = generate_network(cfg)
B = cfg.B; U = cfg.U; R = cfg.R;
area = cfg.area_xy;

net.bs_pos = zeros(B,2);
net.bs_type = strings(B,1);
net.bs_pos(1,:) = area / 2;
net.bs_type(1) = "macro";
net.bs_pos(2:end,:) = rand(B-1,2) .* area;
net.bs_type(2:end) = "pico";
net.ue_pos = rand(U,2) .* area;

nblk = max(R, round(prod(area) * cfg.blockage_density));
blk = core.generate_blockages(cfg, nblk);
net.blockages = blk;
net.ris = core.place_ris_on_blockages(cfg, blk, R);
net.ris_pos = net.ris.pos;

net.bs_params = core.expand_bs_params(cfg, net.bs_type);
net.Pmax_W = 10.^((net.bs_params.Pmax_dBm - 30)/10);

net.dist_bs_ue = utils.pdist2_fast(net.bs_pos, net.ue_pos);
net.dist_bs_ris = utils.pdist2_fast(net.bs_pos, net.ris_pos);
net.dist_ris_ue = utils.pdist2_fast(net.ris_pos, net.ue_pos);
net.dist_ue_bs = net.dist_bs_ue';
net.dist_bs_bs = utils.pdist2_fast(net.bs_pos, net.bs_pos);
net.dist_ue_ue = utils.pdist2_fast(net.ue_pos, net.ue_pos);

% LoS / visibility
net.los.bs_ue = false(B,U);
for b = 1:B
    for u = 1:U
        net.los.bs_ue(b,u) = core.line_of_sight(net.bs_pos(b,:), net.ue_pos(u,:), blk);
    end
end
net.los.bs_ris = false(B,R);
net.los.ris_ue = false(R,U);
for b = 1:B
    for r = 1:R
        net.los.bs_ris(b,r) = core.line_of_sight(net.bs_pos(b,:), net.ris_pos(r,:), blk);
    end
end
for r = 1:R
    for u = 1:U
        net.los.ris_ue(r,u) = core.line_of_sight(net.ris_pos(r,:), net.ue_pos(u,:), blk);
    end
end

net.ch.bs_ue = core.generate_sparse_channels(cfg, net.bs_pos, net.ue_pos, net.bs_params.Nt, 1, net.los.bs_ue, false);
net.ch.ue_bs = core.generate_sparse_channels(cfg, net.ue_pos, net.bs_pos, 1, 1, net.los.bs_ue.', false);
net.ch.bs_ris = core.generate_sparse_channels(cfg, net.bs_pos, net.ris_pos, net.bs_params.Nt, cfg.N0, net.los.bs_ris, false);
net.ch.ris_ue = core.generate_sparse_channels(cfg, net.ris_pos, net.ue_pos, cfg.N0, 1, net.los.ris_ue, false);
net.ch.ue_ris = core.generate_sparse_channels(cfg, net.ue_pos, net.ris_pos, 1, cfg.N0, net.los.ris_ue.', false);
net.ch.ris_bs = core.generate_sparse_channels(cfg, net.ris_pos, net.bs_pos, cfg.N0, 1, net.los.bs_ris.', false);
net.ch.bs_bs = core.generate_sparse_channels(cfg, net.bs_pos, net.bs_pos, net.bs_params.Nt, 1, true(B,B), false);
net.ch.ue_ue = core.generate_sparse_channels(cfg, net.ue_pos, net.ue_pos, 1, 1, true(U,U), false);
end
