library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rsisa.all;  -- constants of instruction opcodes

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
	signal alu: std_logic_vector(7 downto 0);
	signal alu1: std_logic_vector(7 downto 0);
	signal alu2: std_logic_vector(7 downto 0);
	signal z: std_logic;
	signal membus: std_logic;
	signal busmem: std_logic;
	
	signal bbus: std_logic_vector(15 downto 0);

	signal nextpc: std_logic_vector(15 downto 0);
	signal state: std_logic_vector(5 downto 0);
	signal nextstate: std_logic_vector(5 downto 0);
	
	--control signal
	signal arload: std_logic;
	signal arinc: std_logic;
	signal pcload: std_logic;
	signal pcinc: std_logic;
	signal pcbus: std_logic;
	signal drload: std_logic;
	signal drhbus: std_logic;
	signal drlbus: std_logic;
	signal trload: std_logic;
	signal trbus: std_logic;
	signal irload: std_logic;
	signal rload: std_logic;
	signal rbus: std_logic;
	signal alus: std_logic_vector(7 downto 1);
	signal acload: std_logic;
	signal acbus: std_logic;
	signal zload: std_logic;
	

	--state table
	constant fetch1: std_logic_vector(5 downto 0) := "000000";
	constant fetch2: std_logic_vector(5 downto 0) := "000001";
	constant fetch3: std_logic_vector(5 downto 0) := "000010";

	constant nop1: std_logic_vector(5 downto 0) := "000011";
	constant ldac1: std_logic_vector(5 downto 0) := "000100";
	constant ldac2: std_logic_vector(5 downto 0) := "000101";
	constant ldac3: std_logic_vector(5 downto 0) := "000110";
	constant ldac4: std_logic_vector(5 downto 0) := "000111";
	constant ldac5: std_logic_vector(5 downto 0) := "001000";
	constant stac1: std_logic_vector(5 downto 0) := "001001";
	constant stac2: std_logic_vector(5 downto 0) := "001010";
	constant stac3: std_logic_vector(5 downto 0) := "001011";
	constant stac4: std_logic_vector(5 downto 0) := "001100";
	constant stac5: std_logic_vector(5 downto 0) := "001101";
	constant mvac1: std_logic_vector(5 downto 0) := "001110";
	constant movr1: std_logic_vector(5 downto 0) := "001111";
	constant jump1: std_logic_vector(5 downto 0) := "010000";
	constant jump2: std_logic_vector(5 downto 0) := "010001";
	constant jump3: std_logic_vector(5 downto 0) := "010010";
	constant jmpzy1: std_logic_vector(5 downto 0) := "010011";
	constant jmpzy2: std_logic_vector(5 downto 0) := "010100";
	constant jmpzy3: std_logic_vector(5 downto 0) := "010101";
	constant jmpzn1: std_logic_vector(5 downto 0) := "010110";
	constant jmpzn2: std_logic_vector(5 downto 0) := "010111";
	constant jpnzy1: std_logic_vector(5 downto 0) := "011000";
	constant jpnzy2: std_logic_vector(5 downto 0) := "011001";
	constant jpnzy3: std_logic_vector(5 downto 0) := "011010";
	constant jpnzn1: std_logic_vector(5 downto 0) := "011011";
	constant jpnzn2: std_logic_vector(5 downto 0) := "011100";
	constant add1: std_logic_vector(5 downto 0) := "011101";
	constant sub1: std_logic_vector(5 downto 0) := "011110";
	constant inac1: std_logic_vector(5 downto 0) := "011111";
	constant clac1: std_logic_vector(5 downto 0) := "100000";
	constant and1: std_logic_vector(5 downto 0) := "100001";
	constant or1: std_logic_vector(5 downto 0) := "100010";
	constant xor1: std_logic_vector(5 downto 0) := "100011";
	constant not1: std_logic_vector(5 downto 0) := "100100";

