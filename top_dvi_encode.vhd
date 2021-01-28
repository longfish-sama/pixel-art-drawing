-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"
-- CREATED		"Thu Jan 28 19:27:55 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY top_dvi_encode IS 
	PORT
	(
		de :  IN  STD_LOGIC;
		clk_pix :  IN  STD_LOGIC;
		rst_n :  IN  STD_LOGIC;
		h_sync :  IN  STD_LOGIC;
		v_sync :  IN  STD_LOGIC;
		clk_ddr :  IN  STD_LOGIC;
		b_din :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		g_din :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		r_din :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		r_diff_p :  OUT  STD_LOGIC;
		r_diff_n :  OUT  STD_LOGIC;
		g_diff_p :  OUT  STD_LOGIC;
		g_diff_n :  OUT  STD_LOGIC;
		b_diff_p :  OUT  STD_LOGIC;
		b_diff_n :  OUT  STD_LOGIC;
		clk_diff_p :  OUT  STD_LOGIC;
		clk_diff_n :  OUT  STD_LOGIC
	);
END top_dvi_encode;

ARCHITECTURE bdf_type OF top_dvi_encode IS 

COMPONENT par10bit_to_ddr_signal
	PORT(clk_ddr : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 data_par_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 data_out_h : OUT STD_LOGIC;
		 data_out_l : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT ddr_out
	PORT(outclock : IN STD_LOGIC;
		 aclr : IN STD_LOGIC;
		 datain_h : IN STD_LOGIC_VECTOR(0 TO 0);
		 datain_l : IN STD_LOGIC_VECTOR(0 TO 0);
		 dataout : OUT STD_LOGIC_VECTOR(0 TO 0)
	);
END COMPONENT;

COMPONENT ser_to_diffser
	PORT(datain : IN STD_LOGIC_VECTOR(0 TO 0);
		 dataout : OUT STD_LOGIC_VECTOR(0 TO 0);
		 dataout_b : OUT STD_LOGIC_VECTOR(0 TO 0)
	);
END COMPONENT;

COMPONENT dvi_encoder
GENERIC (CTRLTOKEN0 : STD_LOGIC_VECTOR(9 DOWNTO 0);
			CTRLTOKEN1 : STD_LOGIC_VECTOR(9 DOWNTO 0);
			CTRLTOKEN2 : STD_LOGIC_VECTOR(9 DOWNTO 0);
			CTRLTOKEN3 : STD_LOGIC_VECTOR(9 DOWNTO 0)
			);
	PORT(clkin : IN STD_LOGIC;
		 rstin : IN STD_LOGIC;
		 c0 : IN STD_LOGIC;
		 c1 : IN STD_LOGIC;
		 de : IN STD_LOGIC;
		 din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dout : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(0 TO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(0 TO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(0 TO 0);
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_20 <= '0';



b2v_inst : par10bit_to_ddr_signal
PORT MAP(clk_ddr => clk_ddr,
		 rst => rst_n,
		 data_par_in => SYNTHESIZED_WIRE_0,
		 data_out_h => SYNTHESIZED_WIRE_14,
		 data_out_l => SYNTHESIZED_WIRE_15);


b2v_inst1 : par10bit_to_ddr_signal
PORT MAP(clk_ddr => clk_ddr,
		 rst => rst_n,
		 data_par_in => SYNTHESIZED_WIRE_1,
		 data_out_h => SYNTHESIZED_WIRE_17,
		 data_out_l => SYNTHESIZED_WIRE_18);


b2v_inst10 : ddr_out
PORT MAP(outclock => clk_ddr,
		 aclr => SYNTHESIZED_WIRE_19,
		 datain_h(0) => SYNTHESIZED_WIRE_3,
		 datain_l(0) => SYNTHESIZED_WIRE_4,
		 dataout(0) => SYNTHESIZED_WIRE_6(0));


b2v_inst11 : ser_to_diffser
PORT MAP(datain(0) => SYNTHESIZED_WIRE_5(0),
		 dataout(0) => g_diff_p,
		 dataout_b(0) => g_diff_n);


b2v_inst12 : ser_to_diffser
PORT MAP(datain(0) => SYNTHESIZED_WIRE_6(0),
		 dataout(0) => b_diff_p,
		 dataout_b(0) => b_diff_n);


b2v_inst13 : ser_to_diffser
PORT MAP(datain(0) => clk_pix,
		 dataout(0) => clk_diff_p,
		 dataout_b(0) => clk_diff_n);


SYNTHESIZED_WIRE_19 <= NOT(rst_n);



b2v_inst2 : par10bit_to_ddr_signal
PORT MAP(clk_ddr => clk_ddr,
		 rst => rst_n,
		 data_par_in => SYNTHESIZED_WIRE_7,
		 data_out_h => SYNTHESIZED_WIRE_3,
		 data_out_l => SYNTHESIZED_WIRE_4);


b2v_inst3 : ser_to_diffser
PORT MAP(datain(0) => SYNTHESIZED_WIRE_8(0),
		 dataout(0) => r_diff_p,
		 dataout_b(0) => r_diff_n);


b2v_inst4 : dvi_encoder
GENERIC MAP(CTRLTOKEN0 => "1101010100",
			CTRLTOKEN1 => "0010101011",
			CTRLTOKEN2 => "0101010100",
			CTRLTOKEN3 => "1010101011"
			)
PORT MAP(clkin => clk_pix,
		 rstin => rst_n,
		 c0 => h_sync,
		 c1 => v_sync,
		 de => de,
		 din => r_din,
		 dout => SYNTHESIZED_WIRE_0);


b2v_inst5 : dvi_encoder
GENERIC MAP(CTRLTOKEN0 => "1101010100",
			CTRLTOKEN1 => "0010101011",
			CTRLTOKEN2 => "0101010100",
			CTRLTOKEN3 => "1010101011"
			)
PORT MAP(clkin => clk_pix,
		 rstin => rst_n,
		 c0 => SYNTHESIZED_WIRE_20,
		 c1 => SYNTHESIZED_WIRE_20,
		 de => de,
		 din => g_din,
		 dout => SYNTHESIZED_WIRE_1);


b2v_inst6 : dvi_encoder
GENERIC MAP(CTRLTOKEN0 => "1101010100",
			CTRLTOKEN1 => "0010101011",
			CTRLTOKEN2 => "0101010100",
			CTRLTOKEN3 => "1010101011"
			)
PORT MAP(clkin => clk_pix,
		 rstin => rst_n,
		 c0 => SYNTHESIZED_WIRE_20,
		 c1 => SYNTHESIZED_WIRE_20,
		 de => de,
		 din => b_din,
		 dout => SYNTHESIZED_WIRE_7);



b2v_inst8 : ddr_out
PORT MAP(outclock => clk_ddr,
		 aclr => SYNTHESIZED_WIRE_19,
		 datain_h(0) => SYNTHESIZED_WIRE_14,
		 datain_l(0) => SYNTHESIZED_WIRE_15,
		 dataout(0) => SYNTHESIZED_WIRE_8(0));


b2v_inst9 : ddr_out
PORT MAP(outclock => clk_ddr,
		 aclr => SYNTHESIZED_WIRE_19,
		 datain_h(0) => SYNTHESIZED_WIRE_17,
		 datain_l(0) => SYNTHESIZED_WIRE_18,
		 dataout(0) => SYNTHESIZED_WIRE_5(0));


END bdf_type;