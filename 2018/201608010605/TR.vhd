library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity TR is
port( clk : in std_logic;
		cin : in std_logic_vector(7 downto 0);
		reset : in std_logic;
		load : in std_logic;
		cout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of TR is
	signal TRdata:std_logic_vector(7 downto 0);
	begin
	
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					TRdata <= "00000000";
				elsif(TRload='1') then
					TRdata <= cin;
				end if;
			end if;
			cout <= TRdata;
		end process;
end rtl;
		