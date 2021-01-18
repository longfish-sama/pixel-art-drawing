library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_color_bar is
end entity tb_color_bar;

architecture tb of tb_color_bar is
    signal clk_pix: std_logic;
    signal rst: std_logic;
    signal hor_sync: std_logic;
    signal ver_sync: std_logic;
    signal de: std_logic;
    signal vga_r: std_logic_vector(7 downto 0);
    signal vga_b: std_logic_vector(7 downto 0);
    signal vga_g: std_logic_vector(7 downto 0);
    component vga_color_bar
        port(
            clk_pix, rst: in std_logic;
            hor_sync, ver_sync, de: out std_logic;
            vga_r, vga_g, vga_b: out std_logic_vector(7 downto 0)    
        );
    end component;
begin
    u1:vga_color_bar
    port map(
        clk_pix=> clk_pix,
        rst=> rst,
        hor_sync=> hor_sync,
        ver_sync=> ver_sync,
        de=> de,
        vga_r=> vga_r,
        vga_g=> vga_g,
        vga_b=> vga_b
    );
    clk_gen: process
    begin
        clk_pix<= '0';
        wait for 6.734 ns;
        clk_pix<= '1';
        wait for 6.734 ns;
    end process clk_gen;
    rst_gen: process
    begin
        rst<= '0';
        wait for 1 us;
        rst<= '1';
        wait;
    end process rst_gen;
    
end architecture tb;