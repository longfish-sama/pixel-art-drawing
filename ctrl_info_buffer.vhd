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
-- CREATED		"Thu Jan 28 19:25:49 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY ctrl_info_buffer IS 
	PORT
	(
		rst_n :  IN  STD_LOGIC;
		clk_sys :  IN  STD_LOGIC;
		clk_pix :  IN  STD_LOGIC;
		color_num_in :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		key_code :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		x_point_in :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		y_point_in :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		color_num_out :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		grid_flag :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		x_point_out :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		y_point_out :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ctrl_info_buffer;

ARCHITECTURE bdf_type OF ctrl_info_buffer IS 

COMPONENT ctrl_ram_rd
	PORT(clk_pix : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 rd_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 add_rd : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 color_num : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 grid_flag : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 x_point : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 y_point : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ctrl_ram
	PORT(wren : IN STD_LOGIC;
		 wrclock : IN STD_LOGIC;
		 rdclock : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rdaddress : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 wraddress : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ctrl_ram_wr
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 color_num : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 key_code : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 x_point : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 y_point : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_en : OUT STD_LOGIC;
		 add_wr : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 ctrl_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(1 DOWNTO 0);


BEGIN 



b2v_inst : ctrl_ram_rd
PORT MAP(clk_pix => clk_pix,
		 rst => rst_n,
		 rd_data => SYNTHESIZED_WIRE_0,
		 add_rd => SYNTHESIZED_WIRE_3,
		 color_num => color_num_out,
		 grid_flag => grid_flag,
		 x_point => x_point_out,
		 y_point => y_point_out);


b2v_inst13 : ctrl_ram
PORT MAP(wren => SYNTHESIZED_WIRE_1,
		 wrclock => clk_sys,
		 rdclock => clk_pix,
		 data => SYNTHESIZED_WIRE_2,
		 rdaddress => SYNTHESIZED_WIRE_3,
		 wraddress => SYNTHESIZED_WIRE_4,
		 q => SYNTHESIZED_WIRE_0);


b2v_inst4 : ctrl_ram_wr
PORT MAP(clk => clk_sys,
		 rst => rst_n,
		 color_num => color_num_in,
		 key_code => key_code,
		 x_point => x_point_in,
		 y_point => y_point_in,
		 wr_en => SYNTHESIZED_WIRE_1,
		 add_wr => SYNTHESIZED_WIRE_4,
		 ctrl_data => SYNTHESIZED_WIRE_2);


END bdf_type;