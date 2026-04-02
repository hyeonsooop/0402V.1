function tf = line_of_sight(p1, p2, blk)
% Simple segment intersection test against finite blockage segments.
tf = true;
for i = 1:size(blk.centers,1)
    q1 = blk.ends1(i,:);
    q2 = blk.ends2(i,:);
    if core.segments_intersect(p1, p2, q1, q2)
        tf = false;
        return;
    end
end
end
