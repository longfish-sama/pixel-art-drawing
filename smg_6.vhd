library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity smg_6 is
    port (
        clk,rst: in std_logic;
        data: in std_logic_vector(23 downto 0);
        dig: out std_logic_vector(7 downto 0);
        sel: out std_logic_vector(5 downto 0)
    );
end entity smg_6;

architecture asm of smg_6 is
    type state_type is (s0,s1,s2,s3,s4,s5);
    signal p_state,n_state: state_type;
    constant code_0: std_logic_vector(7 downto 0):= x"C0"; --default x"c0"
    constant code_1: std_logic_vector(7 downto 0):= x"f9"; --default x"f9"
    constant code_2: std_logic_vector(7 downto 0):= x"a4"; --default x"a4"
    constant code_3: std_logic_vector(7 downto 0):= x"b0"; --default x"b0"
    constant code_4: std_logic_vector(7 downto 0):= x"99"; --default x"99"
    constant code_5: std_logic_vector(7 downto 0):= x"92"; --default x"92"
    constant code_6: std_logic_vector(7 downto 0):= x"82"; --default x"82"
    constant code_7: std_logic_vector(7 downto 0):= x"f8"; --default x"f8"
    constant code_8: std_logic_vector(7 downto 0):= x"80"; --default x"80"
    constant code_9: std_logic_vector(7 downto 0):= x"90"; --default x"90"
    constant code_A: std_logic_vector(7 downto 0):= x"88"; --default x"88"
    constant code_B: std_logic_vector(7 downto 0):= x"83"; --default x"83"
    constant code_C: std_logic_vector(7 downto 0):= x"c6"; --default x"c6"
    constant code_D: std_logic_vector(7 downto 0):= x"a1"; --default x"a1"
    constant code_E: std_logic_vector(7 downto 0):= x"86"; --default x"86"
    constant code_F: std_logic_vector(7 downto 0):= x"8e"; --default x"8e"
    constant code_0_dot: std_logic_vector(7 downto 0):= x"40"; --default x"40"
    constant code_1_dot: std_logic_vector(7 downto 0):= x"79"; --default x"79"
    constant code_2_dot: std_logic_vector(7 downto 0):= x"24"; --default x"24"
    constant code_3_dot: std_logic_vector(7 downto 0):= x"30"; --default x"30"
    constant code_4_dot: std_logic_vector(7 downto 0):= x"19"; --default x"19"
    constant code_5_dot: std_logic_vector(7 downto 0):= x"12"; --default x"12"
    constant code_6_dot: std_logic_vector(7 downto 0):= x"02"; --default x"02"
    constant code_7_dot: std_logic_vector(7 downto 0):= x"78"; --default x"78"
    constant code_8_dot: std_logic_vector(7 downto 0):= x"00"; --default x"00"
    constant code_9_dot: std_logic_vector(7 downto 0):= x"10"; --default x"10"
    constant code_A_dot: std_logic_vector(7 downto 0):= x"08"; --default x"08"
    constant code_B_dot: std_logic_vector(7 downto 0):= x"03"; --default x"03"
    constant code_C_dot: std_logic_vector(7 downto 0):= x"46"; --default x"46"
    constant code_D_dot: std_logic_vector(7 downto 0):= x"21"; --default x"21"
    constant code_E_dot: std_logic_vector(7 downto 0):= x"06"; --default x"06"
    constant code_F_dot: std_logic_vector(7 downto 0):= x"0e"; --default x"0e"
    constant scan_freq: integer:= 240; --Hz
    constant clk_freq: integer:= 50000000; --Hz
    constant scan_cnt: integer:= clk_freq/scan_freq/6-1;
