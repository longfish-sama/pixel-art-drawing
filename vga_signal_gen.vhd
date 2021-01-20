library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity vga_signal_gen is
    port (
        clk_pix, rst_n: in std_logic;
        x_point, y_point, color_num: in std_logic_vector(7 downto 0);
        hor_sync, ver_sync, de: out std_logic;
        vga_r, vga_g, vga_b: out std_logic_vector(7 downto 0);
        img_ram_add: out std_logic_vector(7 downto 0)
    );
end entity vga_signal_gen;

architecture bhv of vga_signal_gen is
    signal hor_sync_tmp, ver_sync_tmp: std_logic; -- horizontal& vertical sync register
    signal hor_sync_delay_tmp, ver_sync_delay_tmp: std_logic; -- delay 1 clock of sync register
    signal hor_cnt: integer range 0 to 3000; -- horizontal counter
    signal ver_cnt: integer range 0 to 2000; -- vertical counter
    signal x_cur_pos: integer range 0 to 3000; -- video x position
    signal y_cur_pos: integer range 0 to 2000; -- video y position
    signal vga_r_tmp, vga_g_tmp, vga_b_tmp: std_logic_vector(7 downto 0); -- color data register
    signal h_active_flag, v_active_flag: std_logic; -- horizontal& vertical video active flag
    signal video_active_flag: std_logic; -- video active (when horizontal active and vertical active)
    signal video_active_flag_delay: std_logic; -- delay 1 clock of video active flag
-- 800*600 at 60fps, clk_pix= 40MHz
    constant h_active: integer:= 800; -- horizontal active time (pixels)
    constant h_blank_fproch: integer:= 40; -- horizontal front porch (pixels)
    constant h_blank_sync: integer:= 128; -- horizontal sync time(pixels)
    constant h_blank_bproch: integer:= 88; -- horizontal back porch (pixels)
    constant v_active: integer:= 600; -- vertical active Time (lines)
    constant v_blank_fproch: integer:= 1; -- vertical front porch (lines)
    constant v_blank_sync: integer:= 4; -- vertical sync time (lines)
    constant v_blank_bproch: integer:= 23; -- vertical back porch (lines)
    constant h_total: integer:= h_active+ h_blank_fproch+ h_blank_sync+ h_blank_bproch; -- horizontal total time (pixels)
    constant v_total: integer:= v_active+ v_blank_fproch+ v_blank_sync+ v_blank_bproch; -- vertical total time (lines)
    constant line_w: integer:= 0;
    constant dot_w: integer:= 1;
    constant selector_w: integer:= 3;
