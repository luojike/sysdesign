library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity DR is
port( DRclk : in std_logic;
		DRin : in std_logic_vector(7 downto 0);
	   DRreset : in std_logic;
		DRload : in std_logic;
		DRout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of DR is
	signal DRdata:std_logic_vector(7 downto 0);
	begin
	
		process(DRclk)
		begin
			if(rising_edge(DRclk)) then
				if(DRreset='1') then
					DRdata <= "00000000";
				elsif(DRload='1') then
					DRdata <= DRin;
				end if;
			end if;
			DRout <= DRdata;
		end process;
end rtl;