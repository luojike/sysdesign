library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
	port(
		    clk: in std_logic;
		    reset: in std_logic;
		    addrbus: in std_logic_vector(15 downto 0);
		    databus: inout std_logic_vector(7 downto 0);
		    read: in std_logic;
		    write: in std_logic
	    );
end entity;

architecture mem_behav of mem is
	signal addr: std_logic_vector(15 downto 0);
	signal rw : std_logic_vector(0 to 1);
	type memtype is array(natural range<>) of std_logic_vector(7 downto 0);
	signal memdata: memtype(4095 downto 0) := (
	0 => X"04",
	1 => X"00",
	2 => X"00",
	3 => X"00",
	4 => X"08",
	5 => X"00",
	6 => X"00",
	7 => X"00",
	others => X"11"
);

begin
	-- The process takes addrbus and read/write signals at first,
	-- then at the next clock does the data transmission.
	for_clk : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				addr <= (others=>'0');
				rw <= (others=>'0');
			else
				addr <= addrbus;
				rw <= read & write;
			end if;

			if(rw(1)='1') then
				memdata(to_integer(addr)) <= databus;
			end if;
		end if;
	end process;

	databus <= memdata(to_integer(addr)) when (rw(0)='1') else (others=>'Z');

end architecture;
