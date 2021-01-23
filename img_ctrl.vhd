library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity img_ctrl is
    port (
        clk, rst: in std_logic;
        x_point, y_point: in std_logic_vector(7 downto 0);
        key_code: in std_logic_vector(3 downto 0);
        color_num: in std_logic_vector(7 downto 0);
        add_wr: out std_logic_vector(9 downto 0);
        img_data: out std_logic_vector(23 downto 0);
        wr_en: out std_logic
    );
end entity img_ctrl;

architecture bhv of img_ctrl is
    -- define rgb value of 32 colors
        constant color_1_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_1_g: std_logic_vector(7 downto 0):= x"ff";
        constant color_1_b: std_logic_vector(7 downto 0):= x"ff";
        constant color_2_r: std_logic_vector(7 downto 0):= x"00";
        constant color_2_g: std_logic_vector(7 downto 0):= x"00";
        constant color_2_b: std_logic_vector(7 downto 0):= x"00";
        constant color_3_r: std_logic_vector(7 downto 0):= x"aa";
        constant color_3_g: std_logic_vector(7 downto 0):= x"aa";
        constant color_3_b: std_logic_vector(7 downto 0):= x"aa";
        constant color_4_r: std_logic_vector(7 downto 0):= x"55";
        constant color_4_g: std_logic_vector(7 downto 0):= x"55";
        constant color_4_b: std_logic_vector(7 downto 0):= x"55";
        constant color_5_r: std_logic_vector(7 downto 0):= x"fe";
        constant color_5_g: std_logic_vector(7 downto 0):= x"d3";
        constant color_5_b: std_logic_vector(7 downto 0):= x"c7";
        constant color_6_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_6_g: std_logic_vector(7 downto 0):= x"c4";
        constant color_6_b: std_logic_vector(7 downto 0):= x"ce";
        constant color_7_r: std_logic_vector(7 downto 0):= x"fa";
        constant color_7_g: std_logic_vector(7 downto 0):= x"ac";
        constant color_7_b: std_logic_vector(7 downto 0):= x"8e";
        constant color_8_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_8_g: std_logic_vector(7 downto 0):= x"8b";
        constant color_8_b: std_logic_vector(7 downto 0):= x"83";
        constant color_9_r: std_logic_vector(7 downto 0):= x"f4";
        constant color_9_g: std_logic_vector(7 downto 0):= x"43";
        constant color_9_b: std_logic_vector(7 downto 0):= x"36";
        constant color_10_r: std_logic_vector(7 downto 0):= x"e9";
        constant color_10_g: std_logic_vector(7 downto 0):= x"1e";
        constant color_10_b: std_logic_vector(7 downto 0):= x"63";
        constant color_11_r: std_logic_vector(7 downto 0):= x"e2";
        constant color_11_g: std_logic_vector(7 downto 0):= x"66";
        constant color_11_b: std_logic_vector(7 downto 0):= x"9e";
        constant color_12_r: std_logic_vector(7 downto 0):= x"9c";
        constant color_12_g: std_logic_vector(7 downto 0):= x"27";
        constant color_12_b: std_logic_vector(7 downto 0):= x"b0";
        constant color_13_r: std_logic_vector(7 downto 0):= x"67";
        constant color_13_g: std_logic_vector(7 downto 0):= x"3a";
        constant color_13_b: std_logic_vector(7 downto 0):= x"b7";
        constant color_14_r: std_logic_vector(7 downto 0):= x"3f";
        constant color_14_g: std_logic_vector(7 downto 0):= x"51";
        constant color_14_b: std_logic_vector(7 downto 0):= x"b5";
        constant color_15_r: std_logic_vector(7 downto 0):= x"00";
        constant color_15_g: std_logic_vector(7 downto 0):= x"46";
        constant color_15_b: std_logic_vector(7 downto 0):= x"70";
        constant color_16_r: std_logic_vector(7 downto 0):= x"05";
        constant color_16_g: std_logic_vector(7 downto 0):= x"71";
        constant color_16_b: std_logic_vector(7 downto 0):= x"97";
        constant color_17_r: std_logic_vector(7 downto 0):= x"21";
        constant color_17_g: std_logic_vector(7 downto 0):= x"96";
        constant color_17_b: std_logic_vector(7 downto 0):= x"f3";
        constant color_18_r: std_logic_vector(7 downto 0):= x"00";
        constant color_18_g: std_logic_vector(7 downto 0):= x"bc";
        constant color_18_b: std_logic_vector(7 downto 0):= x"d4";
        constant color_19_r: std_logic_vector(7 downto 0):= x"3b";
        constant color_19_g: std_logic_vector(7 downto 0):= x"e5";
        constant color_19_b: std_logic_vector(7 downto 0):= x"db";
        constant color_20_r: std_logic_vector(7 downto 0):= x"97";
        constant color_20_g: std_logic_vector(7 downto 0):= x"fd";
        constant color_20_b: std_logic_vector(7 downto 0):= x"dc";
        constant color_21_r: std_logic_vector(7 downto 0):= x"16";
        constant color_21_g: std_logic_vector(7 downto 0):= x"73";
        constant color_21_b: std_logic_vector(7 downto 0):= x"00";
        constant color_22_r: std_logic_vector(7 downto 0):= x"37";
        constant color_22_g: std_logic_vector(7 downto 0):= x"a9";
        constant color_22_b: std_logic_vector(7 downto 0):= x"3c";
        constant color_23_r: std_logic_vector(7 downto 0):= x"89";
        constant color_23_g: std_logic_vector(7 downto 0):= x"e6";
        constant color_23_b: std_logic_vector(7 downto 0):= x"42";
        constant color_24_r: std_logic_vector(7 downto 0):= x"d7";
        constant color_24_g: std_logic_vector(7 downto 0):= x"ff";
        constant color_24_b: std_logic_vector(7 downto 0):= x"07";
        constant color_25_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_25_g: std_logic_vector(7 downto 0):= x"f6";
        constant color_25_b: std_logic_vector(7 downto 0):= x"d1";
        constant color_26_r: std_logic_vector(7 downto 0):= x"f8";
        constant color_26_g: std_logic_vector(7 downto 0):= x"cb";
        constant color_26_b: std_logic_vector(7 downto 0):= x"8c";
        constant color_27_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_27_g: std_logic_vector(7 downto 0):= x"eb";
        constant color_27_b: std_logic_vector(7 downto 0):= x"3b";
        constant color_28_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_28_g: std_logic_vector(7 downto 0):= x"c1";
        constant color_28_b: std_logic_vector(7 downto 0):= x"07";
        constant color_29_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_29_g: std_logic_vector(7 downto 0):= x"98";
        constant color_29_b: std_logic_vector(7 downto 0):= x"00";
        constant color_30_r: std_logic_vector(7 downto 0):= x"ff";
        constant color_30_g: std_logic_vector(7 downto 0):= x"57";
        constant color_30_b: std_logic_vector(7 downto 0):= x"22";
        constant color_31_r: std_logic_vector(7 downto 0):= x"b8";
        constant color_31_g: std_logic_vector(7 downto 0):= x"3f";
        constant color_31_b: std_logic_vector(7 downto 0):= x"27";
        constant color_32_r: std_logic_vector(7 downto 0):= x"79";
        constant color_32_g: std_logic_vector(7 downto 0):= x"55";
        constant color_32_b: std_logic_vector(7 downto 0):= x"48";
