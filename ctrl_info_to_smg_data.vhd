library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ctrl_info_to_smg_data is
    port (
        clk, rst: in std_logic;
        x_point, y_point, color_num: in std_logic_vector(7 downto 0);
        smg_out: out std_logic_vector(23 downto 0)
    );
end entity ctrl_info_to_smg_data;

architecture bhv of ctrl_info_to_smg_data is
    
begin
    pointer_smg: process(clk, rst)
        variable x_point10, x_point1, y_point10, y_point1, color_num10, color_num1: std_logic_vector(3 downto 0);
        variable x_tmp, y_tmp, color_tmp: integer range 0 to 70;
    begin
        if rst = '0' then
            smg_out<= x"888888";
        elsif rising_edge(clk) then
            x_tmp:= conv_integer(x_point);
            y_tmp:= conv_integer(y_point);
            color_tmp:= conv_integer(color_num);
            x_point10:= conv_std_logic_vector(x_tmp/10, x_point10'length);
            x_point1:= conv_std_logic_vector(x_tmp rem 10, x_point1'length);
            y_point10:= conv_std_logic_vector(y_tmp/10, y_point10'length);
            y_point1:= conv_std_logic_vector(y_tmp rem 10, y_point1'length);
            color_num10:= conv_std_logic_vector(color_tmp/10, color_num10'length);
            color_num1:= conv_std_logic_vector(color_tmp rem 10, color_num1'length);
            smg_out<= x_point10& x_point1& y_point10& y_point1& color_num10& color_num1;
        end if;
    end process pointer_smg;
    
    
end architecture bhv;