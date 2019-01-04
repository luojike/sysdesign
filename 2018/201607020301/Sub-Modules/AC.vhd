library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity AC is
port( ACclk : in std_logic;
		ACin : in std_logic_vector(7 downto 0);
		ACreset : in std_logic;
		ACload : in std_logic;
		ACinc : in std_logic;
		ACout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of AC is
	signal ACdata:std_logic_vector(7 downto 0);
	begin
	
		process(ACclk)
		begin
			if(rising_edge(ACclk)) then
				if(ACreset='1') then
					ACdata <= "00000000";
				elsif(ACload='1') then
					ACdata <= ACin;
				elsif(ACinc='1') then
					ACdata <= ACdata+1;
				end if;
			end if;
			ACout <= ACdata;
		end process;
end rtl;
