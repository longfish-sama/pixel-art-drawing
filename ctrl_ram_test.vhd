library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ctrl_ram_test is
    port (
        clk_pix, rst: in std_logic;
        add_rd: buffer std_logic_vector(1 downto 0)
    );
end entity ctrl_ram_test;

architecture test of ctrl_ram_test is
begin
    ram_rd: process(clk_pix, rst)
    begin
        if rst = '0' then
            add_rd<= (others=> '0');
        elsif rising_edge(clk_pix) then
            if add_rd= "10" then
                add_rd<= (others => '0');
            else
                add_rd<= add_rd+ 1;
            end if;
        end if;
    end process ram_rd;
    
end architecture test;