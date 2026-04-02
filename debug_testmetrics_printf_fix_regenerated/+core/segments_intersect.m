function tf = segments_intersect(p1, p2, q1, q2)
% Robust enough for simulation geometry.
o1 = orient2d(p1,p2,q1);
o2 = orient2d(p1,p2,q2);
o3 = orient2d(q1,q2,p1);
o4 = orient2d(q1,q2,p2);

tf = (o1*o2 < 0) && (o3*o4 < 0);

    function v = orient2d(a,b,c)
        v = (b(1)-a(1))*(c(2)-a(2)) - (b(2)-a(2))*(c(1)-a(1));
    end
end
