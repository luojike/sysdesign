library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity AC is
port( clk : in std_logic;
		cin : in std_logic_vector(7 downto 0);
		reset : in std_logic;
		load : in std_logic;
		inc : in std_logic;
		cout :out std_logic_vector(7 downto 0));
end entity;

architecture rtl of AC is
	signal ACdata:std_logic_vector(7 downto 0);
	begin
	
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(reset='1') then
					ACdata <= "00000000";
				elsif(load='1') then
					ACdata <= cin;
				elsif(inc='1') then
					ACdata <= ACdata+1;
				end if;
			end if;
			cout <= ACdata;
		end process;
end rtl;
		