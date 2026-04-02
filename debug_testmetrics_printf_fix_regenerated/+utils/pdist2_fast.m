function D = pdist2_fast(A, B)
na = size(A,1); nb = size(B,1);
D = zeros(na, nb);
for i = 1:na
    diff = B - A(i,:);
    D(i,:) = sqrt(sum(diff.^2,2));
end
