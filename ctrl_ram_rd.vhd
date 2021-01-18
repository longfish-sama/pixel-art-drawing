library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;

entity ctrl_ram_rd is
    port (
        x_point, y_point, color_num: out std_logic_vector(7 downto 0);
        clk_pix, rst: in std_logic;
        add_rd: out std_logic_vector(1 downto 0);
        rd_data: in std_logic_vector(7 downto 0)
    );
end entity ctrl_ram_rd;

architecture asm of ctrl_ram_rd is
begin
    ram_rd: process(clk_pix, rst)
        type state_type is (s0, s1, s2);
        variable state: state_type;
    begin
        if rst = '0' then
            x_point<= conv_std_logic_vector(65, x_point'length);
            y_point<= conv_std_logic_vector(1, y_point'length);
            color_num<= conv_std_logic_vector(1, color_num'length);
            add_rd<= (others=> '0');
            state:= s0;
        elsif rising_edge(clk_pix) then
            case state is
                when s0 =>
                    add_rd<= "00";
                    x_point<= rd_data;
                    state:= s1;
                when s1 =>
                    add_rd<= "01";
                    y_point<= rd_data;
                    state:= s2;
                when s2 =>
                    add_rd<= "10";
                    color_num<= rd_data;
                    state:= s0;
            end case;
        end if;
    end process ram_rd;
end architecture asm;