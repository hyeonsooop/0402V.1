function ris = place_ris_on_blockages(cfg, blk, R)
idx = randi(size(blk.centers,1), R, 1);
ris.pos = blk.centers(idx,:);
ris.blockage_idx = idx;
ris.normal = [ -sin(blk.angles(idx)), cos(blk.angles(idx)) ];
% one-sided deployment: push slightly to one side of the blockage
ris.pos = ris.pos + 0.75 * ris.normal;
ris.side_sign = ones(R,1);
ris.angles = blk.angles(idx);
if size(ris.pos,1) ~= R
    error('RIS placement size mismatch.');
end
end
