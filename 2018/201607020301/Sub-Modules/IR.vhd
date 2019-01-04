library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity IR is
port( IRclk : in std_logic;
		IRin : in std_logic_vector(7 downto 0);
		IRreset : in std_logic;
		IRload : in std_logic;
		IRout : out std_logic_vector(7 downto 0));
end entity;

architecture rtl of IR is
	signal IRdata:std_logic_vector(7 downto 0);
	begin
	
		process(IRclk)
		begin
			if(rising_edge(IRclk)) then
				if(IRreset='1') then
					IRdata <= "00000000";
				elsif(IRload='1') then
					IRdata <= IRin;
				end if;
			end if;
		IRout <= IRdata;
		end process;
end rtl;
		