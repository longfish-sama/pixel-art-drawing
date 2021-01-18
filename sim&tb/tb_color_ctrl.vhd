library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;

entity tb_color_ctrl is
end entity tb_color_ctrl;

architecture tb of tb_color_ctrl is
    component color_ctrl
    port (
        clk, rst: in std_logic;
        x_point, y_point: in std_logic_vector(7 downto 0);
        key_code: in std_logic_vector(3 downto 0);
        color_num: out std_logic_vector(7 downto 0)
    );
    end component;
    signal clk, rst: std_logic;
    signal x_point, y_point: std_logic_vector(7 downto 0);
    signal key_code: std_logic_vector(3 downto 0);
    signal color_num: std_logic_vector(7 downto 0);
begin
    u1:color_ctrl
    port map(
        clk=> clk,
        rst=> rst,
        x_point=> x_point,
        y_point=> y_point,
        key_code=> key_code,
        color_num=> color_num
    );
    clk_gen: process
    begin
        clk<= '0';
        wait for 10 ns;
        clk<= '1';
        wait for 10 ns;
    end process clk_gen;
    rst_gen: process
    begin
        rst<= '0';
        wait for 1 us;
        rst<= '1';
        wait;
    end process rst_gen;
    point_gen: process
    begin
        for i in 0 to 1 loop
            for j in 0 to 15 loop
                y_point<= conv_std_logic_vector(1+j, y_point'length);
                wait for 40 ns;
            end loop;
            x_point<= conv_std_logic_vector(65+i, x_point'length);
        end loop;
    end process point_gen;
    key_code<= "0001";
end architecture tb;