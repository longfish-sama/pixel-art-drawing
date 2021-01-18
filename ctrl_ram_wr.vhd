library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ctrl_ram_wr is
    port (
        x_point, y_point, color_num: in std_logic_vector(7 downto 0);
        clk, rst: in std_logic;
        add_wr: out std_logic_vector(1 downto 0);
        ctrl_data: out std_logic_vector(7 downto 0);
        wr_en: out std_logic
    );
end entity ctrl_ram_wr;

architecture asm of ctrl_ram_wr is
begin
    ram_ctrl: process(clk, rst, x_point, y_point, color_num)
        type state_type is (s0, s1, s2);
        variable state: state_type;
    begin
        if rst = '0' then
            add_wr<= (others => '0');
            ctrl_data<= (others => '0');
            wr_en<= '0';
            state:= s0;
        elsif rising_edge(clk) then
            case state is
                when s0 =>
                    ctrl_data<= x_point;
                    add_wr<= "00";
                    wr_en<= '1';
                    state:= s1;
                when s1 =>
                    ctrl_data<= y_point;
                    add_wr<= "01";
                    wr_en<= '1';
                    state:= s2;
                when s2 =>
                    ctrl_data<= color_num;
                    add_wr<= "10";
                    wr_en<= '1';
                    state:= s0;
            end case;
        end if;
    end process ram_ctrl;
    
    
end architecture asm;