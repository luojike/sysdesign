library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity R is
port( clk : in std_logic;
		cin : in std_logic_vector(7 downto 0);
		reset : in std_logic;
		load : in std_logic;
		cout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of R is
	signal Rdata:std_logic_vector(7 downto 0);
	begin
	
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(reset='1') then	
					Rdata <= "00000000";
				elsif(load='1') then
					Rdata <= cin;
				end if;
			end if;
			cout <= Rdata;
		end process;
end rtl;