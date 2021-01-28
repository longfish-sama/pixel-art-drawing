library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity color_ctrl is
    port (
        clk, rst: in std_logic;
        x_point, y_point: in std_logic_vector(7 downto 0);
        key_code: in std_logic_vector(3 downto 0);
        color_num: out std_logic_vector(7 downto 0)
    );
end entity color_ctrl;

architecture bhv of color_ctrl is
    
begin
    color_sel: process(clk, rst)
        variable x_tmp, y_tmp: integer range 0 to 35;
        variable color_tmp: integer range 1 to 32;
        variable eraser, brush: integer range 1 to 32;
    begin
        if rst = '0' then
            x_tmp:= 33;
            y_tmp:= 1;
            color_tmp:= 1;
            color_num<= conv_std_logic_vector(1, color_num'length);
        elsif rising_edge(clk) then
            x_tmp:= conv_integer(x_point);
            y_tmp:= conv_integer(y_point);
            if x_tmp= 33 and y_tmp= 1 then
                color_tmp:= 1;
            elsif x_tmp= 34 and y_tmp= 1 then
                color_tmp:= 2;
            elsif x_tmp= 33 and y_tmp= 2 then
                color_tmp:= 3;
            elsif x_tmp= 34 and y_tmp= 2 then
                color_tmp:= 4;
            elsif x_tmp= 33 and y_tmp= 3 then
                color_tmp:= 5;
            elsif x_tmp= 34 and y_tmp= 3 then
                color_tmp:= 6;
            elsif x_tmp= 33 and y_tmp= 4 then
                color_tmp:= 7;
            elsif x_tmp= 34 and y_tmp= 4 then
                color_tmp:= 8;
            elsif x_tmp= 33 and y_tmp= 5 then
                color_tmp:= 9;
            elsif x_tmp= 34 and y_tmp= 5 then
                color_tmp:= 10;
            elsif x_tmp= 33 and y_tmp= 6 then
                color_tmp:= 11;
            elsif x_tmp= 34 and y_tmp= 6 then
                color_tmp:= 12;
            elsif x_tmp= 33 and y_tmp= 7 then
                color_tmp:= 13;
            elsif x_tmp= 34 and y_tmp= 7 then
                color_tmp:= 14;
            elsif x_tmp= 33 and y_tmp= 8 then
                color_tmp:= 15;
            elsif x_tmp= 34 and y_tmp= 8 then
                color_tmp:= 16;
            elsif x_tmp= 33 and y_tmp= 9 then
                color_tmp:= 17;
            elsif x_tmp= 34 and y_tmp= 9 then
                color_tmp:= 18;
            elsif x_tmp= 33 and y_tmp= 10 then
                color_tmp:= 19;
            elsif x_tmp= 34 and y_tmp= 10 then
                color_tmp:= 20;
            elsif x_tmp= 33 and y_tmp= 11 then
                color_tmp:= 21;
            elsif x_tmp= 34 and y_tmp= 11 then
                color_tmp:= 22;
            elsif x_tmp= 33 and y_tmp= 12 then
                color_tmp:= 23;
            elsif x_tmp= 34 and y_tmp= 12 then
                color_tmp:= 24;
            elsif x_tmp= 33 and y_tmp= 13 then
                color_tmp:= 25;
            elsif x_tmp= 34 and y_tmp= 13 then
                color_tmp:= 26;
            elsif x_tmp= 33 and y_tmp= 14 then
                color_tmp:= 27;
            elsif x_tmp= 34 and y_tmp= 14 then
                color_tmp:= 28;
            elsif x_tmp= 33 and y_tmp= 15 then
                color_tmp:= 29;
            elsif x_tmp= 34 and y_tmp= 15 then
                color_tmp:= 30;
            elsif x_tmp= 33 and y_tmp= 16 then
                color_tmp:= 31;
            elsif x_tmp= 34 and y_tmp= 16 then
                color_tmp:= 32;
            end if;
            if (key_code= "0001" or key_code= "1111") and x_tmp>= 33 and x_tmp<= 34 then
                brush:= color_tmp;
                color_num<= conv_std_logic_vector(brush, color_num'length);
            elsif key_code= "1110" and x_tmp>= 33 and x_tmp<= 34 then
                eraser:= color_tmp;
                color_num<= conv_std_logic_vector(eraser, color_num'length);
            elsif key_code= "1110" then
                color_num<= conv_std_logic_vector(eraser, color_num'length);
            elsif key_code= "1111" then
                color_num<= conv_std_logic_vector(brush, color_num'length);
            end if;
        end if;
    end process color_sel;
    
    
end architecture bhv;