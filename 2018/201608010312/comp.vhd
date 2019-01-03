-- Copyright (C) 1991-2009 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II"
-- VERSION		"Version 9.0 Build 184 04/29/2009 Service Pack 1 SJ Web Edition"
-- CREATED ON		"Wed Jan 02 08:44:06 2019"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY comp IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		Reset :  IN  STD_LOGIC;
		addrbus :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		databus :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END comp;

ARCHITECTURE bdf_type OF comp IS 

COMPONENT cpu
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 read : OUT STD_LOGIC;
		 write : OUT STD_LOGIC;
		 addrbus : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mem
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 read : IN STD_LOGIC;
		 write : IN STD_LOGIC;
		 addrbus : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	gdfx_temp0 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(15 DOWNTO 0);


BEGIN 
addrbus <= SYNTHESIZED_WIRE_2;



b2v_inst : cpu
PORT MAP(clk => CLK,
		 reset => Reset,
		 databus => gdfx_temp0,
		 read => SYNTHESIZED_WIRE_0,
		 write => SYNTHESIZED_WIRE_1,
		 addrbus => SYNTHESIZED_WIRE_2);


b2v_inst1 : mem
PORT MAP(clk => CLK,
		 reset => Reset,
		 read => SYNTHESIZED_WIRE_0,
		 write => SYNTHESIZED_WIRE_1,
		 addrbus => SYNTHESIZED_WIRE_2,
		 databus => gdfx_temp0);

databus <= gdfx_temp0;

END bdf_type;
