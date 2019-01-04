library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ALU is
port( ACin : in std_logic_vector(7 downto 0);
		BUSin : in std_logic_vector(7 downto 0);
		ALUs : in std_logic_vector(1 downto 0);
		ALUout : out std_logic_vector(7 downto 0));
end ALU;

architecture rtl of ALU is
	begin
	
	process(ACin,BUSin,ALUs)
	begin	
		if(ALUs="01") then
			ALUout <= ACin+BUSin;
		elsif(ALUs="10") then	
			ALUout <= ACin-BUSin;
		end if;
	end process;
end rtl;
