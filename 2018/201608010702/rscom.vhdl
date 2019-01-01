LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY recom IS 
	PORT
	(
		Clk :  IN  STD_LOGIC;
		res :  IN  STD_LOGIC;
		addrbus :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		databus :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END recom;

ARCHITECTURE bdf_type OF recom IS 

COMPONENT cpu
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd : OUT STD_LOGIC;
		 wr : OUT STD_LOGIC;
		 addrbus : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mem
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rd : IN STD_LOGIC;
		 wr : IN STD_LOGIC;
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
PORT MAP(clk => Clk,
		 reset => res,
		 databus => gdfx_temp0,
		 rd => SYNTHESIZED_WIRE_0,
		 wr => SYNTHESIZED_WIRE_1,
		 addrbus => SYNTHESIZED_WIRE_2);


b2v_inst9 : mem
PORT MAP(clk => Clk,
		 reset => res,
		 rd => SYNTHESIZED_WIRE_0,
		 wr => SYNTHESIZED_WIRE_1,
		 addrbus => SYNTHESIZED_WIRE_2,
		 databus => gdfx_temp0);

databus <= gdfx_temp0;

END bdf_type;
