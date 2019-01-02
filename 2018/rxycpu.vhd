LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY rxycpu IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		address :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		dat :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		res :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END rxycpu;

ARCHITECTURE rscompcom OF rxycpu IS 

COMPONENT rsmem
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rd : IN STD_LOGIC;
		 we : IN STD_LOGIC;
		 addrbus : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT cpu
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 databus : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 rd : OUT STD_LOGIC;
		 we : OUT STD_LOGIC;
		 addrbus : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	addr :  STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL	data :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rd :  STD_LOGIC;
SIGNAL	result :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	we :  STD_LOGIC;


BEGIN 



rsmem1 : rsmem
PORT MAP(clk => clk,
		 reset => reset,
		 rd => rd,
		 we => we,
		 addrbus => addr,
		 databus => data,
		 result => result);


cpu1: cpu
PORT MAP(clk => clk,
		 reset => reset,
		 databus => data,
		 rd => rd,
		 we => we,
		 addrbus => addr);

address <= addr;
dat <= data;
res <= result;

END ;