begin
    img_ctrl: process(clk, rst)
        variable x_tmp, y_tmp: integer range 1 to 35;
        variable add_wr_tmp: integer range 0 to 1023;
        variable color_tmp: integer range 1 to 32;
        variable color_r, color_g, color_b: std_logic_vector(7 downto 0);
    begin
        if rst = '0' then
            add_wr<= (others => '0');
            img_data<= (others => '1');
            wr_en<= '0';
            x_tmp:= 33;
            y_tmp:= 1;
            add_wr_tmp:= 0;
            color_tmp:= 1;
        elsif rising_edge(clk) then
            x_tmp:= conv_integer(x_point);
            y_tmp:= conv_integer(y_point);
            color_tmp:= conv_integer(color_num);
            if key_code= "0001" then
                if x_tmp>= 1 and x_tmp<= 32 and y_tmp>= 1 and y_tmp<= 32 then
                    add_wr_tmp:= 32* (y_tmp- 1)+ (x_tmp- 1);
                    case color_tmp is
                        when 1 =>
                            color_r:= color_1_r;
                            color_g:= color_1_g;
                            color_b:= color_1_b;
                        when 2 =>
                            color_r:= color_2_r;
                            color_g:= color_2_g;
                            color_b:= color_2_b;
                        when 3 =>
                            color_r:= color_3_r;
                            color_g:= color_3_g;
                            color_b:= color_3_b;
                        when 4 =>
                            color_r:= color_4_r;
                            color_g:= color_4_g;
                            color_b:= color_4_b;
                        when 5 =>
                            color_r:= color_5_r;
                            color_g:= color_5_g;
                            color_b:= color_5_b;
                        when 6 =>
                            color_r:= color_6_r;
                            color_g:= color_6_g;
                            color_b:= color_6_b;
                        when 7 =>
                            color_r:= color_7_r;
                            color_g:= color_7_g;
                            color_b:= color_7_b;
                        when 8 =>
                            color_r:= color_8_r;
                            color_g:= color_8_g;
                            color_b:= color_8_b;
                        when 9 =>
                            color_r:= color_9_r;
                            color_g:= color_9_g;
                            color_b:= color_9_b;
                        when 10 =>
                            color_r:= color_10_r;
                            color_g:= color_10_g;
                            color_b:= color_10_b;
                        when 11 =>
                            color_r:= color_11_r;
                            color_g:= color_11_g;
                            color_b:= color_11_b;
                        when 12 =>
                            color_r:= color_12_r;
                            color_g:= color_12_g;
                            color_b:= color_12_b;
                        when 13 =>
                            color_r:= color_13_r;
                            color_g:= color_13_g;
                            color_b:= color_13_b;
                        when 14 =>
                            color_r:= color_14_r;
                            color_g:= color_14_g;
                            color_b:= color_14_b;
                        when 15 =>
                            color_r:= color_15_r;
                            color_g:= color_15_g;
                            color_b:= color_15_b;
                        when 16 =>
                            color_r:= color_16_r;
                            color_g:= color_16_g;
                            color_b:= color_16_b;
                        when 17 =>
                            color_r:= color_17_r;
                            color_g:= color_17_g;
                            color_b:= color_17_b;
                        when 18 =>
                            color_r:= color_18_r;
                            color_g:= color_18_g;
                            color_b:= color_18_b;
                        when 19 =>
                            color_r:= color_19_r;
                            color_g:= color_19_g;
                            color_b:= color_19_b;
                        when 20 =>
                            color_r:= color_20_r;
                            color_g:= color_20_g;
                            color_b:= color_20_b;
                        when 21 =>
                            color_r:= color_21_r;
                            color_g:= color_21_g;
                            color_b:= color_21_b;
                        when 22 =>
                            color_r:= color_22_r;
                            color_g:= color_22_g;
                            color_b:= color_22_b;
                        when 23 =>
                            color_r:= color_23_r;
                            color_g:= color_23_g;
                            color_b:= color_23_b;
                        when 24 =>
                            color_r:= color_24_r;
                            color_g:= color_24_g;
                            color_b:= color_24_b;
                        when 25 =>
                            color_r:= color_25_r;
                            color_g:= color_25_g;
                            color_b:= color_25_b;
                        when 26 =>
                            color_r:= color_26_r;
                            color_g:= color_26_g;
                            color_b:= color_26_b;
                        when 27 =>
                            color_r:= color_27_r;
                            color_g:= color_27_g;
                            color_b:= color_27_b;
                        when 28 =>
                            color_r:= color_28_r;
                            color_g:= color_28_g;
                            color_b:= color_28_b;
                        when 29 =>
                            color_r:= color_29_r;
                            color_g:= color_29_g;
                            color_b:= color_29_b;
                        when 30 =>
                            color_r:= color_30_r;
                            color_g:= color_30_g;
                            color_b:= color_30_b;
                        when 31 =>
                            color_r:= color_31_r;
                            color_g:= color_31_g;
                            color_b:= color_31_b;
                        when 32 =>
                            color_r:= color_32_r;
                            color_g:= color_32_g;
                            color_b:= color_32_b;
                    end case;
                    wr_en<= '1';
                    add_wr<= conv_std_logic_vector(add_wr_tmp, add_wr'length);
                    img_data<= color_r& color_g& color_b;    
                end if;
            end if;
        end if;
    end process img_ctrl;
    
    
end architecture bhv;