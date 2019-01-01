library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ALU is
port( AC_in : in std_logic_vector(7 downto 0);
		BUS_in : in std_logic_vector(7 downto 0);
		s : in std_logic_vector(1 downto 0);
		cout : out std_logic_vector(7 downto 0));
end ALU;

architecture rtl of ALU is
	begin
	
	process(AC_in,BUS_in,s)
	begin	
		if(s="01") then
			cout <= AC_in+BUS_in;
		elsif(s="10") then	
			cout <= AC_in-BUS_in;
		end if;
	end process;
end rtl;
