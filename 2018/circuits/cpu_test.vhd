library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_test is
end entity;

architecture cpu_test_arch of cpu_test is
	constant clk_period: time := 50 ns;
	component cpu is
		port(
				clk: in std_logic;
				reset: in std_logic;
				addrbus: out std_logic_vector(31 downto 0);
				databus: inout std_logic_vector(31 downto 0);
				read: out std_logic;
				write: out std_logic
			);
	end component;

		signal clk: std_logic;
		signal reset: std_logic;
		signal addrbus: std_logic_vector(31 downto 0);
		signal databus: std_logic_vector(31 downto 0);
		signal read: std_logic;
		signal write: std_logic;
begin
	cpu_1: cpu
	port map(
			clk => clk,  
			reset => reset,  
			addrbus => addrbus,  
			databus => databus,
			read => read,
			write => write
		);

	clk_gen: process
	begin
		--clk <= not clk after 20 ns;
		for i in 1 to 100 loop
			clk<='1';  
			wait for clk_period/2;  
			clk<='0';  
			wait for clk_period/2;  
		end loop;
		wait; -- wait forever, this means stop of simulation
	end process clk_gen;

	do_reset: process
	begin
			reset <= '1', '0' after 10*clk_period;
			wait;
	end process do_reset;
end;

