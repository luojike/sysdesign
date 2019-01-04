library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity AR is
port( ARclk : in std_logic;
		ARin : in std_logic_vector(15 downto 0);
	   ARreset : in std_logic;
		ARload : in std_logic;
		ARinc : in std_logic;
		ARout :out std_logic_vector(15 downto 0));
end entity;

architecture rtl of AR is
	signal ARdata:std_logic_vector(15 downto 0);
	begin
	
		process(ARclk)
		begin
			if(rising_edge(ARclk)) then
				if(ARreset='1') then
					ARdata <= "0000000000000000";
				elsif(ARload='1') then
					ARdata <= ARin;
				elsif(ARinc='1') then
					ARdata <= ARdata+1;
				end if;
			end if;
			ARout <= ARdata;
		end process;
end rtl;
		