function y = softplus_stable(x)
% Numerically stable log(1+exp(x)).
y = zeros(size(x));
idx = x > 30;
y(idx) = x(idx);
y(~idx) = log1p(exp(x(~idx)));
end
