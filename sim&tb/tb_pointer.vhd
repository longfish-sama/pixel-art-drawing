library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_pointer is
end entity tb_pointer;

architecture tb of tb_pointer is
    component pointer
    port (
        clk_sys, rst: in std_logic;
        key_code: in std_logic_vector(3 downto 0);
        x_point, y_point: out std_logic_vector(7 downto 0)
    );
    end component;
    signal clk_sys, rst: std_logic;
    signal key_code: std_logic_vector(3 downto 0);
    signal x_point, y_point: std_logic_vector(7 downto 0);

begin
    u1:pointer
    port map(
        clk_sys=> clk_sys,
        rst=> rst,
        key_code=> key_code,
        x_point=> x_point,
        y_point=> y_point
    );
    clk_gen: process
    begin
        clk_sys<= '0';
        wait for 10 ns;
        clk_sys<= '1';
        wait for 10 ns;
    end process clk_gen;
    rst_gen: process
    begin
        rst<= '0';
        wait for 1 us;
        rst<= '1';
        wait;
    end process rst_gen;
    code_gen: process
    begin
        for i in 1 to 66 loop
            key_code<= "0100";
            wait for 40 ns;
        end loop;
        for j in 1 to 66 loop
            key_code<= "0011";
            wait for 40 ns;
        end loop;
        for k in 1 to 66 loop
            key_code<= "0101";
            wait for 40 ns;
        end loop;
        for n in 1 to 20 loop
            key_code<= "0010";
            wait for 40 ns;
        end loop;
    end process code_gen;
    
end architecture tb;