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
        img_ram_add: out std_logic_vector(9 downto 0);
        img_ram_data: in std_logic_vector(23 downto 0)
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
	constant x2: integer:= 138;
	constant x3: integer:= 150;
	constant x4: integer:= 163;
	constant x5: integer:= 175;
	constant x6: integer:= 188;
	constant x7: integer:= 200;
	constant x8: integer:= 213;
	constant x9: integer:= 225;
	constant x10: integer:= 238;
	constant x11: integer:= 250;
	constant x12: integer:= 263;
	constant x13: integer:= 275;
	constant x14: integer:= 288;
	constant x15: integer:= 300;
	constant x16: integer:= 313;
	constant x17: integer:= 325;
	constant x18: integer:= 338;
	constant x19: integer:= 350;
	constant x20: integer:= 363;
	constant x21: integer:= 375;
	constant x22: integer:= 388;
	constant x23: integer:= 400;
	constant x24: integer:= 413;
	constant x25: integer:= 425;
	constant x26: integer:= 438;
	constant x27: integer:= 450;
	constant x28: integer:= 463;
	constant x29: integer:= 475;
	constant x30: integer:= 488;
	constant x31: integer:= 500;
	constant x32: integer:= 513;
	constant x1_color: integer:= 608; -- color area locs
	constant x2_color: integer:= 633;
	constant y1: integer:= 28; -- drawing area locs
	constant y2: integer:= 44;
	constant y3: integer:= 61;
	constant y4: integer:= 78;
	constant y5: integer:= 94;
	constant y6: integer:= 111;
	constant y7: integer:= 128;
	constant y8: integer:= 144;
	constant y9: integer:= 161;
	constant y10: integer:= 178;
	constant y11: integer:= 194;
	constant y12: integer:= 211;
	constant y13: integer:= 228;
	constant y14: integer:= 244;
	constant y15: integer:= 261;
	constant y16: integer:= 278;
	constant y17: integer:= 294;
	constant y18: integer:= 311;
	constant y19: integer:= 328;
	constant y20: integer:= 344;
	constant y21: integer:= 361;
	constant y22: integer:= 378;
	constant y23: integer:= 394;
	constant y24: integer:= 411;
	constant y25: integer:= 428;
	constant y26: integer:= 444;
	constant y27: integer:= 461;
	constant y28: integer:= 478;
	constant y29: integer:= 494;
	constant y30: integer:= 511;
	constant y31: integer:= 528;
	constant y32: integer:= 544;
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
	constant x_draw_width: integer:= 13;
	constant y_draw_width: integer:= 17;
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
        --variable color_tmp_row: integer range 0 to 15;
        --variable color_tmp_col: integer range 0 to 1;
    begin
        if rst_n = '0' then
            vga_r_tmp<= x"00";
            vga_g_tmp<= x"00";
            vga_b_tmp<= x"00";
            x_tmp:= 65;
            y_tmp:= 1;
            color_tmp:= 1;
            --color_tmp_row:= 0;
            --color_tmp_col:= 0;
        elsif rising_edge(clk_pix) then
            if video_active_flag= '1' then
                x_tmp:= conv_integer(x_point);
                y_tmp:= conv_integer(y_point);
                color_tmp:= conv_integer(color_num);
                if      -- drawing area pointer
                        (x_tmp<= 32 and y_tmp<= 32 and
                        (x_cur_pos>= h_active*19/128+ x_tmp*h_active/64- dot_w) and (y_cur_pos>= v_active*7/216+ y_tmp*v_active/36- dot_w) and
                        (x_cur_pos<= h_active*19/128+ x_tmp*h_active/64+ dot_w) and (y_cur_pos<= v_active*7/216+ y_tmp*v_active/36+ dot_w)) or
                        -- color area pointer
                        (x_tmp> 32 and y_tmp<= 16 and
                        (x_cur_pos>= x_tmp*h_active/32- h_active*25/96- dot_w) and (y_cur_pos>= v_active/108+ y_tmp*v_active/18- dot_w) and
                        (x_cur_pos<= x_tmp*h_active/32- h_active*25/96+ dot_w) and (y_cur_pos<= v_active/108+ y_tmp*v_active/18- dot_w)) or
                        -- color area selectors
                        (color_tmp>= 1 and color_tmp<= 32 and
                        (x_cur_pos>= h_active*73/96+ (1- (color_tmp rem 2))*h_active/32) and (x_cur_pos< h_active*25/32+ (1- (color_tmp rem 2))*h_active/32) and
                        (y_cur_pos>= v_active/12+ ((color_tmp+ 1)/2- 1)*v_active/18- selector_w) and (y_cur_pos< v_active/12+ ((color_tmp+ 1)/2- 1)*v_active/18)) then
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
                        (x_cur_pos>= x32+ x_draw_width and x_cur_pos<= x32+ x_draw_width+ line_w)) and y_cur_pos>=y1 and y_cur_pos<= y32+ y_draw_width) or
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
                        (y_cur_pos>= y32+ y_draw_width and y_cur_pos<= y32+ y_draw_width+ line_w)) and x_cur_pos>= x1 and x_cur_pos<= x32+ x_draw_width) or
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
            -- elsif color area
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y1_color) and (y_cur_pos<= y1_color+ y_color_width)) then
                    vga_r_tmp<= color_1_r;
                    vga_g_tmp<= color_1_g;
                    vga_b_tmp<= color_1_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y1_color) and (y_cur_pos<= y1_color+ y_color_width)) then
                    vga_r_tmp<= color_2_r;
                    vga_g_tmp<= color_2_g;
                    vga_b_tmp<= color_2_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y2_color) and (y_cur_pos<= y2_color+ y_color_width)) then
                    vga_r_tmp<= color_3_r;
                    vga_g_tmp<= color_3_g;
                    vga_b_tmp<= color_3_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y2_color) and (y_cur_pos<= y2_color+ y_color_width)) then
                    vga_r_tmp<= color_4_r;
                    vga_g_tmp<= color_4_g;
                    vga_b_tmp<= color_4_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y3_color) and (y_cur_pos<= y3_color+ y_color_width)) then
                    vga_r_tmp<= color_5_r;
                    vga_g_tmp<= color_5_g;
                    vga_b_tmp<= color_5_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y3_color) and (y_cur_pos<= y3_color+ y_color_width)) then
                    vga_r_tmp<= color_6_r;
                    vga_g_tmp<= color_6_g;
                    vga_b_tmp<= color_6_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y4_color) and (y_cur_pos<= y4_color+ y_color_width)) then
                    vga_r_tmp<= color_7_r;
                    vga_g_tmp<= color_7_g;
                    vga_b_tmp<= color_7_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y4_color) and (y_cur_pos<= y4_color+ y_color_width)) then
                    vga_r_tmp<= color_8_r;
                    vga_g_tmp<= color_8_g;
                    vga_b_tmp<= color_8_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y5_color) and (y_cur_pos<= y5_color+ y_color_width)) then
                    vga_r_tmp<= color_9_r;
                    vga_g_tmp<= color_9_g;
                    vga_b_tmp<= color_9_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y5_color) and (y_cur_pos<= y5_color+ y_color_width)) then
                    vga_r_tmp<= color_10_r;
                    vga_g_tmp<= color_10_g;
                    vga_b_tmp<= color_10_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y6_color) and (y_cur_pos<= y6_color+ y_color_width)) then
                    vga_r_tmp<= color_11_r;
                    vga_g_tmp<= color_11_g;
                    vga_b_tmp<= color_11_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y6_color) and (y_cur_pos<= y6_color+ y_color_width)) then
                    vga_r_tmp<= color_12_r;
                    vga_g_tmp<= color_12_g;
                    vga_b_tmp<= color_12_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y7_color) and (y_cur_pos<= y7_color+ y_color_width)) then
                    vga_r_tmp<= color_13_r;
                    vga_g_tmp<= color_13_g;
                    vga_b_tmp<= color_13_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y7_color) and (y_cur_pos<= y7_color+ y_color_width)) then
                    vga_r_tmp<= color_14_r;
                    vga_g_tmp<= color_14_g;
                    vga_b_tmp<= color_14_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y8_color) and (y_cur_pos<= y8_color+ y_color_width)) then
                    vga_r_tmp<= color_15_r;
                    vga_g_tmp<= color_15_g;
                    vga_b_tmp<= color_15_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y8_color) and (y_cur_pos<= y8_color+ y_color_width)) then
                    vga_r_tmp<= color_16_r;
                    vga_g_tmp<= color_16_g;
                    vga_b_tmp<= color_16_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y9_color) and (y_cur_pos<= y9_color+ y_color_width)) then
                    vga_r_tmp<= color_17_r;
                    vga_g_tmp<= color_17_g;
                    vga_b_tmp<= color_17_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y9_color) and (y_cur_pos<= y9_color+ y_color_width)) then
                    vga_r_tmp<= color_18_r;
                    vga_g_tmp<= color_18_g;
                    vga_b_tmp<= color_18_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y10_color) and (y_cur_pos<= y10_color+ y_color_width)) then
                    vga_r_tmp<= color_19_r;
                    vga_g_tmp<= color_19_g;
                    vga_b_tmp<= color_19_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y10_color) and (y_cur_pos<= y10_color+ y_color_width)) then
                    vga_r_tmp<= color_20_r;
                    vga_g_tmp<= color_20_g;
                    vga_b_tmp<= color_20_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y11_color) and (y_cur_pos<= y11_color+ y_color_width)) then
                    vga_r_tmp<= color_21_r;
                    vga_g_tmp<= color_21_g;
                    vga_b_tmp<= color_21_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y11_color) and (y_cur_pos<= y11_color+ y_color_width)) then
                    vga_r_tmp<= color_22_r;
                    vga_g_tmp<= color_22_g;
                    vga_b_tmp<= color_22_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y12_color) and (y_cur_pos<= y12_color+ y_color_width)) then
                    vga_r_tmp<= color_23_r;
                    vga_g_tmp<= color_23_g;
                    vga_b_tmp<= color_23_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y12_color) and (y_cur_pos<= y12_color+ y_color_width)) then
                    vga_r_tmp<= color_24_r;
                    vga_g_tmp<= color_24_g;
                    vga_b_tmp<= color_24_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y13_color) and (y_cur_pos<= y13_color+ y_color_width)) then
                    vga_r_tmp<= color_25_r;
                    vga_g_tmp<= color_25_g;
                    vga_b_tmp<= color_25_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y13_color) and (y_cur_pos<= y13_color+ y_color_width)) then
                    vga_r_tmp<= color_26_r;
                    vga_g_tmp<= color_26_g;
                    vga_b_tmp<= color_26_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y14_color) and (y_cur_pos<= y14_color+ y_color_width)) then
                    vga_r_tmp<= color_27_r;
                    vga_g_tmp<= color_27_g;
                    vga_b_tmp<= color_27_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y14_color) and (y_cur_pos<= y14_color+ y_color_width)) then
                    vga_r_tmp<= color_28_r;
                    vga_g_tmp<= color_28_g;
                    vga_b_tmp<= color_28_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y15_color) and (y_cur_pos<= y15_color+ y_color_width)) then
                    vga_r_tmp<= color_29_r;
                    vga_g_tmp<= color_29_g;
                    vga_b_tmp<= color_29_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y15_color) and (y_cur_pos<= y15_color+ y_color_width)) then
                    vga_r_tmp<= color_30_r;
                    vga_g_tmp<= color_30_g;
                    vga_b_tmp<= color_30_b;
                elsif ((x_cur_pos>= x1_color) and (x_cur_pos<= x1_color+ x_color_width) and (y_cur_pos>= y16_color) and (y_cur_pos<= y16_color+ y_color_width)) then
                    vga_r_tmp<= color_31_r;
                    vga_g_tmp<= color_31_g;
                    vga_b_tmp<= color_31_b;
                elsif ((x_cur_pos>= x2_color) and (x_cur_pos<= x2_color+ x_color_width) and (y_cur_pos>= y16_color) and (y_cur_pos<= y16_color+ y_color_width)) then
                    vga_r_tmp<= color_32_r;
                    vga_g_tmp<= color_32_g;
                    vga_b_tmp<= color_32_b;
            -- elsif draw row1
                elsif (x_cur_pos>=x1- 2 and x_cur_pos<x2- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(0, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x2- 2 and x_cur_pos<x3- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(1, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x3- 2 and x_cur_pos<x4- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(2, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x4- 2 and x_cur_pos<x5- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(3, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x5- 2 and x_cur_pos<x6- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(4, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x6- 2 and x_cur_pos<x7- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(5, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x7- 2 and x_cur_pos<x8- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(6, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x8- 2 and x_cur_pos<x9- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(7, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x9- 2 and x_cur_pos<x10- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(8, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x10- 2 and x_cur_pos<x11- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(9, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x11- 2 and x_cur_pos<x12- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(10, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x12- 2 and x_cur_pos<x13- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(11, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x13- 2 and x_cur_pos<x14- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(12, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x14- 2 and x_cur_pos<x15- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(13, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x15- 2 and x_cur_pos<x16- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(14, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x16- 2 and x_cur_pos<x17- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(15, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x17- 2 and x_cur_pos<x18- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(16, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x18- 2 and x_cur_pos<x19- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(17, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x19- 2 and x_cur_pos<x20- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(18, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x20- 2 and x_cur_pos<x21- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(19, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x21- 2 and x_cur_pos<x22- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(20, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x22- 2 and x_cur_pos<x23- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(21, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x23- 2 and x_cur_pos<x24- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(22, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x24- 2 and x_cur_pos<x25- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(23, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x25- 2 and x_cur_pos<x26- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(24, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x26- 2 and x_cur_pos<x27- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(25, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x27- 2 and x_cur_pos<x28- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(26, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x28- 2 and x_cur_pos<x29- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(27, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x29- 2 and x_cur_pos<x30- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(28, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x30- 2 and x_cur_pos<x31- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(29, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x31- 2 and x_cur_pos<x32- 2 and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(30, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
                elsif (x_cur_pos>=x32- 2 and x_cur_pos<x32+ x_draw_width and y_cur_pos>=y1 and y_cur_pos<y2) then
                    img_ram_add<= conv_std_logic_vector(31, img_ram_add'length);
                    vga_r_tmp<= img_ram_data(23 downto 16);
                    vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
			--elsif draw row2
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(32, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(33, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(34, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(35, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(36, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(37, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(38, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(39, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(40, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(41, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(42, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(43, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(44, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(45, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(46, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(47, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(48, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(49, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(50, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(51, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(52, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(53, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(54, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(55, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(56, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(57, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(58, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(59, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(60, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(61, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(62, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y2 and y_cur_pos<y3) then
					img_ram_add<= conv_std_logic_vector(63, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
			-- elsif draw row3
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(64, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(65, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(66, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(67, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(68, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(69, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(70, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(71, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(72, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(73, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(74, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(75, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(76, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(77, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(78, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(79, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(80, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(81, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(82, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(83, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(84, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(85, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(86, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(87, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(88, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(89, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(90, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(91, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(92, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(93, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(94, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y3 and y_cur_pos<y4) then
					img_ram_add<= conv_std_logic_vector(95, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
			-- elsif draw row4
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(96, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(97, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(98, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(99, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(100, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(101, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(102, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(103, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(104, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(105, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(106, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(107, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(108, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(109, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(110, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(111, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(112, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(113, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(114, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(115, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(116, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(117, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(118, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(119, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(120, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(121, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(122, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(123, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(124, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(125, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(126, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y4 and y_cur_pos<y5) then
					img_ram_add<= conv_std_logic_vector(127, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row5
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(128, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(129, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(130, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(131, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(132, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(133, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(134, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(135, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(136, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(137, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(138, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(139, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(140, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(141, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(142, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(143, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(144, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(145, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(146, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(147, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(148, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(149, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(150, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(151, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(152, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(153, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(154, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(155, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(156, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(157, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(158, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y5 and y_cur_pos<y6) then
					img_ram_add<= conv_std_logic_vector(159, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row6
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(160, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(161, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(162, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(163, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(164, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(165, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(166, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(167, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(168, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(169, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(170, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(171, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(172, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(173, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(174, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(175, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(176, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(177, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(178, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(179, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(180, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(181, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(182, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(183, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(184, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(185, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(186, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(187, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(188, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(189, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(190, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y6 and y_cur_pos<y7) then
					img_ram_add<= conv_std_logic_vector(191, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row7
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(192, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(193, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(194, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(195, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(196, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(197, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(198, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(199, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(200, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(201, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(202, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(203, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(204, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(205, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(206, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(207, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(208, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(209, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(210, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(211, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(212, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(213, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(214, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(215, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(216, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(217, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(218, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(219, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(220, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(221, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(222, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y7 and y_cur_pos<y8) then
					img_ram_add<= conv_std_logic_vector(223, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row8
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(224, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(225, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(226, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(227, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(228, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(229, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(230, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(231, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(232, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(233, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(234, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(235, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(236, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(237, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(238, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(239, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(240, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(241, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(242, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(243, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(244, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(245, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(246, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(247, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(248, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(249, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(250, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(251, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(252, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(253, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(254, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y8 and y_cur_pos<y9) then
					img_ram_add<= conv_std_logic_vector(255, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row9
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(256, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(257, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(258, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(259, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(260, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(261, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(262, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(263, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(264, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(265, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(266, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(267, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(268, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(269, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(270, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(271, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(272, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(273, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(274, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(275, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(276, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(277, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(278, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(279, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(280, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(281, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(282, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(283, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(284, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(285, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(286, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y9 and y_cur_pos<y10) then
					img_ram_add<= conv_std_logic_vector(287, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row10
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(288, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(289, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(290, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(291, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(292, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(293, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(294, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(295, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(296, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(297, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(298, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(299, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(300, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(301, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(302, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(303, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(304, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(305, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(306, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(307, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(308, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(309, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(310, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(311, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(312, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(313, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(314, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(315, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(316, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(317, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(318, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y10 and y_cur_pos<y11) then
					img_ram_add<= conv_std_logic_vector(319, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row11
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(320, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(321, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(322, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(323, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(324, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(325, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(326, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(327, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(328, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(329, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(330, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(331, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(332, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(333, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(334, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(335, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(336, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(337, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(338, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(339, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(340, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(341, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(342, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(343, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(344, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(345, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(346, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(347, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(348, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(349, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(350, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y11 and y_cur_pos<y12) then
					img_ram_add<= conv_std_logic_vector(351, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row12
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(352, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(353, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(354, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(355, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(356, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(357, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(358, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(359, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(360, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(361, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(362, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(363, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(364, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(365, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(366, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(367, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(368, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(369, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(370, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(371, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(372, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(373, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(374, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(375, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(376, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(377, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(378, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(379, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(380, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(381, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(382, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y12 and y_cur_pos<y13) then
					img_ram_add<= conv_std_logic_vector(383, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row13
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(384, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(385, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(386, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(387, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(388, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(389, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(390, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(391, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(392, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(393, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(394, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(395, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(396, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(397, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(398, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(399, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(400, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(401, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(402, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(403, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(404, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(405, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(406, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(407, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(408, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(409, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(410, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(411, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(412, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(413, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(414, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y13 and y_cur_pos<y14) then
					img_ram_add<= conv_std_logic_vector(415, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row14
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(416, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(417, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(418, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(419, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(420, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(421, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(422, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(423, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(424, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(425, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(426, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(427, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(428, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(429, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(430, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(431, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(432, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(433, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(434, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(435, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(436, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(437, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(438, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(439, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(440, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(441, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(442, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(443, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(444, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(445, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(446, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y14 and y_cur_pos<y15) then
					img_ram_add<= conv_std_logic_vector(447, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row15
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(448, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(449, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(450, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(451, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(452, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(453, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(454, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(455, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(456, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(457, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(458, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(459, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(460, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(461, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(462, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(463, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(464, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(465, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(466, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(467, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(468, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(469, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(470, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(471, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(472, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(473, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(474, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(475, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(476, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(477, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(478, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y15 and y_cur_pos<y16) then
					img_ram_add<= conv_std_logic_vector(479, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row16
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(480, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(481, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(482, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(483, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(484, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(485, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(486, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(487, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(488, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(489, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(490, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(491, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(492, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(493, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(494, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(495, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(496, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(497, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(498, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(499, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(500, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(501, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(502, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(503, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(504, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(505, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(506, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(507, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(508, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(509, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(510, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y16 and y_cur_pos<y17) then
					img_ram_add<= conv_std_logic_vector(511, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row17
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(512, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(513, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(514, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(515, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(516, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(517, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(518, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(519, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(520, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(521, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(522, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(523, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(524, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(525, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(526, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(527, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(528, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(529, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(530, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(531, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(532, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(533, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(534, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(535, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(536, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(537, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(538, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(539, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(540, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(541, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(542, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y17 and y_cur_pos<y18) then
					img_ram_add<= conv_std_logic_vector(543, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row18
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(544, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(545, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(546, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(547, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(548, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(549, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(550, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(551, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(552, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(553, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(554, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(555, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(556, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(557, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(558, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(559, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(560, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(561, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(562, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(563, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(564, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(565, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(566, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(567, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(568, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(569, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(570, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(571, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(572, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(573, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(574, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y18 and y_cur_pos<y19) then
					img_ram_add<= conv_std_logic_vector(575, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row19
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(576, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(577, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(578, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(579, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(580, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(581, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(582, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(583, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(584, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(585, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(586, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(587, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(588, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(589, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(590, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(591, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(592, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(593, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(594, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(595, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(596, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(597, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(598, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(599, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(600, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(601, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(602, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(603, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(604, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(605, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(606, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y19 and y_cur_pos<y20) then
					img_ram_add<= conv_std_logic_vector(607, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row20
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(608, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(609, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(610, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(611, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(612, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(613, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(614, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(615, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(616, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(617, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(618, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(619, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(620, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(621, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(622, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(623, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(624, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(625, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(626, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(627, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(628, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(629, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(630, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(631, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(632, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(633, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(634, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(635, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(636, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(637, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(638, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y20 and y_cur_pos<y21) then
					img_ram_add<= conv_std_logic_vector(639, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row21
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(640, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(641, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(642, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(643, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(644, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(645, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(646, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(647, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(648, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(649, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(650, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(651, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(652, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(653, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(654, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(655, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(656, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(657, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(658, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(659, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(660, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(661, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(662, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(663, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(664, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(665, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(666, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(667, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(668, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(669, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(670, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y21 and y_cur_pos<y22) then
					img_ram_add<= conv_std_logic_vector(671, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row22
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(672, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(673, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(674, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(675, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(676, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(677, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(678, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(679, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(680, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(681, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(682, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(683, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(684, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(685, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(686, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(687, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(688, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(689, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(690, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(691, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(692, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(693, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(694, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(695, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(696, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(697, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(698, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(699, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(700, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(701, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(702, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y22 and y_cur_pos<y23) then
					img_ram_add<= conv_std_logic_vector(703, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row23
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(704, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(705, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(706, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(707, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(708, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(709, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(710, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(711, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(712, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(713, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(714, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(715, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(716, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(717, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(718, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(719, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(720, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(721, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(722, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(723, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(724, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(725, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(726, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(727, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(728, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(729, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(730, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(731, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(732, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(733, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(734, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y23 and y_cur_pos<y24) then
					img_ram_add<= conv_std_logic_vector(735, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row24
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(736, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(737, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(738, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(739, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(740, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(741, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(742, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(743, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(744, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(745, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(746, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(747, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(748, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(749, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(750, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(751, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(752, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(753, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(754, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(755, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(756, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(757, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(758, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(759, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(760, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(761, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(762, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(763, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(764, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(765, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(766, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y24 and y_cur_pos<y25) then
					img_ram_add<= conv_std_logic_vector(767, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row25
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(768, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(769, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(770, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(771, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(772, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(773, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(774, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(775, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(776, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(777, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(778, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(779, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(780, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(781, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(782, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(783, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(784, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(785, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(786, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(787, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(788, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(789, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(790, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(791, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(792, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(793, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(794, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(795, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(796, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(797, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(798, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y25 and y_cur_pos<y26) then
					img_ram_add<= conv_std_logic_vector(799, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row26
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(800, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(801, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(802, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(803, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(804, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(805, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(806, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(807, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(808, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(809, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(810, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(811, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(812, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(813, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(814, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(815, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(816, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(817, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(818, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(819, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(820, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(821, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(822, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(823, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(824, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(825, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(826, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(827, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(828, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(829, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(830, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y26 and y_cur_pos<y27) then
					img_ram_add<= conv_std_logic_vector(831, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row27
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(832, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(833, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(834, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(835, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(836, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(837, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(838, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(839, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(840, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(841, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(842, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(843, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(844, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(845, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(846, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(847, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(848, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(849, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(850, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(851, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(852, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(853, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(854, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(855, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(856, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(857, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(858, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(859, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(860, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(861, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(862, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y27 and y_cur_pos<y28) then
					img_ram_add<= conv_std_logic_vector(863, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row28
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(864, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(865, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(866, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(867, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(868, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(869, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(870, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(871, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(872, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(873, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(874, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(875, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(876, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(877, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(878, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(879, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(880, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(881, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(882, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(883, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(884, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(885, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(886, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(887, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(888, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(889, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(890, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(891, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(892, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(893, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(894, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y28 and y_cur_pos<y29) then
					img_ram_add<= conv_std_logic_vector(895, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row29
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(896, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(897, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(898, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(899, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(900, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(901, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(902, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(903, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(904, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(905, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(906, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(907, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(908, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(909, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(910, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(911, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(912, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(913, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(914, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(915, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(916, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(917, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(918, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(919, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(920, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(921, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(922, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(923, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(924, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(925, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(926, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y29 and y_cur_pos<y30) then
					img_ram_add<= conv_std_logic_vector(927, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row30
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(928, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(929, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(930, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(931, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(932, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(933, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(934, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(935, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(936, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(937, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(938, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(939, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(940, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(941, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(942, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(943, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(944, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(945, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(946, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(947, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(948, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(949, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(950, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(951, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(952, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(953, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(954, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(955, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(956, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(957, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(958, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y30 and y_cur_pos<y31) then
					img_ram_add<= conv_std_logic_vector(959, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row31
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(960, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(961, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(962, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(963, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(964, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(965, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(966, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(967, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(968, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(969, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(970, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(971, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(972, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(973, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(974, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(975, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(976, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(977, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(978, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(979, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(980, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(981, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(982, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(983, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(984, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(985, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(986, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(987, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(988, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(989, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(990, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y31 and y_cur_pos<y32) then
					img_ram_add<= conv_std_logic_vector(991, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
                    vga_b_tmp<= img_ram_data(7 downto 0);
            -- elsif draw row32
				elsif ((x_cur_pos>=x1- 2) and (x_cur_pos<x2- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(992, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x2- 2) and (x_cur_pos<x3- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(993, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x3- 2) and (x_cur_pos<x4- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(994, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x4- 2) and (x_cur_pos<x5- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(995, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x5- 2) and (x_cur_pos<x6- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(996, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x6- 2) and (x_cur_pos<x7- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(997, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x7- 2) and (x_cur_pos<x8- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(998, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x8- 2) and (x_cur_pos<x9- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(999, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x9- 2) and (x_cur_pos<x10- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1000, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x10- 2) and (x_cur_pos<x11- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1001, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x11- 2) and (x_cur_pos<x12- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1002, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x12- 2) and (x_cur_pos<x13- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1003, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x13- 2) and (x_cur_pos<x14- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1004, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x14- 2) and (x_cur_pos<x15- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1005, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x15- 2) and (x_cur_pos<x16- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1006, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x16- 2) and (x_cur_pos<x17- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1007, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x17- 2) and (x_cur_pos<x18- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1008, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x18- 2) and (x_cur_pos<x19- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1009, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x19- 2) and (x_cur_pos<x20- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1010, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x20- 2) and (x_cur_pos<x21- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1011, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x21- 2) and (x_cur_pos<x22- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1012, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x22- 2) and (x_cur_pos<x23- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1013, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x23- 2) and (x_cur_pos<x24- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1014, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x24- 2) and (x_cur_pos<x25- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1015, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x25- 2) and (x_cur_pos<x26- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1016, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x26- 2) and (x_cur_pos<x27- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1017, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x27- 2) and (x_cur_pos<x28- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1018, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x28- 2) and (x_cur_pos<x29- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1019, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x29- 2) and (x_cur_pos<x30- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1020, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x30- 2) and (x_cur_pos<x31- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1021, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x31- 2) and (x_cur_pos<x32- 2) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1022, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);
				elsif ((x_cur_pos>=x32- 2) and (x_cur_pos<x32+ x_draw_width) and y_cur_pos>=y32 and y_cur_pos<y32+ y_draw_width) then
					img_ram_add<= conv_std_logic_vector(1023, img_ram_add'length);
					vga_r_tmp<= img_ram_data(23 downto 16);
					vga_g_tmp<= img_ram_data(15 downto 8);
					vga_b_tmp<= img_ram_data(7 downto 0);

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