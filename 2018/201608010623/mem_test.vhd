library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_test is
	end entity;

architecture mem_test_arch of rsmem_test is
	constant td: time := 20 ns;
	constant n: integer := 100;
	component mem is
		port(
			    clk: in std_logic;
			    reset: in std_logic;
			    addrbus: in std_logic_vector(15 downto 0);
			    databus: inout std_logic_vector(7 downto 0);
			    read: in std_logic;
			    write: in std_logic
		    );
	end component;

	signal clk: std_logic := '0';
	signal reset: std_logic;
	signal addrbus: std_logic_vector(15 downto 0);
	signal databus: std_logic_vector(7 downto 0);
	signal read: std_logic;
	signal write: std_logic;
begin
	mem_1: mem
	port map(
			clk => clk,  
			reset => reset,
			addrbus => addrbus,  
			databus => databus,
			read => read,
			write => write
		);

	clk <= not clk after td/2;
	reset <= '1', '0' after 5*td;

	access_gen: process
	begin
		for i in 0 to n loop
			addrbus <= std_logic_vector(to_unsigned(i mod 32, 16));  
			read <= '1';
			write <= '0';
			wait for td;
		end loop;
		wait; -- wait forever, this means stop of simulation
	end process access_gen;

end;
