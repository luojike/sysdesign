library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;





package instruc is

	

	-- RS prefix is used to avoid tautonym such like AND, OR, XOR, NOT

	constant RSNOP: std_logic_vector(7 downto 0) := "00000000";

	constant RSLDAC: std_logic_vector(7 downto 0) := "00000001";

	constant RSSTAC: std_logic_vector(7 downto 0) := "00000010";

	constant RSMVAC: std_logic_vector(7 downto 0) := "00000011";

	constant RSMOVR: std_logic_vector(7 downto 0) := "00000100";

	constant RSJUMP: std_logic_vector(7 downto 0) := "00000101";

	constant RSJMPZ: std_logic_vector(7 downto 0) := "00000110";

	constant RSJPNZ: std_logic_vector(7 downto 0) := "00000111";



	constant RSADD: std_logic_vector(7 downto 0) := "00001000";

	constant RSSUB: std_logic_vector(7 downto 0) := "00001001";

	constant RSINAC: std_logic_vector(7 downto 0) := "00001010";

	constant RSCLAC: std_logic_vector(7 downto 0) := "00001011";

	constant RSAND: std_logic_vector(7 downto 0) := "00001100";

	constant RSOR: std_logic_vector(7 downto 0) := "00001101";

	constant RSXOR: std_logic_vector(7 downto 0) := "00001110";

	constant RSNOT: std_logic_vector(7 downto 0) := "00001111";



end package;
