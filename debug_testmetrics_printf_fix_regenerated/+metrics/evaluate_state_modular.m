function m = evaluate_state_modular(cfg, net, assoc, ris_assign, state, txrx)
dl_terms = metrics.effective_dl_terms(cfg, net, assoc, ris_assign, state, txrx);
ul_terms = metrics.effective_ul_terms(cfg, net, assoc, ris_assign, state, txrx);
dl = metrics.compute_dl_sinr_rates(cfg, dl_terms);
ul = metrics.compute_ul_sinr_rates(cfg, ul_terms);
power = metrics.compute_power_consumption(cfg, net, state, struct('Rsum', sum(dl.rate,'all') + sum(ul.rate,'all')));
meta = metrics.compute_ee_and_penalty(cfg, net, dl.rate, ul.rate, power);

m = meta;
m.sinr_dl = dl.sinr; m.sinr_ul = ul.sinr;
m.Rd = dl.rate; m.Ru = ul.rate;
m.mean_direct = dl.mean_direct;
m.mean_reflect = dl.mean_reflect;
m.components.dl = dl_terms;
m.components.ul = ul_terms;
m.components.power = power;
m.breakdown.dl = rmfield(dl, {'sinr','rate'});
m.breakdown.ul = rmfield(ul, {'sinr','rate'});
end
