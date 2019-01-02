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

COMPONENT mem
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 read_0 : IN STD_LOGIC;
		 write_0 : IN STD_LOGIC;
		 addrbus : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT cpu
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 read_0 : OUT STD_LOGIC;
		 write_0 : OUT STD_LOGIC;
		 addrbus : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	gdfx_temp0 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(15 DOWNTO 0);


BEGIN 
addrbus <= SYNTHESIZED_WIRE_2;



b2v_inst : mem
PORT MAP(clk => CLK,
		 reset => Reset,
		 read_0 => SYNTHESIZED_WIRE_0,
		 write_0 => SYNTHESIZED_WIRE_1,
		 addrbus => SYNTHESIZED_WIRE_2,
		 databus => gdfx_temp0);


b2v_inst2 : cpu
PORT MAP(clk => CLK,
		 reset => Reset,
		 databus => gdfx_temp0,
		 read_0 => SYNTHESIZED_WIRE_0,
		 write_0 => SYNTHESIZED_WIRE_1,
		 addrbus => SYNTHESIZED_WIRE_2);

databus <= gdfx_temp0;

END bdf_type;
