library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rscomp is
	end entity;

architecture rscomp_test of rscomp is
	component rscpu is
		port(
			    clk: in std_logic;
			    reset: in std_logic;
			    addrbus: out std_logic_vector(15 downto 0);
			    databus: inout std_logic_vector(7 downto 0);
			    rd: out std_logic;
			    wr: out std_logic
		    );
	end component;

	component rsmem is
		port(
			    clk: in std_logic;
			    reset: in std_logic;
			    addrbus: in std_logic_vector(15 downto 0);
			    databus: inout std_logic_vector(7 downto 0);
			    rd: in std_logic;
			    wr: in std_logic
		    );
	end component;

	signal clk: std_logic := '0';
	signal reset: std_logic;
	signal addrbus: std_logic_vector(15 downto 0);
	signal databus: std_logic_vector(7 downto 0);
	signal rd: std_logic;
	signal wr: std_logic;

begin
	cpu_1: rscpu
	port map(
			clk => clk,
			reset => reset,
			addrbus => addrbus,  
			databus => databus,
			rd => rd,
			wr => wr
		);

	mem_1: mem
	port map(
			clk => clk,
			reset => reset,
			addrbus => addrbus,  
			databus => databus,
			rd => rd,
			wr => wr
		);

	reset <= '1', '0' after 300 ns;
	clk <= not clk after 50 ns;

end architecture;

