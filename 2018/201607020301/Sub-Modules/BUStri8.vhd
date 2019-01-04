library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity BUStri8 is 
port( input : in std_logic_vector(7 downto 0);
		enable : in std_logic;
		output : out std_logic_vector(7 downto 0));
end BUStri8;

architecture rtl of BUStri8 is
begin
	process(input,enable)
	begin
		if(enable='1') then
			output <= input;
		else
			output <= "ZZZZZZZZ";
		end if;
	end process;
end rtl;