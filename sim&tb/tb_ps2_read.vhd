library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ps2_read is
end entity tb_ps2_read;

architecture bhv of tb_ps2_read is
    signal clk_sys: std_logic;
    signal clk_ps2: std_logic;
    signal data_in_ps2: std_logic;
    signal rst: std_logic;
    signal data_out_ps2: std_logic_vector(7 downto 0);
    signal key_code_out:std_logic_vector(3 downto 0);
    component ps2_read
    port(
        clk_sys: in std_logic;
        clk_ps2: in std_logic;
        data_in_ps2: in std_logic;
        rst: in std_logic;
        data_out_ps2: out std_logic_vector(7 downto 0)
    ); end component;
    component ps2_decode
    port(
        code_in_ps2: in std_logic_vector(7 downto 0);
        clk_sys, rst: in std_logic;
        key_code_out: out std_logic_vector(3 downto 0)
    ); end component;
begin
    u1:ps2_read
    port map(
        clk_ps2=> clk_ps2,
        clk_sys=> clk_sys,
        data_out_ps2=> data_out_ps2,
        data_in_ps2=> data_in_ps2,
        rst=> rst
    );
    u2:ps2_decode
    port map(
        code_in_ps2=> data_out_ps2,
        clk_sys=> clk_sys,
        rst=> rst,
        key_code_out=> key_code_out
    );
    clk_sys_gen: process
    begin
        clk_sys<= '0';
        wait for 10 ns;
        clk_sys<= '1';
        wait for 10 ns;
    end process clk_sys_gen;
    clk_ps2_gen: process
    begin
        clk_ps2<= '1';
        wait for 1 ms;
--clk_ps2<='1';wait for 39 ns;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;

        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;

        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;

        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;

        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;

        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;

        clk_ps2<= '0';
        wait for 39 us;
        clk_ps2<= '1';
        wait for 39 us;
        
        clk_ps2<= '1';
        wait for 1 ms;
    end process clk_ps2_gen;
    rst_gen: process
    begin
        rst<= '0';
        wait for 1 us;
        rst<= '1';
        wait;
    end process rst_gen;
    ps2_data_gen: process
    begin
        data_in_ps2<= '1';
        wait for 1 ms;
----------------------------------
        data_in_ps2<= '0'; --起始位
        wait for 78 us;

        data_in_ps2<= '0'; --8位数据
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '1';
        wait for 78 us;
        data_in_ps2<= '1';
        wait for 78 us;
        data_in_ps2<= '1';
        wait for 78 us;
        data_in_ps2<= '1';
        wait for 78 us;

        data_in_ps2<= '1'; --奇校验
        wait for 78 us;

        data_in_ps2<= '1'; --停止位
        wait for 78 us;
----------------------------------
        data_in_ps2<= '0'; --起始位
        wait for 78 us;

        data_in_ps2<= '1'; --8位数据
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '1';
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '1';
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;
        data_in_ps2<= '0';
        wait for 78 us;

        data_in_ps2<= '0'; --奇校验
        wait for 78 us;

        data_in_ps2<= '1'; --停止位
        wait for 78 us;

        data_in_ps2<= '1';
        wait for 1 ms;

    end process ps2_data_gen;
end architecture bhv;