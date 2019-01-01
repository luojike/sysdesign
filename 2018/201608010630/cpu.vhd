
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rsisa.all; 

entity rscpu is
	port(
		    clk: in std_logic;
		    reset: in std_logic;
		    addrbus: out std_logic_vector(15 downto 0);
		    databus: inout std_logic_vector(7 downto 0);
		    read: out std_logic;
		    write: out std_logic
	    );
end entity;

architecture rscpu_behav of rscpu is
	signal pc: std_logic_vector(15 downto 0);
	signal ac: std_logic_vector(7 downto 0);
	signal r: std_logic_vector(7 downto 0);
	signal ar: std_logic_vector(15 downto 0);
	signal ir: std_logic_vector(7 downto 0);
	signal dr: std_logic_vector(7 downto 0);
	signal tr: std_logic_vector(7 downto 0);
	signal z: std_logic;

	signal nextpc: std_logic_vector(15 downto 0);
	signal state: std_logic_vector(5 downto 0);
	signal nextstate: std_logic_vector(5 downto 0);

	constant fetch1: std_logic_vector(5 downto 0) := "000000";
	constant fetch2: std_logic_vector(5 downto 0) := "000001";
	constant fetch3: std_logic_vector(5 downto 0) := "000010";

	constant nop1: std_logic_vector(5 downto 0) := "000011";


begin
	-- address and data bus
	addrbus <= ar;
	databus <= dr when write='1' else "ZZZZZZZZ";

	-- update pc, state and other registers
	update_regs: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				pc <= X"00000000";
				state <= fetch1;
			else
				pc <= nextpc;
				state <= nextstate;
			end if;

		end if;

	end process update_regs;

	-- generate nextpc
	for_nextpc: process(ir)
		variable pc1: std_logic_vector(15 downto 0);
		variable pc3: std_logic_vector(15 downto 0);
	begin
		pc1 <= std_logic_vector(unsigned(pc) + 1);
		pc3 <= std_logic_vector(unsigned(pc) + 3);

		case ir is
			when RSJUMP =>
				nextpc <= ar;
			when RSJMPZ =>
				if(z = '1') then
					nextpc <= ar;
				else
					nextpc <= pc3;
				end if;
			when RSJPNZ =>
				if(z = '0') then
					nextpc <= ar;
				else
					nextpc <= pc3;
				end if;
			when RSLDAC =>
				nextpc <= pc3;
			when RSSTAC =>
				nextpc <= pc3;

			when others =>
				nextpc <= pc1;
		end case;

	end process for_nextpc;

	-- generate nextstate by current state and other conditions
	for_nextstate: process(state, ir)
	begin
		case state is
			when fetch1 =>
				nextstate <= fetch2;
			when fetch2 =>
				nextstate <= fetch3;
			when fetch3 =>
				case ir is
					when RSNOP =>
						nextstate <= nop1;
					-- ......
					when others =>
						nextstate <= fetch1;
				end case;

			when others =>
				nextstate <= fetch1;

		end case;

	end process for_nextstate;

	-- generate control signals for each state
	gen_controls: process(state)
	begin
		case state is
			when fetch1 =>
				-- should zero all other control signals
				arload <= '1';
				read <= '1';
			when others =>
				arload <= '0';
				-- ......
		end case;

	end process gen_controls;
end;
