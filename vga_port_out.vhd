library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_port_out is
    port (
        rgb_r, rgb_g, rgb_b: in std_logic_vector(7 downto 0);
        vga_r: out std_logic_vector(4 downto 0);
        vga_g: out std_logic_vector(5 downto 0);
        vga_b: out std_logic_vector(4 downto 0)
    );
end entity vga_port_out;

architecture bhv of vga_port_out is
begin
    vga_r<= rgb_r(7 downto 3);
    vga_g<= rgb_g(7 downto 2);
    vga_b<= rgb_b(7 downto 3);
end architecture bhv;