library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity par10bit_to_ddr_signal is
    port (
        clk_ddr, rst: in std_logic;
        data_par_in: in std_logic_vector(9 downto 0);
        data_out_h, data_out_l: out std_logic
    );
end entity par10bit_to_ddr_signal;

architecture bhv of par10bit_to_ddr_signal is
    begin
    ddr_gen: process(clk_ddr, rst)
        variable cnt: integer range 0 to 6:= 0;
        variable par_tmp: std_logic_vector(9 downto 0):= "0000000000";
    begin
        if rst = '0' then
            par_tmp:= "0000000000";
            cnt:= 0;
        elsif rising_edge(clk_ddr) then
            if cnt= 0 then
                par_tmp:= data_par_in;
            end if;
            data_out_h<= par_tmp(2* cnt);
            data_out_l<= par_tmp(2* cnt+ 1);
            cnt:= cnt+ 1;
            if cnt= 5 then
                cnt:= 0;
            end if;
        end if;
    end process ddr_gen;
end architecture bhv;