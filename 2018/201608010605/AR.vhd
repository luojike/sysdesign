library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity AR is
port( clk : in std_logic;
		cin : in std_logic_vector(15 downto 0);
	   	reset : in std_logic;
		load : in std_logic;
		inc : in std_logic;
		cout :out std_logic_vector(15 downto 0));
end entity;

architecture rtl of AR is
	signal ARdata:std_logic_vector(15 downto 0);
	begin
	
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					ARdata <= "0000000000000000";
				elsif(ARload='1') then
					ARdata <= cin;
				elsif(ARinc='1') then
					ARdata <= ARdata+1;
				end if;
			end if;
			cout <= ARdata;
		end process;
end rtl;
		