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

architecture rtl of pointer is
--    type state_type is (s0, s1);
--    signal p_state, n_state: state_type;
begin
    point: process(clk_sys, rst)
        variable x_tmp, y_tmp: integer range 0 to 70;
        --variable key_code_tmp: std_logic_vector(3 downto 0);
    begin
        if rst = '0' then
            x_tmp:= 65;
            y_tmp:= 1;
            x_point<= conv_std_logic_vector(65, x_point'length);
            y_point<= conv_std_logic_vector(1, y_point'length);
        elsif rising_edge(clk_sys) then
            --key_code_tmp:= key_code;
            if key_code/= "0000" then
                case key_code is
                    when "0010" => -- key up
                        if y_tmp>= 2 then
                            y_tmp:= y_tmp- 1;
                        end if;
                    when "0011" => -- key down
                        if x_tmp>= 1 and x_tmp<= 64 and y_tmp<= 63 then
                            y_tmp:= y_tmp+ 1;
                        elsif x_tmp>= 65 and x_tmp<= 66 and y_tmp<= 15 then
                            y_tmp:= y_tmp+ 1;
                        end if;
                    when "0100" => -- key left
                        if x_tmp>= 2 then
                            x_tmp:= x_tmp- 1;
                        end if;
                    when "0101" => -- key right
                        if y_tmp>= 1 and y_tmp<= 16 and x_tmp<= 65 then
                            x_tmp:= x_tmp+ 1;
                        elsif y_tmp>= 17 and y_tmp<= 64 and x_tmp<= 63 then
                            x_tmp:= x_tmp+ 1;
                        elsif y_tmp>= 17 and y_tmp<= 64 and x_tmp= 64 then
                            y_tmp:= 16;
                            x_tmp:= x_tmp+ 1;
                        end if;
                    when others => null;
                end case;
                x_point<= conv_std_logic_vector(x_tmp, x_point'length);
                y_point<= conv_std_logic_vector(y_tmp, y_point'length);
            end if;
        end if;
    end process point;
--    seq: process(clk_sys, rst)
--    begin
--        if rst = '0' then
--            p_state<= s0;
--        elsif rising_edge(clk_sys) then
--            p_state<= n_state;
--        end if;
--    end process seq;
--    
--    com: process(p_state, key_code, rst)
--        variable x_tmp, y_tmp: integer range 0 to 70;
--        variable key_code_tmp: std_logic_vector(3 downto 0);
--    begin
--        if rst= '0' then
--            x_tmp:= 65;
--            y_tmp:= 1;
--            x_point<= conv_std_logic_vector(65, x_point'length);
--            y_point<= conv_std_logic_vector(1, y_point'length);
--        else
--            case p_state is
--                when s0 =>
--                    if key_code/= "0000" then
--                        key_code_tmp:= key_code;
--                        n_state<= s1;
--                    else
--                        n_state<= s0;
--                    end if;
--                when s1 =>
--                    case key_code_tmp is
--                        when "0010" => -- key up
--                            if y_tmp>= 2 then
--                                y_tmp:= y_tmp- 1;
--                            end if;
--                        when "0011" => -- key down
--                            if x_tmp>= 1 and x_tmp<= 64 and y_tmp<= 63 then
--                                y_tmp:= y_tmp+ 1;
--                            elsif x_tmp>= 65 and x_tmp<= 66 and y_tmp<= 15 then
--                                y_tmp:= y_tmp+ 1;
--                            end if;
--                        when "0100" => -- key left
--                            if x_tmp>= 2 then
--                                x_tmp:= x_tmp- 1;
--                            end if;
--                        when "0101" => -- key right
--                            if y_tmp>= 1 and y_tmp<= 16 and x_tmp<= 65 then
--                                x_tmp:= x_tmp+ 1;
--                            elsif y_tmp>= 17 and y_tmp<= 64 and x_tmp<= 63 then
--                                x_tmp:= x_tmp+ 1;
--                            elsif y_tmp>= 17 and y_tmp<= 64 and x_tmp= 64 then
--                                y_tmp:= 16;
--                                x_tmp:= x_tmp+ 1;
--                            end if;
--                        when others => null;
--                    end case;
--                    x_point<= conv_std_logic_vector(x_tmp, x_point'length);
--                    y_point<= conv_std_logic_vector(y_tmp, y_point'length);
--                    n_state<= s0;
--            end case;
--        end if;
--    end process com;
    
end architecture rtl;