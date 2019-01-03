library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity TR is
port( TRclk : in std_logic;
		TRin : in std_logic_vector(7 downto 0);
		TRreset : in std_logic;
		TRload : in std_logic;
		TRout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of TR is
	signal TRdata:std_logic_vector(7 downto 0);
	begin
	
		process(TRclk)
		begin
			if(rising_edge(TRclk)) then
				if(TRreset='1') then
					TRdata <= "00000000";
				elsif(TRload='1') then
					TRdata <= TRin;
				end if;
			end if;
			TRout <= TRdata;
		end process;
end rtl;
		