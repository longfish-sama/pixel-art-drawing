library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ps2_decode is
    port (
        code_in_ps2: in std_logic_vector(7 downto 0);
        clk_sys, rst: in std_logic;
        key_code_out: out std_logic_vector(3 downto 0);
        ctrl: out std_logic
    );
end entity ps2_decode;
--LUT-----------
-- |key_code_out    btn    |key_code_out    btn |key_code_out   btn
-- |0001           -space  |0110           -W   |1011          -ctrl+D
-- |0010           -up     |0111           -A   |1100          -ctrl+S
-- |0011           -down   |1000           -S   |1101          -ctrl+O
-- |0100           -left   |1001           -D   |1110          -E
-- |0101           -right  |1010           -G   |1111          -B
----------------

architecture bhv of ps2_decode is
begin
    decode: process(clk_sys, rst)
        variable flag_end: std_logic;
        variable flag_ctrl: std_logic;
        variable code_in_tmp: std_logic_vector(7 downto 0);
    begin
        if rst = '0' then
            flag_end:= '0';
            flag_ctrl:= '0';
            code_in_tmp:= "00000000";
            key_code_out<= "0000";
        elsif rising_edge(clk_sys) then
            code_in_tmp:= code_in_ps2;
            if code_in_tmp= "11110000" then
                flag_end:= '1';
            elsif flag_end= '1' and code_in_tmp= "00010100" then
                flag_ctrl:= not flag_ctrl;
                flag_end:= '0';
            elsif flag_end= '1' and flag_ctrl= '1' then
                case code_in_tmp is
                    when "00100011" => --ctrl+D
                        key_code_out<= "1011";
                    when "00011011" => --ctrl+S
                        key_code_out<= "1100";
                    when "01000100" => --ctrl+O
                        key_code_out<= "1101";
                    when others =>
                        key_code_out<= "0000";
                end case;
                flag_ctrl:= '0';
                flag_end:= '0';
            elsif flag_end= '1' then
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
                    when "00011101" => --key W
                        key_code_out<= "0110";
                    when "00011100" => --key A
                        key_code_out<= "0111";
                    when "00011011" => --key S
                        key_code_out<= "1000";
                    when "00100011" => --key D
                        key_code_out<= "1001";
                    when "00110100" => --key G
                        key_code_out<= "1010";
                    when "00100100" => --key E
                        key_code_out<= "1110";
                    when "00110010" => --key B
                        key_code_out<= "1111";
                    when others =>
                        key_code_out<= "0000";
                end case;
                flag_ctrl:= '0';
                flag_end:= '0';
            else
                flag_end:= '0';
                key_code_out<= "0000";
            end if;
            ctrl<= flag_ctrl;
        end if;
    end process decode;
end architecture bhv;