clear; clc; close all force;


cfg = core.default_config();
scenarios = {
    struct('name','Algorithm 3, 20RISs&2SSFs','R',20,'Ns',2,'N0',8,'surface_mode','ssf')
    struct('name','Algorithm 3, 10RISs&2SSFs','R',10,'Ns',2,'N0',8,'surface_mode','ssf')
    struct('name','Algorithm 3, 20RISs&NoSSF','R',20,'Ns',1,'N0',16,'surface_mode','nosff')
};

results = cell(numel(scenarios),1);
fig = figure('Color','w','Visible','off');
hold on; grid on;

for s = 1:numel(scenarios)
    run_cfg = cfg;
    run_cfg.R = scenarios{s}.R;
    run_cfg.Ns = scenarios{s}.Ns;
    run_cfg.N0 = scenarios{s}.N0;
    run_cfg.surface_mode = scenarios{s}.surface_mode;
    run_cfg.run_name = regexprep(lower(scenarios{s}.name),'[^a-z0-9]+','_');
    run_cfg.ris_surface_gain = sqrt(run_cfg.N0 * run_cfg.Ns);

    fprintf('\n=== Running %s ===\n', scenarios{s}.name);
    out = core.run_scenario(run_cfg);
    results{s} = out;

    plot(out.history.iter, out.history.EE, 'LineWidth', 1.7, 'DisplayName', scenarios{s}.name);
end

xlabel('Iteration Index');
ylabel('Energy Efficiency (bits/Joule)');
title('Figure 5 - Proposed Method Only');
legend('Location','best');
set(gca,'Box','on');

fig_file = 'results_fig5_proposed_only.fig';
mat_file = 'results_fig5_proposed_only.mat';

save(mat_file, 'results', 'cfg', 'scenarios');
try
    savefig(fig, fig_file);
catch ME
    warning('FIG save failed: %s', ME.message);
end

fprintf('\nSaved figure data: %s\n', fig_file);
fprintf('Saved workspace: %s\n', mat_file);
