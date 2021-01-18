library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_hdmi_color_bar is
end entity tb_hdmi_color_bar;

architecture tb of tb_hdmi_color_bar is
    component vga_color_bar
    port(
        clk_pix, rst: in std_logic;
        hor_sync, ver_sync, de: out std_logic;
        vga_r, vga_g, vga_b: out std_logic_vector(7 downto 0)    
    );
    end component;
    component tmds_encode
    port(
        data_in: in std_logic_vector(7 downto 0);
        ctrl0_in, ctrl1_in, data_en: in std_logic;
        clk, rst: in std_logic;
        data_out: out std_logic_vector(9 downto 0)
    );
    end component;
    component par10bit_to_ser
    port (
        clk_ddr, rst: in std_logic;
        data_par_in: in std_logic_vector(9 downto 0);
        data_ser_out: out std_logic
    );
    end component;
    signal wire_hor_sync: std_logic;
    signal wire_ver_sync: std_logic;
    signal wire_de: std_logic;
    signal wire_vga_r: std_logic_vector(7 downto 0);
    signal wire_vga_g: std_logic_vector(7 downto 0);
    signal wire_vga_b: std_logic_vector(7 downto 0);
    signal ctrl0, ctrl1, ctrl2, ctrl3: std_logic;
    signal wire_ch0_par: std_logic_vector(9 downto 0);
    signal wire_ch1_par: std_logic_vector(9 downto 0);
    signal wire_ch2_par: std_logic_vector(9 downto 0);
    signal clk_ddr, clk_pix, rst: std_logic;
    signal data_ser_out0, data_ser_out1, data_ser_out2: std_logic;

begin
    u1:vga_color_bar
    port map(
        clk_pix=> clk_pix,
        rst=> rst,
        hor_sync=> wire_hor_sync,
        ver_sync=> wire_ver_sync,
        de=> wire_de,
        vga_r=> wire_vga_r,
        vga_g=> wire_vga_g,
        vga_b=> wire_vga_b
    );
    u21:tmds_encode
    port map(
        data_in=> wire_vga_r,
        ctrl0_in=> wire_hor_sync,
        ctrl1_in=> wire_ver_sync,
        data_en=> wire_de,
        clk=> clk_pix,
        rst=> rst,
        data_out=> wire_ch0_par
    );
    u22:tmds_encode
    port map(
        data_in=> wire_vga_g,
        ctrl0_in=> ctrl0,
        ctrl1_in=> ctrl1,
        data_en=> wire_de,
        clk=> clk_pix,
        rst=> rst,
        data_out=> wire_ch1_par
    );
    u23:tmds_encode
    port map(
        data_in=> wire_vga_b,
        ctrl0_in=> ctrl2,
        ctrl1_in=> ctrl3,
        data_en=> wire_de,
        clk=> clk_pix,
        rst=> rst,
        data_out=> wire_ch2_par
    );
    u31:par10bit_to_ser
    port map(
        clk_ddr=> clk_ddr,
        rst=> rst,
        data_par_in=> wire_ch0_par,
        data_ser_out=> data_ser_out0
    );
    u32:par10bit_to_ser
    port map(
        clk_ddr=> clk_ddr,
        rst=> rst,
        data_par_in=> wire_ch1_par,
        data_ser_out=> data_ser_out1
    );
    u33:par10bit_to_ser
    port map(
        clk_ddr=> clk_ddr,
        rst=> rst,
        data_par_in=> wire_ch2_par,
        data_ser_out=> data_ser_out2
    );
    clkpix_gen: process
    begin
        clk_pix<= '0';
        wait for 3.367 ns;
        clk_pix<= '1';
        wait for 3.367 ns;
    end process clkpix_gen;
    clkddr_gen: process
    begin
        clk_ddr<= '0';
        wait for 673.4 ps;
        clk_ddr<= '1';
        wait for 673.4 ps;
    end process clkddr_gen;
    rst_gen: process
    begin
        rst<= '0';
        wait for 1 us;
        rst<= '1';
        wait;
    end process rst_gen;
    ctrl0<= '1';
    ctrl1<= '0';
    ctrl2<= '0';
    ctrl3<= '0';
end architecture tb;