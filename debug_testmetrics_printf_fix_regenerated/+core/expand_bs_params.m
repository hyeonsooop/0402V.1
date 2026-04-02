function p = expand_bs_params(cfg, bs_type)
B = numel(bs_type);
p.Nt = zeros(B,1);
p.Nr = zeros(B,1);
p.NRF = zeros(B,1);
p.Pmax_dBm = zeros(B,1);
p.mu = zeros(B,1);
p.PAB = zeros(B,1);
p.PSB = zeros(B,1);
for b = 1:B
    if bs_type(b) == "macro"
        s = cfg.macro;
    else
        s = cfg.pico;
    end
    p.Nt(b) = s.Nt;
    p.Nr(b) = s.Nr;
    p.NRF(b) = s.NRF;
    p.Pmax_dBm(b) = s.Pmax_dBm;
    p.mu(b) = s.mu;
    p.PAB(b) = s.PAB;
    p.PSB(b) = s.PSB;
end
