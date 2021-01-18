library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ps2_decode is
    port (
        code_in_ps2: in std_logic_vector(7 downto 0);
        clk_sys, rst: in std_logic;
        key_code_out: out std_logic_vector(3 downto 0)
    );
end entity ps2_decode;
----------------
-- key_code_out    btn     - key_code_out   btn
-- 0001            space   - 0110
-- 0010            up      - 0111
-- 0011            down    - 1000
-- 0100            left    - 1001
-- 0101            right   - 1010
----------------

architecture bhv of ps2_decode is
    type state_type is (s0, s1, s2);
    signal p_state, n_state: state_type;
begin
    seq: process(clk_sys, rst)
    begin
        if rst= '0' then
            p_state<= s0;
        elsif rising_edge(clk_sys) then
            p_state<= n_state;
        end if;
    end process seq;
    com: process(p_state, code_in_ps2)
        variable code_in_tmp: std_logic_vector(7 downto 0);
    begin
        key_code_out<= "0000";
        case p_state is
            when s0 =>
                if code_in_ps2= "11110000" then
                    n_state<= s1;
                else
                    n_state<= s0;
                end if;
            when s1 =>
                code_in_tmp:= code_in_ps2;
                if code_in_tmp/= "11110000" then
                    n_state<= s2;
                else
                    n_state<= s1;
                end if;
            when s2 =>
                case code_in_tmp is
                    when "00101001" => --key space
                        key_code_out<= "0001";
                    when "01110101" => --key up
                        key_code_out<= "0010";
                    when "01101011" => --key left
                        key_code_out<= "0100";
                    when "01110010" => --key down
                        key_code_out<= "0011";
                    when "01110100" => --key right
                        key_code_out<= "0101";
                    when others =>
                        key_code_out<= "0000";
                end case;
                n_state<= s0;
        end case;
    end process com;
end architecture bhv;