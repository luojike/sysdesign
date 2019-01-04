library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity R is
port( Rclk : in std_logic;
		Rin : in std_logic_vector(7 downto 0);
		Rreset : in std_logic;
		Rload : in std_logic;
		Rout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of R is
	signal Rdata:std_logic_vector(7 downto 0);
	begin
	
		process(Rclk)
		begin
			if(rising_edge(Rclk)) then
				if(Rreset='1') then	
					Rdata <= "00000000";
				elsif(Rload='1') then
					Rdata <= Rin;
				end if;
			end if;
			Rout <= Rdata;
		end process;
end rtl;