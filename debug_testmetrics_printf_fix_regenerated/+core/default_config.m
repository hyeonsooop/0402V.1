function cfg = default_config()
% Reference-guided configuration for TVT 2024 Fig. 5 proposed method.

cfg.seed = 7;
cfg.area_xy = [500, 500];
cfg.B = 21;           % 1 macro + 20 pico
cfg.P = 20;
cfg.U = 20;
cfg.R = 20;
cfg.Ns = 2;
cfg.N0 = 8;
cfg.Nc = 2;
cfg.K = cfg.U / cfg.Nc;
cfg.Mc = 2;

cfg.fc = 340e9;
cfg.W = 20e9;
cfg.c = 3e8;
cfg.lambda = cfg.c / cfg.fc;
cfg.D = cfg.lambda / 2;
cfg.Np = 5;
cfg.Gt_dB = 0;
cfg.Gr_dB = 0;
cfg.k_abs = 0.003;                 % placeholder absorption coefficient at 340 GHz
cfg.block_penalty_dB = 25;         % attenuation for blocked direct/NLoS links
cfg.reflection_penalty_dB = 8;     % additional attenuation per reflected hop
cfg.ris_link_extra_gain_dB = 40;    % extra amplitude lift for RIS-hop links
cfg.quant_bits = 4;
cfg.ris_surface_gain = sqrt(cfg.N0 * cfg.Ns);                % phase quantization for analog precoder

cfg.macro.Nt = 256;
cfg.macro.Nr = 1;
cfg.macro.NRF = 4;
cfg.macro.Pmax_dBm = 46;
cfg.macro.mu = 0.388;
cfg.macro.PAB = 65.8;
cfg.macro.PSB = 19.7;

cfg.pico.Nt = 64;
cfg.pico.Nr = 1;
cfg.pico.NRF = 1;
cfg.pico.Pmax_dBm = 30;
cfg.pico.mu = 0.08;
cfg.pico.PAB = 1.5;
cfg.pico.PSB = 0.5;

cfg.PBB = 7.54;
cfg.PPS = 40e-3;
cfg.p0 = 0.825;
cfg.pbh = 0.25;                    % W / Gbit/s
cfg.Pn_b_dBm = 10;
cfg.rho_rsi_dB = -110;
cfg.beta1 = 0.5;
cfg.beta2 = 0.5;

% blockage model inspired by line Boolean model reference
cfg.blockage_density = 500 / 1e6;  % per m^2
cfg.blockage_mean_len = 25;
cfg.blockage_len_span = 20;

cfg.noise_figure_dB = 7;
cfg.noise_power_W = 10.^((-174 + 10*log10(cfg.W) + cfg.noise_figure_dB - 30)/10);
cfg.ue_tx_W = 0.05;
cfg.ue_circuit_W = 0.10;

cfg.max_iter = 300;
cfg.delta = 1e-5;
cfg.armijo_c1 = 1e-4;
cfg.armijo_backtrack = 0.5;
cfg.armijo_max_trials = 20;
cfg.step_theta = 0.12;
cfg.step_p = 0.10;

cfg.kappa = 5.0;
cfg.lambda_penalty = 1.0 * ones(cfg.B,1);
cfg.tau_d = 1.0 * ones(cfg.K, cfg.Nc);
cfg.tau_u = 1.0 * ones(cfg.K, cfg.Nc);
cfg.Rd_Q = 0.05e9;   % 50 Mbps target
cfg.Ru_Q = 0.02e9;   % 20 Mbps target
cfg.ee_scale = 1e8;
cfg.w_penalty_power = 1.0;
cfg.w_penalty_qos = 1.0;
cfg.gp_scale = 1.0;
cfg.gth_scale = 1.0;
cfg.gth_clip = 0.15;

cfg.log_every = 10;
cfg.run_name = 'default_run';
cfg.surface_mode = 'ssf';
end
