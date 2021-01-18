library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pointer_to_smg is
    port (
        clk, rst: in std_logic;
        x_point, y_point, color_num: in std_logic_vector(7 downto 0);
        smg_out: out std_logic_vector(23 downto 0)
    );
end entity pointer_to_smg;

architecture bhv of pointer_to_smg is
    
begin
    pointer_smg: process(clk, rst)
    begin
        if rst = '0' then
            smg_out<= x"888888";
        elsif rising_edge(clk) then
            smg_out<= x_point& y_point& color_num;
        end if;
    end process pointer_smg;
    
    
end architecture bhv;