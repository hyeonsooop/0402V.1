function [k_idx, i_idx] = find_assignment_index(assoc, u)
[k_idx, i_idx] = find(assoc.order == u, 1, 'first');
if isempty(k_idx)
    k_idx = 1;
    i_idx = 1;
end
end
