library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_test is
end entity;

architecture mem_test_arch of mem_test is
	constant td: time := 50 ns;
	component mem is
		port(
			addrbus: in std_logic_vector(31 downto 0);
			databus: inout std_logic_vector(31 downto 0);
			read: in std_logic;
			write: in std_logic
			);
	end component;

	signal addrbus: std_logic_vector(31 downto 0);
	signal databus: std_logic_vector(31 downto 0);
	signal read: std_logic;
	signal write: std_logic;
begin
	mem_1: mem
	port map(
			addrbus => addrbus,  
			databus => databus,
			read => read,
			write => write
		);

	read <= '1', '0' after 12*td;

	addr_gen: process
	begin
		for i in 0 to 15 loop
			addrbus <= std_logic_vector(to_unsigned(i, 32));  
			wait for td;
		end loop;
		wait; -- wait forever, this means stop of simulation
	end process addr_gen;

end;

