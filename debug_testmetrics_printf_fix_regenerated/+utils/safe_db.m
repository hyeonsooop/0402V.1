function y = safe_db(x)
y = 10*log10(max(real(x), 1e-15));
