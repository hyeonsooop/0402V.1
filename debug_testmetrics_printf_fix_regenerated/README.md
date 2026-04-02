# RPM-CGJO Fig.5 Modular Refactor

This package keeps the original experiment entry point and scenario loop, but refactors the internals into reusable layers:

- `+geometry`: layout and channel generation wrapper
- `+association`: user clustering and RIS-SSF assignment wrapper
- `+transceiver`: DL precoders and UL receivers
- `+metrics`: effective channels, SINR/rates, power, EE/penalty
- `+optimizer`: objective decomposition and gradients
- `+debug`: block-wise sanity checks

## Main file
- `main_fig5_proposed_only.m`

## Backward compatibility
Legacy calls to:
- `core.evaluate_state`
- `core.compute_cost_and_gradient`

still work, but they now call the modular stack internally.

## Recommended debug order
1. `debug.test_metrics_only(cfg)`
2. Run one scenario with small `max_iter`
3. Inspect `logs/*.csv` and `reflect_direct_ratio`
4. Replace transceiver or optimizer blocks independently for other papers
