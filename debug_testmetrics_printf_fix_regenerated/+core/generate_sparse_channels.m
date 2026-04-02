function H = generate_sparse_channels(cfg, tx_pos, rx_pos, Nt_in, Nr_in, los_map, is_double_hop)
if nargin < 7, is_double_hop = false; end
nTx = size(tx_pos,1);
nRx = size(rx_pos,1);
H = cell(nTx, nRx);

if isscalar(Nt_in)
    Nt_vec = repmat(Nt_in, nTx, 1);
else
    Nt_vec = Nt_in(:);
end
if isscalar(Nr_in)
    Nr_vec = repmat(Nr_in, nRx, 1);
else
    Nr_vec = Nr_in(:);
end
if islogical(los_map) || isnumeric(los_map)
    los = los_map;
else
    los = true(nTx,nRx);
end

ris_link_gain = 10^(cfg.ris_link_extra_gain_dB/20);

for t = 1:nTx
    for r = 1:nRx
        Nt = Nt_vec(t); Nr = Nr_vec(r);
        d = norm(tx_pos(t,:) - rx_pos(r,:)) + 1e-3;
        pl = core.pathloss_linear(cfg, d, is_double_hop);
        if ~los(t,r)
            pl = pl * 10^(cfg.block_penalty_dB/10);
        end
        Hraw = core.sample_sparse_mimo(cfg, Nt, Nr);
        gain = sqrt(1/max(pl, eps));

        % RIS-hop channels are easily over-attenuated because both hops
        % are normalized and then multiplied again during reflection.
        % Add a controlled amplitude lift here so the RIS path stays
        % numerically relevant before optimization.
        if Nt == cfg.N0 || Nr == cfg.N0
            gain = gain * sqrt(max(cfg.N0,1)) * ris_link_gain;
        end

        H{t,r} = gain * Hraw;
    end
end
end
