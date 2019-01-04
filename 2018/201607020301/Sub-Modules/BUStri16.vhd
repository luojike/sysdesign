library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity BUStri16 is 
port( input : in std_logic_vector(15 downto 0);
		enable : in std_logic;
		output : out std_logic_vector(15 downto 0));
end BUStri16;

architecture rtl of BUStri16 is
begin
	process(input,enable)
	begin
		if(enable='1') then
			output <= input;
		else
			output <= "ZZZZZZZZZZZZZZZZ";
		end if;
	end process;
end rtl;