library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
		port(
      clk: in std_logic;
			addrbus: in std_logic_vector(15 downto 0);
			databus: inout std_logic_vector(7 downto 0);
			read: in std_logic;
			write: in std_logic
			);
end entity;

architecture mem_behav of mem is
    signal dr: std_logic_vector(7 downto 0);
    signal data: std_logic_vector(7 downto 0);
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
    update_dr: process(clk)
    begin
        if(rising_edge(clk)) then
            dr <= data;
        end if;
    end process;

    databus <= dr;

    data <= memdata(to_integer(addrbus)) when read='1' else "ZZZZZZZZ";

end architecture;
