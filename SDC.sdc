create_clock -name clk_ps2 -period 66667 [get_ports {clk_ps2}]
create_clock -name clk_sys -period 20 [get_ports {clk_sys}]
derive_pll_clocks
derive_clock_uncertainty