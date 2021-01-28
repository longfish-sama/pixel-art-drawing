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
-- CREATED		"Thu Jan 28 19:24:44 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY top_smg_display IS 
	PORT
	(
		clk_sys :  IN  STD_LOGIC;
		rst_n :  IN  STD_LOGIC;
		color_num :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		x_point :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		y_point :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		dig :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		sel :  OUT  STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END top_smg_display;

ARCHITECTURE bdf_type OF top_smg_display IS 

COMPONENT ctrl_info_to_smg_data
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 color_num : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 x_point : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 y_point : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 smg_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
	);
END COMPONENT;

COMPONENT smg_6
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 dig : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 sel : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(23 DOWNTO 0);


BEGIN 



b2v_inst : ctrl_info_to_smg_data
PORT MAP(clk => clk_sys,
		 rst => rst_n,
		 color_num => color_num,
		 x_point => x_point,
		 y_point => y_point,
		 smg_out => SYNTHESIZED_WIRE_0);


b2v_inst6 : smg_6
PORT MAP(clk => clk_sys,
		 rst => rst_n,
		 data => SYNTHESIZED_WIRE_0,
		 dig => dig,
		 sel => sel);


END bdf_type;