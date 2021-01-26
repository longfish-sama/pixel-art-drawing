library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;

entity pointer is
    port (
        clk_sys, rst: in std_logic;
        key_code: in std_logic_vector(3 downto 0);
        x_point, y_point: out std_logic_vector(7 downto 0)
    );
end entity pointer;

architecture bhv of pointer is
--    type state_type is (s0, s1);
--    signal p_state, n_state: state_type;
begin
    point: process(clk_sys, rst, key_code)
        variable x_tmp, y_tmp: integer range 0 to 35;
        variable key_code_tmp: std_logic_vector(3 downto 0);
    begin
        if rst = '0' then
            x_tmp:= 33;
            y_tmp:= 1;
            x_point<= conv_std_logic_vector(33, x_point'length);
            y_point<= conv_std_logic_vector(1, y_point'length);
        elsif rising_edge(clk_sys) then
            key_code_tmp:= key_code;
            case key_code_tmp is
                when "0010" => -- key up
                    if y_tmp>= 2 then
                        y_tmp:= y_tmp- 1;
                    end if;
                when "0011" => -- key down
                    if ((x_tmp>= 1 and x_tmp<= 32 and y_tmp<= 31) or
                        (x_tmp>= 33 and x_tmp<= 34 and y_tmp<= 15)) then
                        y_tmp:= y_tmp+ 1;
                    end if;
                when "0100" => -- key left
                    if (x_tmp>= 2 and x_tmp<= 32) or x_tmp=34 then
                        x_tmp:= x_tmp- 1;
                    elsif x_tmp= 33 then
                        x_tmp:= 32;
                        y_tmp:= y_tmp*2- 1;
                    end if;
                when "0101" => -- key right
                    if x_tmp= 33 or x_tmp<= 31 then
                        x_tmp:= x_tmp+ 1;
                    elsif x_tmp= 32 then
                        x_tmp:= 33;
                        y_tmp:= (y_tmp+ 1)/2;
                    end if;
                when "0110" => --W, up*5
                    if y_tmp>= 6 then
                        y_tmp:= y_tmp- 5;
                    elsif y_tmp<= 5 then
                        y_tmp:= 1;
                    end if;
                when "0111" => --A, left*5
                    if x_tmp>= 6 and x_tmp<= 32 then
                        x_tmp:= x_tmp- 5;
                    elsif x_tmp<= 5 then
                        x_tmp:= 1;
                    elsif x_tmp>= 33 and x_tmp<= 34 then
                        x_tmp:= 32;
                        y_tmp:= y_tmp*2- 1;
                    end if;
                when "1000" => --S, down*5
                    if ((x_tmp>= 1 and x_tmp<= 32 and y_tmp<= 27) or
                        (x_tmp>= 33 and x_tmp<= 34 and y_tmp<= 11)) then
                        y_tmp:= y_tmp+ 5;
                    elsif x_tmp>= 1 and x_tmp<= 32 and y_tmp>= 28 then
                        y_tmp:= 32;
                    elsif x_tmp>= 33 and x_tmp<= 34 and y_tmp>= 12 then
                        y_tmp:= 16;
                    end if;
                when "1001" => --D, right*5
                    if x_tmp>= 1 and x_tmp<= 27 then
                        x_tmp:= x_tmp+ 5;
                    elsif x_tmp>= 28 and x_tmp<= 32 then
                        x_tmp:= 33;
                        y_tmp:= (y_tmp+ 1)/2;
                    elsif x_tmp>= 33 then
                        x_tmp:= 34;
                    end if;
                when others => null;
            end case;
            x_point<= conv_std_logic_vector(x_tmp, x_point'length);
            y_point<= conv_std_logic_vector(y_tmp, y_point'length);
        end if;
    end process point;
end architecture bhv;