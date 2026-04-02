function tr = transport_direction(state, prev_state, prev_dir)
if isempty(prev_dir)
    tr.theta = zeros(size(state.theta));
    tr.p = zeros(size(state.p));
    return;
end
% transport on product manifold: Euclidean for p, projected transport for theta.
tr.theta = prev_dir.theta - real(conj(prev_dir.theta) .* state.theta) .* state.theta;
% scaled transport if norm increases
if nargin >= 2 && ~isempty(prev_state)
    oldn = norm(prev_dir.theta(:));
    newn = norm(tr.theta(:));
    if newn > oldn && newn > 0
        tr.theta = tr.theta * (oldn / newn);
    end
end
tr.p = prev_dir.p;
end
