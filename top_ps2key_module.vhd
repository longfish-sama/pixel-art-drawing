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
-- CREATED		"Thu Jan 28 19:22:39 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY top_ps2key_module IS 
	PORT
	(
		clk_sys :  IN  STD_LOGIC;
		clk_ps2 :  IN  STD_LOGIC;
		data_in_ps2 :  IN  STD_LOGIC;
		rst_n :  IN  STD_LOGIC;
		ctrl :  OUT  STD_LOGIC;
		key_code_out :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END top_ps2key_module;

ARCHITECTURE bdf_type OF top_ps2key_module IS 

COMPONENT ps2_decode
	PORT(clk_sys : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 code_in_ps2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ctrl : OUT STD_LOGIC;
		 key_code_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ps2_read_2
	PORT(clk_sys : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 clk_ps2 : IN STD_LOGIC;
		 data_in_ps2 : IN STD_LOGIC;
		 data_out_ps2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN 



b2v_inst1 : ps2_decode
PORT MAP(clk_sys => clk_sys,
		 rst => rst_n,
		 code_in_ps2 => SYNTHESIZED_WIRE_0,
		 ctrl => ctrl,
		 key_code_out => key_code_out);


b2v_inst2 : ps2_read_2
PORT MAP(clk_sys => clk_sys,
		 rst => rst_n,
		 clk_ps2 => clk_ps2,
		 data_in_ps2 => data_in_ps2,
		 data_out_ps2 => SYNTHESIZED_WIRE_0);


END bdf_type;