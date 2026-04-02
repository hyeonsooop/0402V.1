function a = steering_upa(N, phi, theta, lambda, D)
L = floor(sqrt(N));
W = ceil(N / max(L,1));
vals = zeros(L*W,1);
idx = 1;
for l = 0:L-1
    for w = 0:W-1
        vals(idx) = exp(1j * (2*pi/lambda) * D * (l*sin(theta)*cos(phi) + w*cos(theta)));
        idx = idx + 1;
    end
end
vals = vals(1:N);
a = vals / sqrt(max(N,1));
