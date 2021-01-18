library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_par_to_ddr is
end entity tb_par_to_ddr;

architecture tb of tb_par_to_ddr is
    component par10bit_to_ddr_signal
    port (
        clk_ddr, rst: in std_logic;
        data_par_in: in std_logic_vector(9 downto 0);
        data_out_h, data_out_l: out std_logic
    );
    end component;
    signal clk_ddr, rst: std_logic;
    signal data_par_in: std_logic_vector(9 downto 0);
    signal data_out_h, data_out_l: std_logic;
    constant period: time:= 20 ns;
begin
    u1:par10bit_to_ddr_signal
    port map(
        clk_ddr=> clk_ddr,
        data_par_in=> data_par_in,
        rst=> rst,
        data_out_h=> data_out_h,
        data_out_l=> data_out_l
    );
    clkser_gen: process
    begin
        clk_ddr<= '0';
        wait for period/2;
        clk_ddr<= '1';
        wait for period/2;
    end process clkser_gen;
    dataparin_gen: process
    begin
        data_par_in<= "0000000000";
        for i in 0 to 1023 loop
            wait for period*5;
            data_par_in<= data_par_in+ 1;
        end loop;
    end process dataparin_gen;
    rst_gen: process
    begin
        rst<= '0';
        wait for 1 us;
        rst<= '1';
        wait;
    end process rst_gen;
end architecture tb;