-- 800*600 gird locs (calculated in Excel)
    constant x1: integer:= 125; -- drawing area locs
    constant x2: integer:= 131;
    constant x3: integer:= 138;
    constant x4: integer:= 144;
    constant x5: integer:= 150;
    constant x6: integer:= 156;
    constant x7: integer:= 163;
    constant x8: integer:= 169;
    constant x9: integer:= 175;
    constant x10: integer:= 181;
    constant x11: integer:= 188;
    constant x12: integer:= 194;
    constant x13: integer:= 200;
    constant x14: integer:= 206;
    constant x15: integer:= 213;
    constant x16: integer:= 219;
    constant x17: integer:= 225;
    constant x18: integer:= 231;
    constant x19: integer:= 238;
    constant x20: integer:= 244;
    constant x21: integer:= 250;
    constant x22: integer:= 256;
    constant x23: integer:= 263;
    constant x24: integer:= 269;
    constant x25: integer:= 275;
    constant x26: integer:= 281;
    constant x27: integer:= 288;
    constant x28: integer:= 294;
    constant x29: integer:= 300;
    constant x30: integer:= 306;
    constant x31: integer:= 313;
    constant x32: integer:= 319;
    constant x33: integer:= 325;
    constant x34: integer:= 331;
    constant x35: integer:= 338;
    constant x36: integer:= 344;
    constant x37: integer:= 350;
    constant x38: integer:= 356;
    constant x39: integer:= 363;
    constant x40: integer:= 369;
    constant x41: integer:= 375;
    constant x42: integer:= 381;
    constant x43: integer:= 388;
    constant x44: integer:= 394;
    constant x45: integer:= 400;
    constant x46: integer:= 406;
    constant x47: integer:= 413;
    constant x48: integer:= 419;
    constant x49: integer:= 425;
    constant x50: integer:= 431;
    constant x51: integer:= 438;
    constant x52: integer:= 444;
    constant x53: integer:= 450;
    constant x54: integer:= 456;
    constant x55: integer:= 463;
    constant x56: integer:= 469;
    constant x57: integer:= 475;
    constant x58: integer:= 481;
    constant x59: integer:= 488;
    constant x60: integer:= 494;
    constant x61: integer:= 500;
    constant x62: integer:= 506;
    constant x63: integer:= 513;
    constant x64: integer:= 519;
    constant x1_color: integer:= 608; -- color area locs
    constant x2_color: integer:= 633;
    constant y1: integer:= 28; -- drawing area locs
    constant y2: integer:= 36;
    constant y3: integer:= 44;
    constant y4: integer:= 53;
    constant y5: integer:= 61;
    constant y6: integer:= 69;
    constant y7: integer:= 78;
    constant y8: integer:= 86;
    constant y9: integer:= 94;
    constant y10: integer:= 103;
    constant y11: integer:= 111;
    constant y12: integer:= 119;
    constant y13: integer:= 128;
    constant y14: integer:= 136;
    constant y15: integer:= 144;
    constant y16: integer:= 153;
    constant y17: integer:= 161;
    constant y18: integer:= 169;
    constant y19: integer:= 178;
    constant y20: integer:= 186;
    constant y21: integer:= 194;
    constant y22: integer:= 203;
    constant y23: integer:= 211;
    constant y24: integer:= 219;
    constant y25: integer:= 228;
    constant y26: integer:= 236;
    constant y27: integer:= 244;
    constant y28: integer:= 253;
    constant y29: integer:= 261;
    constant y30: integer:= 269;
    constant y31: integer:= 278;
    constant y32: integer:= 286;
    constant y33: integer:= 294;
    constant y34: integer:= 303;
    constant y35: integer:= 311;
    constant y36: integer:= 319;
    constant y37: integer:= 328;
    constant y38: integer:= 336;
    constant y39: integer:= 344;
    constant y40: integer:= 353;
    constant y41: integer:= 361;
    constant y42: integer:= 369;
    constant y43: integer:= 378;
    constant y44: integer:= 386;
    constant y45: integer:= 394;
    constant y46: integer:= 403;
    constant y47: integer:= 411;
    constant y48: integer:= 419;
    constant y49: integer:= 428;
    constant y50: integer:= 436;
    constant y51: integer:= 444;
    constant y52: integer:= 453;
    constant y53: integer:= 461;
    constant y54: integer:= 469;
    constant y55: integer:= 478;
    constant y56: integer:= 486;
    constant y57: integer:= 494;
    constant y58: integer:= 503;
    constant y59: integer:= 511;
    constant y60: integer:= 519;
    constant y61: integer:= 528;
    constant y62: integer:= 536;
    constant y63: integer:= 544;
    constant y64: integer:= 553;
    constant y1_color: integer:= 28; -- color area locs
    constant y2_color: integer:= 61;
    constant y3_color: integer:= 94;
    constant y4_color: integer:= 128;
    constant y5_color: integer:= 161;
    constant y6_color: integer:= 194;
    constant y7_color: integer:= 228;
    constant y8_color: integer:= 261;
    constant y9_color: integer:= 294;
    constant y10_color: integer:= 328;
    constant y11_color: integer:= 361;
    constant y12_color: integer:= 394;
    constant y13_color: integer:= 428;
    constant y14_color: integer:= 461;
    constant y15_color: integer:= 494;
    constant y16_color: integer:= 528;
    constant x_color_width: integer:= 17;
    constant y_color_width: integer:= 22;
-- define rgb value of colors
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
    constant color_back_r: std_logic_vector(7 downto 0):= x"f0";
    constant color_back_g: std_logic_vector(7 downto 0):= x"f0";
    constant color_back_b: std_logic_vector(7 downto 0):= x"f0";
    constant color_sel_r: std_logic_vector(7 downto 0):= x"ff";
    constant color_sel_g: std_logic_vector(7 downto 0):= x"00";
    constant color_sel_b: std_logic_vector(7 downto 0):= x"00";

