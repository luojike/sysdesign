library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity PC is
port( PCclk : in std_logic;
		PCin : in std_logic_vector(15 downto 0);
	   PCreset : in std_logic;
		PCload : in std_logic;
		PCinc : in std_logic;
		PCout :out std_logic_vector(15 downto 0));
end entity;

architecture rtl of PC is
	signal PCdata:std_logic_vector(15 downto 0);
	begin
	
		process(PCclk)
		begin
			if(rising_edge(PCclk)) then
				if(PCreset='1') then	
					PCdata <= "0000000000000000";
				elsif(PCload='1') then
					PCdata <= PCin;
				elsif(PCinc='1') then
					PCdata <= PCdata+1;
				end if;
			end if;
			PCout <= PCdata;
		end process;
end rtl;