library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp is
	port(
		    clk: in std_logic;
		    reset: in std_logic;
		    addrbus: out std_logic_vector(15 downto 0);
		    databus: inout std_logic_vector(7 downto 0);
		    read: out std_logic;
		    write: out std_logic
	    );
end entity;

architecture comp_test of comp is
	component cpu is
		port(
			    clk: in std_logic;
			    reset: in std_logic;
			    addrbus: out std_logic_vector(15 downto 0);
			    databus: inout std_logic_vector(7 downto 0);
			    read: out std_logic;
			    write: out std_logic
		    );
	end component;

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

	mem_1: mem
	port map(
			clk => clk,
			reset => reset,
			addrbus => addrbus,  
			databus => databus,
			read => read,
			write => write
		);

end architecture;