begin
	-- address and data bus
	addrbus <= ar;
	addrbus <= bbus(7 downto 0) when busmem ='1' else "ZZZZZZZZ";
	bbus <= "00000000" & addrbus when membus ='1' else "ZZZZZZZZZZZZZZZZ";
	bbus <= "00000000" & dr when (drlbus ='1' and trbus ='0') else "ZZZZZZZZZZZZZZZZ";
	bbus <= dr & "00000000" when (drhbus ='1' and trbus ='0') else "ZZZZZZZZZZZZZZZZ";
	bbus <= pc when  pcbus ='1' else "ZZZZZZZZZZZZZZZZ";
	bbus <= "00000000" & tr when (drlbus ='0' and trbus ='1' and drhbus ='0') else "ZZZZZZZZZZZZZZZZ";
	bbus <= dr & tr when (drhbus ='1' and trbus ='1') else "ZZZZZZZZZZZZZZZZ";
	bbus <= tr & dr when (drlbus ='1' and trbus ='1') else "ZZZZZZZZZZZZZZZZ";
	bbus <= "00000000" & r when rbus ='1' else "ZZZZZZZZZZZZZZZZ";
	bbus <= "00000000" & ac when acbus ='1' else "ZZZZZZZZZZZZZZZZ";
	alu1 <= bbus(7 downto 0);
	alu2 <= ac;
	case alus is
		when add1 =>
			alu <= alu2 + alu1;
		when sub1 =>
			alu <= alu2 - alu1;
		when inac1 =>
			alu <= alu2 + "00000001";
		when clac1 =>
			alu <= "00000000";
		when and1 =>
			alu <= alu2 and alu1;
		when or1 =>
			alu <= alu2 or alu1;
		when xor1 =>
			alu <= alu2 xor alu1;
		when not1 =>
			alu <= not alu2;
		when others =>
			alu <= alu1;
	end case;
	-- update pc, state and other registers
	update_regs: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				pc <= "0000000000000000";
				state <= fetch1;
			else
				pc <= nextpc;
				state <= nextstate;
			end if;
			if(arload='1') then 
				ar <= bbus;
			else if(arinc='1') then
				ar <= ar + 1;
			else
				ar <= ar;
			end if;
			if(pcload='1') then 
				pc <= bbus;
			else if(pcinc='1') then
				pc <= pc + 1;
			else
				pc <= pc;
			end if;
			if(drload='1') then 
				dr <= bbus(7 downto 0);
			else
				dr <= "ZZZZZZZZ";
			end if;
			if(trload='1') then 
				tr <= dr;
			else
				tr <= "ZZZZZZZZ";
			end if;
			if(irload='1') then 
				ir <= dr;
			else
				ir <= "ZZZZZZZZ";
			end if;
			if(rload='1') then 
				r <= bbus(7 downto 0);
			else
				r <= "ZZZZZZZZ";
			end if;
			if(acload = '1') then
				ac <= alu;
			else
				ac <= "ZZZZZZZZ";
			end if;
			if(zload = '1') then
				z <= xor alu;
			else
				z <= 'Z';
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
					when RSLDAC =>
						nextstate <= ldac1;
					when RSSTAC => 
						nextstate <= stac1;
					when RSMVAC => 
						nextstate <= mvac1;
					when RSMOVR =>
						nextstate <= movr1;
					when RSJUMP =>
						nextstate <= jump1;
					when RSJMPZ =>
						if(z = '1') then
							nextstate <= jmpzy1;
						else
							nextstate <= jmpzn1;
						end if;
					when RSJPNZ =>
						if(z = '1') then
							nextstate <= jpnzy1;
						else
							nextstate <= jpnzn1;
						end if;
					when RSADD =>
						nextstate <= add1;
					when RSSUB =>
						nextstate <= sub1;
					when RSINAC =>
						nextstate <= inac1;
					when RSCLAC =>
						nextstate <= clac1;
					when RSAND =>
						nextstate <= and1;
					when RSOR =>
						nextstate <= or1;
					when RSXOR =>
						nextstate <= xor1;
					when RSNOT =>
						nextstate <= not1;
					when others =>
						nextstate <= fetch1;
				end case;
			when ldac1 =>
				nextstate <= ldac2;
			when ldac2 =>
				nextstate <= ldac3;
			when ldac3 =>
				nextstate <= ldac4;
			when ldac4 =>
				nextstate <= ldac5;
			when stac1 =>
				nextstate <= stac2;
			when stac2 =>
				nextstate <= stac3;
			when stac3 =>
				nextstate <= stac4;
			when stac4 =>
				nextstate <= stac5;
			when jump1 =>
				nextstate <=jump2;
			when jump2 =>
				nextstate <=jump3;
			when jmpzy1 =>
				nextstate <=jmpzy2;
			when jmpzy2 =>
				nextstate <=jmpzy3;
			when jmpzn1 =>
				nextstate <= jmpzn2;
			when jpnzy1 =>
				nextstate <=jpnzy2;
			when jpnzy2 =>
				nextstate <=jpnzy3;
			when jpnzn1 =>
				nextstate <= jpnzn2;
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
				pcbus <= '1';
			when fetch2 =>
				membus <= '1';
				drload <= '1';
				pcinc <= '1';
				read <= '1';
			when fetch3 =>
				irload <= '1';
				arload <= '1'; 
				pcbus <= '1';
			when ldac1 =>
				membus <= '1';
				drload <= '1';
				pcinc <= '1';
				arinc <= '1';
				read <= '1';
			when ldac2 =>
				trload <= '1';
				membus <= '1';
				drload <= '1';
				pcinc <= '1';
				read <= '1';
			when ldac3 =>
				arload <= '1';
				drhbus <= '1';
				trbus <= '1';
			when ldac4 =>
				membus <= '1';
				drload <= '1';
				read <= '1';
			when ldac5 =>
				acload <= '1';
				drlbus <= '1';
			when stac1 =>
				drload <= '1';
				membus <= '1';
				pcinc <= '1';
				arinc <= '1';
				read <= '1';
			when stac2 =>
				trload <= '1';
				drload <= '1';
				membus <= '1';
				pcinc <= '1';
				read <= '1';
			when stac3 =>
				arload <= '1';
				drhbus <= '1';
				trbus <= '1';
			when stac4 =>
				drload <= '1';
				acbus <= '1';
			when stac5 =>
				busmem <= '1';
				drlbus <= '1';
				write <= '1';
			when mvac1 =>
				rload <= '1';
				acbus <= '1';
			when movr1 =>
				acload <= '1';
				rbus <= '1';
			when jump1 =>
				drload <= '1';
				membus <= '1';
				arinc <= '1';
				read <= '1';
			when jump2 =>
				trload <= '1';
				drload <= '1';
				membus <= '1';
				read <= '1';
			when jump3 =>
				pcload <= '1';
				drhbus <= '1';
				trbus <= '1';
			when jmpzy1 =>
				drload <= '1';
				membus <= '1';
				arinc <= '1';
				read <= '1';
			when jmpzy2 =>
				trload <= '1';
				drload <= '1';
				membus <= '1';
				read <= '1';
			when jmpzy3 =>
				pcload <= '1';
				drhbus <= '1';
				trbus <= '1';
			when jmpzn1 =>
				pcinc <= '1';
			when jmpzn2 =>
				pcinc <= '1';
			when jpnzy1 =>
				drload <= '1';
				membus <= '1';
				arinc <= '1';
				read <= '1';
			when jpnzy2 =>
				trload <= '1';
				drload <= '1';
				membus <= '1';
				read <= '1';
			when jpnzy3 =>
				pcload <= '1';
				drhbus <= '1';
				trbus <= '1';
			when jpnzn1 =>
				pcinc <= '1';
			when jpnzn2 =>
				pcinc <= '1';
			when add1 =>
				acload <= '1';
				zload <= '1';
				alus <= add1;
			when sub1=>
				acload <= '1';
				zload <= '1';
				alus <= sub1;
			when inac1 =>
				acload <= '1';
				zload <= '1';
				alus <= inac1;
			when clac1 =>
				acload <= '1';
				alus <= clac1;
			when and1 =>
				acload <= '1';
				zload <= '1';
				alus <= and1;
			when or1 =>
				acload <= '1';
				zload <= '1';
				alus <= or1;
			when xor1 =>
				acload <= '1';
				zload <= '1';
				alus <= xor1;
			when not1 =>
				acload <= '1';
				zload <= '1';
				alus <= not1;
			when others =>
				read <= 'Z';
				write <= 'Z';
				arload <= 'Z';
				arinc <= 'Z';
				pcload <= 'Z';
				pcinc <= 'Z';
				pcbus <= 'Z';
				drload <= 'Z';
				drhbus <= 'Z';
				drlbus <= 'Z';
				trload <= 'Z';
				trbus <= 'Z';
				irload <= 'Z';
				rload <= 'Z';
				rbus <= 'Z';
				alus <= "ZZZZZZ";
				acload <= 'Z';
				acbus <= 'Z';
				zload <= 'Z';
				membus <= 'Z';
				busmem <= 'Z';
		end case;

	end process gen_controls;
end;

