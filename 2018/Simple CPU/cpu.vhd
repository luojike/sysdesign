library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	port(
			clk: in std_logic;
			reset: in std_logic;
			addrbus: out std_logic_vector(31 downto 0);
			databus: inout std_logic_vector(31 downto 0);
			read: out std_logic;
			write: out std_logic
		);
end entity;

architecture cpu_behav of cpu is
	type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
	signal regs: regfile(31 downto 0);
	signal pc: std_logic_vector(31 downto 0);
	signal ir: std_logic_vector(31 downto 0);
--signal next_pc: std_logic_vector(31 downto 0);

begin
	addrbus <= pc;
	read <= '1';
	ir <= databus;

	do_reset: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				pc <= X"00000000";
			else
				pc <= std_logic_vector(unsigned(pc) + 4);
			end if;
		end if;


	end process do_reset;
end;