begin
    hor_sync<= hor_sync_delay_tmp;
    ver_sync<= ver_sync_delay_tmp;
    video_active_flag<= h_active_flag and v_active_flag;
    de<= video_active_flag_delay;
    vga_r<= vga_r_tmp;
    vga_g<= vga_g_tmp;
    vga_b<= vga_b_tmp;

    sync_active_flag_gen: process(clk_pix, rst_n)
    -- gen hor_sync, ver_sync and de signal
    begin
        if rst_n= '0' then
            hor_sync_delay_tmp<= '0';
            ver_sync_delay_tmp<= '0';
            video_active_flag_delay<= '0';
        elsif rising_edge(clk_pix) then
            hor_sync_delay_tmp<= hor_sync_tmp;
            ver_sync_delay_tmp<= ver_sync_tmp;
            video_active_flag_delay<= video_active_flag;
        end if;
    end process sync_active_flag_gen;

    hor_cnt_gen: process(clk_pix, rst_n)
    -- horizontal counter (maxcnt= h_total- 1)
    begin
        if rst_n = '0' then
            hor_cnt<= 0;
        elsif rising_edge(clk_pix) then
            if hor_cnt= h_total- 1 then
                hor_cnt<= 0;
            else
                hor_cnt<= hor_cnt+ 1;
            end if;
        end if;
    end process hor_cnt_gen;

    x_cur_pos_gen: process(clk_pix, rst_n)
    -- x position of active video
    begin
        if rst_n = '0' then
            x_cur_pos<= 0;
        elsif rising_edge(clk_pix) then
            if hor_cnt>= h_blank_fproch+ h_blank_sync+ h_blank_bproch- 1 then -- when video active
                x_cur_pos<= hor_cnt- (h_blank_fproch+ h_blank_sync+ h_blank_bproch- 1);
            else
                x_cur_pos<= x_cur_pos;
            end if;
        end if;
    end process x_cur_pos_gen;

    y_cur_pos_gen: process(clk_pix, rst_n)
    -- y position of active video
    begin
        if rst_n = '0' then
            y_cur_pos<= 0;
        elsif rising_edge(clk_pix) then
            if ver_cnt>= v_blank_fproch+ v_blank_sync+ v_blank_bproch- 1 then -- when video active
                y_cur_pos<= ver_cnt- (v_blank_fproch+ v_blank_sync+ v_blank_bproch- 1);
            else
                y_cur_pos<= y_cur_pos;
            end if;
        end if;
    end process y_cur_pos_gen;

    ver_cnt_gen: process(clk_pix, rst_n)
    -- vertical counter (maxcnt= v_total- 1)
    begin
        if rst_n = '0' then
            ver_cnt<= 0;
        elsif rising_edge(clk_pix) then
            if hor_cnt= h_blank_fproch- 1 then -- at hor_sync time
                if ver_cnt= v_total- 1 then
                    ver_cnt<= 0;
                else
                    ver_cnt<= ver_cnt+ 1;
                end if;
            else
                ver_cnt<= ver_cnt;
            end if;
        end if;
    end process ver_cnt_gen;

    hor_sync_gen: process(clk_pix, rst_n)
    -- horizontal sync
    begin
        if rst_n = '0' then
            hor_sync_tmp<= '0';
        elsif rising_edge(clk_pix) then
            if hor_cnt= h_blank_fproch- 1 then
                hor_sync_tmp<= '1'; -- horizontal sync start
            elsif hor_cnt= h_blank_fproch+ h_blank_sync- 1 then
                hor_sync_tmp<= not hor_sync_tmp; -- horizontal sync end
            else
                hor_sync_tmp<= hor_sync_tmp;
            end if;
        end if;
    end process hor_sync_gen;

    h_active_flag_gen: process(clk_pix, rst_n)
    -- horizontal active flag
    begin
        if rst_n = '0' then
            h_active_flag<= '0';
        elsif rising_edge(clk_pix) then
            if hor_cnt= h_blank_fproch+ h_blank_sync+ h_blank_bproch- 1 then
                h_active_flag<= '1'; -- horizontal active start
            elsif hor_cnt= h_total- 1 then
                h_active_flag<= '0'; -- horizontal active end
            else
                h_active_flag<= h_active_flag;
            end if;
        end if;
    end process h_active_flag_gen;

    ver_sync_gen: process(clk_pix, rst_n)
    -- vertical sync
    begin
        if rst_n = '0' then
            ver_sync_tmp<= '0';
        elsif rising_edge(clk_pix) then
            if (ver_cnt= v_blank_fproch- 1) and (hor_cnt= h_blank_fproch- 1) then
                ver_sync_tmp<= '1'; -- vertical sync start
            elsif (ver_cnt= v_blank_fproch+ v_blank_sync- 1) and (hor_cnt= h_blank_fproch- 1) then
                ver_sync_tmp<= not ver_sync_tmp; -- vertical sync end
            else
                ver_sync_tmp<= ver_sync_tmp;
            end if;
        end if;
    end process ver_sync_gen;

    v_active_flag_gen: process(clk_pix, rst_n)
    -- vertical active flag
    begin
        if rst_n = '0' then
            v_active_flag<= '0';
        elsif rising_edge(clk_pix) then
            if (ver_cnt= v_blank_fproch+ v_blank_sync+ v_blank_bproch- 1) and (hor_cnt= h_blank_fproch- 1) then
                v_active_flag<= '1'; -- vertical active start
            elsif (ver_cnt= v_total- 1) and (hor_cnt= h_blank_fproch- 1) then
                v_active_flag<= '0'; -- vertical active end
            else
                v_active_flag<= v_active_flag;
            end if;
        end if;
    end process v_active_flag_gen;

    img_gen: process(clk_pix, rst_n)
        variable x_tmp, y_tmp: integer range 1 to 70;
        variable color_tmp: integer range 1 to 32;
        variable color_tmp_row: integer range 0 to 15;
        variable color_tmp_col: integer range 0 to 1;
    begin
        if rst_n = '0' then
            vga_r_tmp<= x"00";
            vga_g_tmp<= x"00";
            vga_b_tmp<= x"00";
            x_tmp:= 65;
            y_tmp:= 1;
            color_tmp:= 1;
            color_tmp_row:= 0;
            color_tmp_col:= 0;
        elsif rising_edge(clk_pix) then
            if video_active_flag= '1' then
                x_tmp:= conv_integer(x_point);
                y_tmp:= conv_integer(y_point);
                color_tmp:= conv_integer(color_num);
                case color_tmp is
                    when 1 =>
                        color_tmp_row:= 0;
                        color_tmp_col:= 0;
                    when 2 =>
                        color_tmp_row:= 0;
                        color_tmp_col:= 1;
                    when 3 =>
                        color_tmp_row:= 1;
                        color_tmp_col:= 0;
                    when 4 =>
                        color_tmp_row:= 1;
                        color_tmp_col:= 1;
                    when 5 =>
                        color_tmp_row:= 2;
                        color_tmp_col:= 0;
                    when 6 =>
                        color_tmp_row:= 2;
                        color_tmp_col:= 1;
                    when 7 =>
                        color_tmp_row:= 3;
                        color_tmp_col:= 0;
                    when 8 =>
                        color_tmp_row:= 3;
                        color_tmp_col:= 1;
                    when 9 =>
                        color_tmp_row:= 4;
                        color_tmp_col:= 0;
                    when 10 =>
                        color_tmp_row:= 4;
                        color_tmp_col:= 1;
                    when 11 =>
                        color_tmp_row:= 5;
                        color_tmp_col:= 0;
                    when 12 =>
                        color_tmp_row:= 5;
                        color_tmp_col:= 1;
                    when 13 =>
                        color_tmp_row:= 6;
                        color_tmp_col:= 0;
                    when 14 =>
                        color_tmp_row:= 6;
                        color_tmp_col:= 1;
                    when 15 =>
                        color_tmp_row:= 7;
                        color_tmp_col:= 0;
                    when 16 =>
                        color_tmp_row:= 7;
                        color_tmp_col:= 1;
                    when 17 =>
                        color_tmp_row:= 8;
                        color_tmp_col:= 0;
                    when 18 =>
                        color_tmp_row:= 8;
                        color_tmp_col:= 1;
                    when 19 =>
                        color_tmp_row:= 9;
                        color_tmp_col:= 0;
                    when 20 =>
                        color_tmp_row:= 9;
                        color_tmp_col:= 1;
                    when 21 =>
                        color_tmp_row:= 10;
                        color_tmp_col:= 0;
                    when 22 =>
                        color_tmp_row:= 10;
                        color_tmp_col:= 1;
                    when 23 =>
                        color_tmp_row:= 11;
                        color_tmp_col:= 0;
                    when 24 =>
                        color_tmp_row:= 11;
                        color_tmp_col:= 1;
                    when 25 =>
                        color_tmp_row:= 12;
                        color_tmp_col:= 0;
                    when 26 =>
                        color_tmp_row:= 12;
                        color_tmp_col:= 1;
                    when 27 =>
                        color_tmp_row:= 13;
                        color_tmp_col:= 0;
                    when 28 =>
                        color_tmp_row:= 13;
                        color_tmp_col:= 1;
                    when 29 =>
                        color_tmp_row:= 14;
                        color_tmp_col:= 0;
                    when 30 =>
                        color_tmp_row:= 14;
                        color_tmp_col:= 1;
                    when 31 =>
                        color_tmp_row:= 15;
                        color_tmp_col:= 0;
                    when 32 =>
                        color_tmp_row:= 15;
                        color_tmp_col:= 1;
                end case;
                if      -- drawing area pointer
                        (x_tmp<= 64 and y_tmp<= 64 and
                        (x_cur_pos>= h_active*39/256+ x_tmp*h_active/128- dot_w) and (y_cur_pos>= v_active*17/432+ y_tmp*v_active/72- dot_w) and
                        (x_cur_pos<= h_active*39/256+ x_tmp*h_active/128+ dot_w) and (y_cur_pos<= v_active*17/432+ y_tmp*v_active/72+ dot_w)) or
                        -- color area pointer
                        (x_tmp> 64 and y_tmp<= 16 and
                        (x_cur_pos>= x_tmp*h_active/32- h_active*121/96- dot_w) and (y_cur_pos>= v_active/108+ y_tmp*v_active/18- dot_w) and
                        (x_cur_pos<= x_tmp*h_active/32- h_active*121/96+ dot_w) and (y_cur_pos<= v_active/108+ y_tmp*v_active/18- dot_w)) or
                        -- color area selectors
                        (color_tmp>= 1 and color_tmp<= 32 and
                        (x_cur_pos>= h_active*73/96+ color_tmp_col*h_active/32) and (x_cur_pos< h_active*25/32+ color_tmp_col*h_active/32) and
                        (y_cur_pos>= v_active/12+ color_tmp_row*v_active/18- selector_w) and (y_cur_pos< v_active/12+ color_tmp_row*v_active/18)) then
                    vga_r_tmp<= color_sel_r;
                    vga_g_tmp<= color_sel_g;
                    vga_b_tmp<= color_sel_b;
                elsif   -- drawing area ver line
                        (((x_cur_pos>= x1 and x_cur_pos<= x1+ line_w) or (x_cur_pos>= x2 and x_cur_pos<= x2+ line_w) or
                        (x_cur_pos>= x3 and x_cur_pos<= x3+ line_w) or (x_cur_pos>= x4 and x_cur_pos<= x4+ line_w) or
                        (x_cur_pos>= x5 and x_cur_pos<= x5+ line_w) or (x_cur_pos>= x6 and x_cur_pos<= x6+ line_w) or
                        (x_cur_pos>= x7 and x_cur_pos<= x7+ line_w) or (x_cur_pos>= x8 and x_cur_pos<= x8+ line_w) or
                        (x_cur_pos>= x9 and x_cur_pos<= x9+ line_w) or (x_cur_pos>= x10 and x_cur_pos<= x10+ line_w) or
                        (x_cur_pos>= x11 and x_cur_pos<= x11+ line_w) or (x_cur_pos>= x12 and x_cur_pos<= x12+ line_w) or
                        (x_cur_pos>= x13 and x_cur_pos<= x13+ line_w) or (x_cur_pos>= x14 and x_cur_pos<= x14+ line_w) or
                        (x_cur_pos>= x15 and x_cur_pos<= x15+ line_w) or (x_cur_pos>= x16 and x_cur_pos<= x16+ line_w) or
                        (x_cur_pos>= x17 and x_cur_pos<= x17+ line_w) or (x_cur_pos>= x18 and x_cur_pos<= x18+ line_w) or
                        (x_cur_pos>= x19 and x_cur_pos<= x19+ line_w) or (x_cur_pos>= x20 and x_cur_pos<= x20+ line_w) or
                        (x_cur_pos>= x21 and x_cur_pos<= x21+ line_w) or (x_cur_pos>= x22 and x_cur_pos<= x22+ line_w) or
                        (x_cur_pos>= x23 and x_cur_pos<= x23+ line_w) or (x_cur_pos>= x24 and x_cur_pos<= x24+ line_w) or
                        (x_cur_pos>= x25 and x_cur_pos<= x25+ line_w) or (x_cur_pos>= x26 and x_cur_pos<= x26+ line_w) or
                        (x_cur_pos>= x27 and x_cur_pos<= x27+ line_w) or (x_cur_pos>= x28 and x_cur_pos<= x28+ line_w) or
                        (x_cur_pos>= x29 and x_cur_pos<= x29+ line_w) or (x_cur_pos>= x30 and x_cur_pos<= x30+ line_w) or
                        (x_cur_pos>= x31 and x_cur_pos<= x31+ line_w) or (x_cur_pos>= x32 and x_cur_pos<= x32+ line_w) or
                        (x_cur_pos>= x33 and x_cur_pos<= x33+ line_w) or (x_cur_pos>= x34 and x_cur_pos<= x34+ line_w) or
                        (x_cur_pos>= x35 and x_cur_pos<= x35+ line_w) or (x_cur_pos>= x36 and x_cur_pos<= x36+ line_w) or
                        (x_cur_pos>= x37 and x_cur_pos<= x37+ line_w) or (x_cur_pos>= x38 and x_cur_pos<= x38+ line_w) or
                        (x_cur_pos>= x39 and x_cur_pos<= x39+ line_w) or (x_cur_pos>= x40 and x_cur_pos<= x40+ line_w) or
                        (x_cur_pos>= x41 and x_cur_pos<= x41+ line_w) or (x_cur_pos>= x42 and x_cur_pos<= x42+ line_w) or
                        (x_cur_pos>= x43 and x_cur_pos<= x43+ line_w) or (x_cur_pos>= x44 and x_cur_pos<= x44+ line_w) or
                        (x_cur_pos>= x45 and x_cur_pos<= x45+ line_w) or (x_cur_pos>= x46 and x_cur_pos<= x46+ line_w) or
                        (x_cur_pos>= x47 and x_cur_pos<= x47+ line_w) or (x_cur_pos>= x48 and x_cur_pos<= x48+ line_w) or
                        (x_cur_pos>= x49 and x_cur_pos<= x49+ line_w) or (x_cur_pos>= x50 and x_cur_pos<= x50+ line_w) or
                        (x_cur_pos>= x51 and x_cur_pos<= x51+ line_w) or (x_cur_pos>= x52 and x_cur_pos<= x52+ line_w) or
                        (x_cur_pos>= x53 and x_cur_pos<= x53+ line_w) or (x_cur_pos>= x54 and x_cur_pos<= x54+ line_w) or
                        (x_cur_pos>= x55 and x_cur_pos<= x55+ line_w) or (x_cur_pos>= x56 and x_cur_pos<= x56+ line_w) or
                        (x_cur_pos>= x57 and x_cur_pos<= x57+ line_w) or (x_cur_pos>= x58 and x_cur_pos<= x58+ line_w) or
                        (x_cur_pos>= x59 and x_cur_pos<= x59+ line_w) or (x_cur_pos>= x60 and x_cur_pos<= x60+ line_w) or
                        (x_cur_pos>= x61 and x_cur_pos<= x61+ line_w) or (x_cur_pos>= x62 and x_cur_pos<= x62+ line_w) or
                        (x_cur_pos>= x63 and x_cur_pos<= x63+ line_w) or (x_cur_pos>= x64 and x_cur_pos<= x64+ line_w) or
                        (x_cur_pos>= x64*2- x63 and x_cur_pos<= x64*2- x63+ line_w)) and y_cur_pos>=y1 and y_cur_pos<= y64*2- y63) or
                        -- drawing area hor line
                        (((y_cur_pos>= y1 and y_cur_pos<= y1+ line_w) or (y_cur_pos>= y2 and y_cur_pos<= y2+ line_w) or
                        (y_cur_pos>= y3 and y_cur_pos<= y3+ line_w) or (y_cur_pos>= y4 and y_cur_pos<= y4+ line_w) or
                        (y_cur_pos>= y5 and y_cur_pos<= y5+ line_w) or (y_cur_pos>= y6 and y_cur_pos<= y6+ line_w) or
                        (y_cur_pos>= y7 and y_cur_pos<= y7+ line_w) or (y_cur_pos>= y8 and y_cur_pos<= y8+ line_w) or
                        (y_cur_pos>= y9 and y_cur_pos<= y9+ line_w) or (y_cur_pos>= y10 and y_cur_pos<= y10+ line_w) or
                        (y_cur_pos>= y11 and y_cur_pos<= y11+ line_w) or (y_cur_pos>= y12 and y_cur_pos<= y12+ line_w) or
                        (y_cur_pos>= y13 and y_cur_pos<= y13+ line_w) or (y_cur_pos>= y14 and y_cur_pos<= y14+ line_w) or
                        (y_cur_pos>= y15 and y_cur_pos<= y15+ line_w) or (y_cur_pos>= y16 and y_cur_pos<= y16+ line_w) or
                        (y_cur_pos>= y17 and y_cur_pos<= y17+ line_w) or (y_cur_pos>= y18 and y_cur_pos<= y18+ line_w) or
                        (y_cur_pos>= y19 and y_cur_pos<= y19+ line_w) or (y_cur_pos>= y20 and y_cur_pos<= y20+ line_w) or
                        (y_cur_pos>= y21 and y_cur_pos<= y21+ line_w) or (y_cur_pos>= y22 and y_cur_pos<= y22+ line_w) or
                        (y_cur_pos>= y23 and y_cur_pos<= y23+ line_w) or (y_cur_pos>= y24 and y_cur_pos<= y24+ line_w) or
                        (y_cur_pos>= y25 and y_cur_pos<= y25+ line_w) or (y_cur_pos>= y26 and y_cur_pos<= y26+ line_w) or
                        (y_cur_pos>= y27 and y_cur_pos<= y27+ line_w) or (y_cur_pos>= y28 and y_cur_pos<= y28+ line_w) or
                        (y_cur_pos>= y29 and y_cur_pos<= y29+ line_w) or (y_cur_pos>= y30 and y_cur_pos<= y30+ line_w) or
                        (y_cur_pos>= y31 and y_cur_pos<= y31+ line_w) or (y_cur_pos>= y32 and y_cur_pos<= y32+ line_w) or
                        (y_cur_pos>= y33 and y_cur_pos<= y33+ line_w) or (y_cur_pos>= y34 and y_cur_pos<= y34+ line_w) or
                        (y_cur_pos>= y35 and y_cur_pos<= y35+ line_w) or (y_cur_pos>= y36 and y_cur_pos<= y36+ line_w) or
                        (y_cur_pos>= y37 and y_cur_pos<= y37+ line_w) or (y_cur_pos>= y38 and y_cur_pos<= y38+ line_w) or
                        (y_cur_pos>= y39 and y_cur_pos<= y39+ line_w) or (y_cur_pos>= y40 and y_cur_pos<= y40+ line_w) or
                        (y_cur_pos>= y41 and y_cur_pos<= y41+ line_w) or (y_cur_pos>= y42 and y_cur_pos<= y42+ line_w) or
                        (y_cur_pos>= y43 and y_cur_pos<= y43+ line_w) or (y_cur_pos>= y44 and y_cur_pos<= y44+ line_w) or
                        (y_cur_pos>= y45 and y_cur_pos<= y45+ line_w) or (y_cur_pos>= y46 and y_cur_pos<= y46+ line_w) or
                        (y_cur_pos>= y47 and y_cur_pos<= y47+ line_w) or (y_cur_pos>= y48 and y_cur_pos<= y48+ line_w) or
                        (y_cur_pos>= y49 and y_cur_pos<= y49+ line_w) or (y_cur_pos>= y50 and y_cur_pos<= y50+ line_w) or
                        (y_cur_pos>= y51 and y_cur_pos<= y51+ line_w) or (y_cur_pos>= y52 and y_cur_pos<= y52+ line_w) or
                        (y_cur_pos>= y53 and y_cur_pos<= y53+ line_w) or (y_cur_pos>= y54 and y_cur_pos<= y54+ line_w) or
                        (y_cur_pos>= y55 and y_cur_pos<= y55+ line_w) or (y_cur_pos>= y56 and y_cur_pos<= y56+ line_w) or
                        (y_cur_pos>= y57 and y_cur_pos<= y57+ line_w) or (y_cur_pos>= y58 and y_cur_pos<= y58+ line_w) or
                        (y_cur_pos>= y59 and y_cur_pos<= y59+ line_w) or (y_cur_pos>= y60 and y_cur_pos<= y60+ line_w) or
                        (y_cur_pos>= y61 and y_cur_pos<= y61+ line_w) or (y_cur_pos>= y62 and y_cur_pos<= y62+ line_w) or
                        (y_cur_pos>= y63 and y_cur_pos<= y63+ line_w) or (y_cur_pos>= y64 and y_cur_pos<= y64+ line_w) or
                        (y_cur_pos>= y64*2- y63 and y_cur_pos<= y64*2- y63+ line_w)) and x_cur_pos>= x1 and x_cur_pos<= x64*2- x63) or
                        -- color area ver line
                        (((x_cur_pos>= x1_color and x_cur_pos<= x1_color+ line_w) or (x_cur_pos>= x1_color+ x_color_width and x_cur_pos<= x1_color+ x_color_width+ line_w) or
                        (x_cur_pos>= x2_color and x_cur_pos<= x2_color+ line_w) or (x_cur_pos>= x2_color+ x_color_width and x_cur_pos<= x2_color+ x_color_width+ line_w)) and
                        ((y_cur_pos>= y1_color and y_cur_pos<= y1_color+ y_color_width) or (y_cur_pos>= y2_color and y_cur_pos<= y2_color+ y_color_width) or
                        (y_cur_pos>= y3_color and y_cur_pos<= y3_color+ y_color_width) or (y_cur_pos>= y4_color and y_cur_pos<= y4_color+ y_color_width) or
                        (y_cur_pos>= y5_color and y_cur_pos<= y5_color+ y_color_width) or (y_cur_pos>= y6_color and y_cur_pos<= y6_color+ y_color_width) or
                        (y_cur_pos>= y7_color and y_cur_pos<= y7_color+ y_color_width) or (y_cur_pos>= y8_color and y_cur_pos<= y8_color+ y_color_width) or
                        (y_cur_pos>= y9_color and y_cur_pos<= y9_color+ y_color_width) or (y_cur_pos>= y10_color and y_cur_pos<= y10_color+ y_color_width) or
                        (y_cur_pos>= y11_color and y_cur_pos<= y11_color+ y_color_width) or (y_cur_pos>= y12_color and y_cur_pos<= y12_color+ y_color_width) or
                        (y_cur_pos>= y13_color and y_cur_pos<= y13_color+ y_color_width) or (y_cur_pos>= y14_color and y_cur_pos<= y14_color+ y_color_width) or
                        (y_cur_pos>= y15_color and y_cur_pos<= y15_color+ y_color_width) or (y_cur_pos>= y16_color and y_cur_pos<= y16_color+ y_color_width))) or
                        -- color area hor line
                        (((y_cur_pos>= y1_color and y_cur_pos<= y1_color+ line_w) or (y_cur_pos>= y1_color+ y_color_width and y_cur_pos<= y1_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y2_color and y_cur_pos<= y2_color+ line_w) or (y_cur_pos>= y2_color+ y_color_width and y_cur_pos<= y2_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y3_color and y_cur_pos<= y3_color+ line_w) or (y_cur_pos>= y3_color+ y_color_width and y_cur_pos<= y3_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y4_color and y_cur_pos<= y4_color+ line_w) or (y_cur_pos>= y4_color+ y_color_width and y_cur_pos<= y4_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y5_color and y_cur_pos<= y5_color+ line_w) or (y_cur_pos>= y5_color+ y_color_width and y_cur_pos<= y5_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y6_color and y_cur_pos<= y6_color+ line_w) or (y_cur_pos>= y6_color+ y_color_width and y_cur_pos<= y6_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y7_color and y_cur_pos<= y7_color+ line_w) or (y_cur_pos>= y7_color+ y_color_width and y_cur_pos<= y7_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y8_color and y_cur_pos<= y8_color+ line_w) or (y_cur_pos>= y8_color+ y_color_width and y_cur_pos<= y8_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y9_color and y_cur_pos<= y9_color+ line_w) or (y_cur_pos>= y9_color+ y_color_width and y_cur_pos<= y9_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y10_color and y_cur_pos<= y10_color+ line_w) or (y_cur_pos>= y10_color+ y_color_width and y_cur_pos<= y10_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y11_color and y_cur_pos<= y11_color+ line_w) or (y_cur_pos>= y11_color+ y_color_width and y_cur_pos<= y11_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y12_color and y_cur_pos<= y12_color+ line_w) or (y_cur_pos>= y12_color+ y_color_width and y_cur_pos<= y12_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y13_color and y_cur_pos<= y13_color+ line_w) or (y_cur_pos>= y13_color+ y_color_width and y_cur_pos<= y13_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y14_color and y_cur_pos<= y14_color+ line_w) or (y_cur_pos>= y14_color+ y_color_width and y_cur_pos<= y14_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y15_color and y_cur_pos<= y15_color+ line_w) or (y_cur_pos>= y15_color+ y_color_width and y_cur_pos<= y15_color+ y_color_width+ line_w) or
                        (y_cur_pos>= y16_color and y_cur_pos<= y16_color+ line_w) or (y_cur_pos>= y16_color+ y_color_width and y_cur_pos<= y16_color+ y_color_width+ line_w)) and
                        ((x_cur_pos>= x1_color and x_cur_pos<= x1_color+ x_color_width) or (x_cur_pos>= x2_color and x_cur_pos<= x2_color+ x_color_width))) then
                    -- gird
                    vga_r_tmp<= color_sel_r;
                    vga_g_tmp<= color_sel_g;
                    vga_b_tmp<= color_sel_b;

                else
                    vga_r_tmp<= color_back_r;
                    vga_g_tmp<= color_back_g;
                    vga_b_tmp<= color_back_b;
                end if;
            else
                vga_r_tmp<= x"00";
                vga_g_tmp<= x"00";
                vga_b_tmp<= x"00";    
            end if;
        end if;
    end process img_gen;
    
end architecture bhv;