begin
    seq: process(clk, rst)
        variable scan_timer: integer;
    begin
        if rst= '0' then
            p_state<= s0;
            scan_timer:= 0;
        elsif rising_edge(clk) then
            if scan_timer=scan_cnt then
                scan_timer:= 0;
                p_state<= n_state;
            else
                scan_timer:= scan_timer+1;
            end if;
        end if;
    end process seq;
    com: process(p_state, data)
    begin
        case p_state is
            when s0 =>
                sel<="011111";
                n_state<=s1;
                case data(3 downto 0) is
                    when "0000" => dig<= code_0_dot;
                    when "0001" => dig<= code_1_dot;
                    when "0010" => dig<= code_2_dot;
                    when "0011" => dig<= code_3_dot;
                    when "0100" => dig<= code_4_dot;
                    when "0101" => dig<= code_5_dot;
                    when "0110" => dig<= code_6_dot;
                    when "0111" => dig<= code_7_dot;
                    when "1000" => dig<= code_8_dot;
                    when "1001" => dig<= code_9_dot;
                    when "1010" => dig<= code_A_dot;
                    when "1011" => dig<= code_B_dot;
                    when "1100" => dig<= code_C_dot;
                    when "1101" => dig<= code_D_dot;
                    when "1110" => dig<= code_E_dot;
                    when "1111" => dig<= code_F_dot;
                end case;
            when s1 =>
                sel<="101111";
                n_state<=s2;
                case data(7 downto 4) is
                    when "0000" => dig<= code_0;
                    when "0001" => dig<= code_1;
                    when "0010" => dig<= code_2;
                    when "0011" => dig<= code_3;
                    when "0100" => dig<= code_4;
                    when "0101" => dig<= code_5;
                    when "0110" => dig<= code_6;
                    when "0111" => dig<= code_7;
                    when "1000" => dig<= code_8;
                    when "1001" => dig<= code_9;
                    when "1010" => dig<= code_A;
                    when "1011" => dig<= code_B;
                    when "1100" => dig<= code_C;
                    when "1101" => dig<= code_D;
                    when "1110" => dig<= code_E;
                    when "1111" => dig<= code_F;
                end case;
            when s2 =>
                sel<="110111";
                n_state<=s3;
                case data(11 downto 8) is
                    when "0000" => dig<= code_0_dot;
                    when "0001" => dig<= code_1_dot;
                    when "0010" => dig<= code_2_dot;
                    when "0011" => dig<= code_3_dot;
                    when "0100" => dig<= code_4_dot;
                    when "0101" => dig<= code_5_dot;
                    when "0110" => dig<= code_6_dot;
                    when "0111" => dig<= code_7_dot;
                    when "1000" => dig<= code_8_dot;
                    when "1001" => dig<= code_9_dot;
                    when "1010" => dig<= code_A_dot;
                    when "1011" => dig<= code_B_dot;
                    when "1100" => dig<= code_C_dot;
                    when "1101" => dig<= code_D_dot;
                    when "1110" => dig<= code_E_dot;
                    when "1111" => dig<= code_F_dot;
                end case;
            when s3 =>
                sel<="111011";
                n_state<=s4;
                case data(15 downto 12) is
                    when "0000" => dig<= code_0;
                    when "0001" => dig<= code_1;
                    when "0010" => dig<= code_2;
                    when "0011" => dig<= code_3;
                    when "0100" => dig<= code_4;
                    when "0101" => dig<= code_5;
                    when "0110" => dig<= code_6;
                    when "0111" => dig<= code_7;
                    when "1000" => dig<= code_8;
                    when "1001" => dig<= code_9;
                    when "1010" => dig<= code_A;
                    when "1011" => dig<= code_B;
                    when "1100" => dig<= code_C;
                    when "1101" => dig<= code_D;
                    when "1110" => dig<= code_E;
                    when "1111" => dig<= code_F;
                end case;
            when s4 =>
                sel<="111101";
                n_state<=s5;
                case data(19 downto 16) is
                    when "0000" => dig<= code_0_dot;
                    when "0001" => dig<= code_1_dot;
                    when "0010" => dig<= code_2_dot;
                    when "0011" => dig<= code_3_dot;
                    when "0100" => dig<= code_4_dot;
                    when "0101" => dig<= code_5_dot;
                    when "0110" => dig<= code_6_dot;
                    when "0111" => dig<= code_7_dot;
                    when "1000" => dig<= code_8_dot;
                    when "1001" => dig<= code_9_dot;
                    when "1010" => dig<= code_A_dot;
                    when "1011" => dig<= code_B_dot;
                    when "1100" => dig<= code_C_dot;
                    when "1101" => dig<= code_D_dot;
                    when "1110" => dig<= code_E_dot;
                    when "1111" => dig<= code_F_dot;
                end case;
            when s5 =>                    
                sel<="111110";
                n_state<=s0;
                case data(23 downto 20) is
                    when "0000" => dig<= code_0;
                    when "0001" => dig<= code_1;
                    when "0010" => dig<= code_2;
                    when "0011" => dig<= code_3;
                    when "0100" => dig<= code_4;
                    when "0101" => dig<= code_5;
                    when "0110" => dig<= code_6;
                    when "0111" => dig<= code_7;
                    when "1000" => dig<= code_8;
                    when "1001" => dig<= code_9;
                    when "1010" => dig<= code_A;
                    when "1011" => dig<= code_B;
                    when "1100" => dig<= code_C;
                    when "1101" => dig<= code_D;
                    when "1110" => dig<= code_E;
                    when "1111" => dig<= code_F;
                end case;
        end case;
    end process com;
end architecture asm;