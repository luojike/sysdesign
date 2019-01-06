library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.instruc.all;  -- constants of instruction opcodes

entity cpu is
	port(
		    clk: in std_logic;
		    reset: in std_logic;
		    addrbus: out std_logic_vector(15 downto 0) := "0000000000000000";
		    databus: inout std_logic_vector(7 downto 0);
		    readm: out std_logic;
		    writem: out std_logic
	    );
end entity;

architecture rscpu_behav of cpu is
	-- registers
	signal pc: std_logic_vector(15 downto 0); -- Program counter
	signal ac: std_logic_vector(7 downto 0); -- accumulate calculator
	signal r: std_logic_vector(7 downto 0); -- register
	signal ar: std_logic_vector(15 downto 0); -- address register
	signal ir: std_logic_vector(7 downto 0); -- instruction register
	signal dr: std_logic_vector(7 downto 0); -- data register
	signal tr: std_logic_vector(7 downto 0); -- temp register
	signal z: std_logic; -- if zero
	
	-- control signal
	-- AR
	signal arload: std_logic;
	signal arinc: std_logic;
	
	-- PC
	signal pcload: std_logic;
	signal pcinc: std_logic;
	signal pcbus: std_logic;
	
	-- DR
	signal drload: std_logic;
	signal drhbus: std_logic;
	signal drlbus: std_logic;
	
	-- TR
	signal trload: std_logic;
	signal trbus: std_logic;
	
	-- IR
	signal irload: std_logic;
	
	-- R
	signal rload: std_logic;
	signal rbus: std_logic;
	
	-- ALU
	signal alusel: std_logic_vector(3 downto 0);
	
	-- AC
	signal acload: std_logic;
	signal acbus: std_logic;
	
	-- Z
	signal zload: std_logic;
	
	-- mem
	signal membus: std_logic;

	signal nextpc: std_logic_vector(15 downto 0) := "0000000000000000";
	signal state: std_logic_vector(5 downto 0);
	signal nextstate: std_logic_vector(5 downto 0);

	constant fetch1: std_logic_vector(5 downto 0) := "000000"; -- ar <- pc;
	constant fetch2: std_logic_vector(5 downto 0) := "000001"; -- dr <- m; pc <- pc+1;
	constant fetch3: std_logic_vector(5 downto 0) := "000010"; -- ir <- dr[7..6]; ar <- dr[5..0];
	
	constant nop1: std_logic_vector(5 downto 0) := "000011";
	
	constant LDAC1: std_logic_vector(5 downto 0) := "000100";
	constant LDAC2: std_logic_vector(5 downto 0) := "000101";
	constant LDAC3: std_logic_vector(5 downto 0) := "000110";
	constant LDAC4: std_logic_vector(5 downto 0) := "000111";
	constant LDAC5: std_logic_vector(5 downto 0) := "001000";
	
	
	constant STAC1: std_logic_vector(5 downto 0) := "001001";	
	constant STAC2: std_logic_vector(5 downto 0) := "001010";	
	constant STAC3: std_logic_vector(5 downto 0) := "001011";	
	constant STAC4: std_logic_vector(5 downto 0) := "001100";	
	constant STAC5: std_logic_vector(5 downto 0) := "001101";
	
	constant MVAC1: std_logic_vector(5 downto 0) := "001110";
	
	constant MOVR1: std_logic_vector(5 downto 0) := "001111";
	
	constant JUMP1: std_logic_vector(5 downto 0) := "010000";
	constant JUMP2: std_logic_vector(5 downto 0) := "010001";
	constant JUMP3: std_logic_vector(5 downto 0) := "010010";
	
	constant JMPZY1: std_logic_vector(5 downto 0) := "010011";
	constant JMPZY2: std_logic_vector(5 downto 0) := "010100";
	constant JMPZY3: std_logic_vector(5 downto 0) := "010101";
	
	constant JMPZN1: std_logic_vector(5 downto 0) := "010110";
	constant JMPZN2: std_logic_vector(5 downto 0) := "010111";
	
	constant JPNZY1: std_logic_vector(5 downto 0) := "011000";
	constant JPNZY2: std_logic_vector(5 downto 0) := "011001";
	constant JPNZY3: std_logic_vector(5 downto 0) := "011010";
	
	constant JPNZN1: std_logic_vector(5 downto 0) := "011011";
	constant JPNZN2: std_logic_vector(5 downto 0) := "011100";
	
	constant ADD1: std_logic_vector(5 downto 0) := "011101";
	
	constant SUB1: std_logic_vector(5 downto 0) := "011110";
	
	constant INAC1: std_logic_vector(5 downto 0) := "011111";
	
	constant CLAC1: std_logic_vector(5 downto 0) := "100000";
	
	constant AND1: std_logic_vector(5 downto 0) := "100001";
	
	constant OR1: std_logic_vector(5 downto 0) := "100010";
	
	constant XOR1: std_logic_vector(5 downto 0) := "100011";
	
	constant NOT1: std_logic_vector(5 downto 0) := "100100";

begin
	
	update_regs_pro: process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset='1') then
				pc <= "0000000000000000";
				state <= fetch1;
			else
				pc <= nextpc;
				state <= nextstate;
			end if;
		end if;
	end process update_regs_pro;
	
	-- State transition
	next_state_pro: process(state,ir,z)
	begin
		case state is
			when fetch1 =>
				nextstate <= fetch2;
			when fetch2 =>
				nextstate <= fetch3;
			when fetch3 =>
				case ir is
					-- More than one state
					when RSNOP =>
						nextstate <= NOP1;
					when RSLDAC =>
						nextstate <= LDAC1;
					when RSSTAC =>
						nextstate <= STAC1;
					when RSMVAC =>
						nextstate <= MVAC1;
					when RSMOVR =>
						nextstate <= MOVR1;
					when RSJUMP =>
						nextstate <= JUMP1;
					when RSJMPZ =>
						--if(z='0') then 
						--	nextstate <= JMPZY1;
						--else if(z='1') then
						--	nextstate <= JMPZN1;
						--end if;
						case z is
							when '0' =>
								nextstate <= JMPZY1;
							when '1' =>
								nextstate <= JMPZN1;
						end case;
					when RSJPNZ =>
						--if(z='1') then 
						--	nextstate <= JPNZY1;
						--else if(z='0') then
						--	nextstate <= JPNZN1;
						--end if;
						case z is
							when '0' =>
								nextstate <= JPNZN1;
							when '1' =>
								nextstate <= JPNZY1;
						end case;
					-- one state	
					when RSADD =>
						nextstate <= ADD1;
					when RSSUB =>
						nextstate <= SUB1;
					when RSINAC =>
						nextstate <= INAC1;
					when RSCLAC =>
						nextstate <= CLAC1;
					when RSAND =>
						nextstate <= AND1;
					when RSOR =>
						nextstate <= OR1;
					when RSXOR =>
						nextstate <= XOR1;
					when RSNOT =>
						nextstate <= NOT1;	
					when others =>
						nextstate <= fetch1;
				end case;
			-- STAC 
			when STAC1 =>
				nextstate <= STAC2;	
			when STAC2 =>
				nextstate <= STAC3;	
			when STAC3 =>
				nextstate <= STAC4;	
			when STAC4 =>
				nextstate <= STAC5;	
			-- LDAC 
			when LDAC1 =>
				nextstate <= LDAC2;	
			when LDAC2 =>
				nextstate <= LDAC3;	
			when LDAC3 =>
				nextstate <= LDAC4;
			when LDAC4 =>
				nextstate <= LDAC5;	
			-- JUMP
			when JUMP1 =>
				nextstate <= JUMP2;	
			when JUMP2 =>
				nextstate <= JUMP3;	
			-- JMPZY
			when JMPZY1 =>
				nextstate <= JMPZY2;
			when JMPZY2 =>
				nextstate <= JMPZY3;
			-- JMPZN
			when JMPZN1 =>
				nextstate <= JMPZN2;
			-- JPNZY
			when JPNZY1 =>
				nextstate <= JPNZY2;
			when JPNZY2 =>
				nextstate <= JPNZY3;
			-- JPNZN
			when JPNZN1 =>
				nextstate <= JPNZN2;
			when others =>
				nextstate <= fetch1;
		end case;
	end process next_state_pro;
	
	-- generate control signals for each state
	state_ctrl_Pro: process(state)
	begin
		case state is
			when fetch1 =>
				-- ar <- pc	
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '1';	arinc <= '0';	
				pcbus <= '1';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when fetch2 =>
				-- dr <- m; pc <- pc+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when fetch3 =>
				-- ir <- dr; ar <- pc
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '1';	arinc <= '0';	
				pcbus <= '1';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '1';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when NOP1 =>
				-- do nothing	
				
			when LDAC1 =>
				-- dr <- m; pc <- pc+1; ar <- ar+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '1';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when LDAC2 =>
				-- tr <- dr; dr <- m; pc <- pc+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '1';	drhbus <= '0';	drlbus <= '1';
				trload <= '1';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when LDAC3 =>
				-- ar <- dr,tr
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '1';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '1';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when LDAC4 =>
				-- dr <- m
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';	
			when LDAC5 =>
				-- ac <- dr
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '1';	acbus <= '0';
				zload <= '0';
			when STAC1 =>
				-- dr <- m; pc <- pc+1; ar <- ar+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '1';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when STAC2 =>
				-- tr <- dr; dr <- m; pc <- pc+1;
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '1';	drhbus <= '0';	drlbus <= '1';
				trload <= '1';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when STAC3 =>
				-- ar <- dr,tr
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '1';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '1';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when STAC4 =>
				-- dr <- ac
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '1';
				zload <= '0';
			when STAC5 =>
				-- m <- dr
				readm <= '0';	writem <= '1';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when MVAC1 =>
				-- r <- ac
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '1';	rbus <= '0';
				acload <= '0';	acbus <= '1';
				zload <= '0';
			when MOVR1 =>
				-- ac <- r
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '1';
				acload <= '1';	acbus <= '0';
				zload <= '0';
			when JUMP1 =>
				-- dr <- m; ar <- ar+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '1';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JUMP2 =>
				-- tr <- dr; dr <- m
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '1';
				trload <= '1';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JUMP3 =>
				-- pc <- dr,tr
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '1';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '1';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JMPZY1 =>
				-- dr <- m; ar <- ar+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '1';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JMPZY2 =>
				-- tr <- dr; dr <- m
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '1';
				trload <= '1';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JMPZY3 =>
				-- pc <- dr,tr
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '1';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '1';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JMPZN1 =>
				-- pc <- pc+1
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JMPZN2 =>
				-- pc <- pc+1
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JPNZY1 =>
				-- dr <- m; ar <- ar+1
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '1';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JPNZY2 =>
				-- tr <- dr; dr <- m
				readm <= '1';	writem <= '0';	membus <= '1';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '1';	drhbus <= '0';	drlbus <= '1';
				trload <= '1';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JPNZY3 =>
				-- pc <- dr,tr
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '1';	pcinc <= '0';
				drload <= '0';	drhbus <= '1';	drlbus <= '0';
				trload <= '0';	trbus <= '1';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JPNZN1 =>
				-- pc <- pc+1
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when JPNZN2 =>
				-- pc <- pc+1
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '1';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
			when ADD1 =>
				-- ac <- ac+r; if(ac+r=0) z<-1 else z<-0	
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '1';
				acload <= '1';	acbus <= '1';
				zload <= '1';
				alusel <= "0001";
			when SUB1 =>
				-- ac <- ac-r; if(ac-r=0) z<-1 else z<-0	
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '1';
				acload <= '1';	acbus <= '1';
				zload <= '1';
				alusel <= "0010";
			when INAC1 =>
				-- ac <- ac+1; if(ac+1=0) z<-1 else z<-0	
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '1';	acbus <= '1';
				zload <= '1';
				alusel <= "0011";
			when CLAC1 =>
				-- ac <- 0; z <- 1	
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '1';	acbus <= '0';
				zload <= '1';
				alusel <= "0100";
			when AND1 =>
				-- ac <- ac and r; if(ac and r=0) z<-1 else z<-0
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '1';
				acload <= '1';	acbus <= '1';
				zload <= '1';
				alusel <= "0101";
			when OR1 =>
				-- ac <- ac or r; if(ac or r=0) z<-1 else z<-0
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '1';
				acload <= '1';	acbus <= '1';
				zload <= '1';
				alusel <= "0110";
			when XOR1 =>
				-- ac <- ac^r; if(ac^r=0) z<-1 else z<-0
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '1';
				acload <= '1';	acbus <= '1';
				zload <= '0';
				alusel <= "0111";
			when NOT1 =>
				-- ac <- ac'; if(ac'=0) z<-1 else z<-0
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '1';	acbus <= '1';
				zload <= '1';
				alusel <= "1000";
			when others =>
				readm <= '0';	writem <= '0';	membus <= '0';
				arload <= '0';	arinc <= '0';	
				pcbus <= '0';	pcload <= '0';	pcinc <= '0';
				drload <= '0';	drhbus <= '0';	drlbus <= '0';
				trload <= '0';	trbus <= '0';
				irload <= '0';
				rload <= '0';	rbus <= '0';
				acload <= '0';	acbus <= '0';
				zload <= '0';
				alusel <= "0000";
		end case;
	end process state_ctrl_Pro;
	
	signal_control: process(clk)
	begin
		if(rising_edge(clk)) then
			if(arload='1') then
				if(pcbus='1') then
					ar <= pc;
				end if;
				if(drlbus='1') then
					ar(15 downto 8) <= databus;
				end if;
				if(trbus='1') then
					ar(7 downto 0) <= databus;
				end if;
			end if;	
			
			if(arinc='1') then
				ar <= std_logic_vector(unsigned(ar) + 1);
			end if;	
			
			if(pcbus='1') then
				ar <= pc;
			end if;	
			
			if(pcload='1') then
				if(drlbus='1') then
					pc(15 downto 8) <= databus;
				end if;
				if(trbus='1') then
					pc(7 downto 0) <= databus;
				end if;
			end if;
			
			if(pcinc='1') then
				pc <= std_logic_vector(unsigned(pc) + 1);
			end if;	
			
			if(drload='1') then
				dr <= databus;
			end if;	
			
			if(drhbus='1') then
				databus <= dr;
			end if;	
			
			if(drlbus='1') then
				databus <= dr;
			end if;	
			
			if(trload='1') then
				tr <= databus;
			end if;	
			
			if(trbus='1') then
				databus <= tr;
			end if;	
			
			if(irload='1') then
				ir <= databus;
			end if;	
			
			if(rload='1') then
				r <= databus;
			end if;	
			
			if(rbus='1') then
				databus <= r;
			end if;	
			
			if(acload='1') then
				ac <= databus;
			end if;	
			
			if(acbus='1') then
				databus <= ac;
			end if;	
			
			if(alusel="0001") then
				ac <= std_logic_vector(unsigned(ac) + unsigned(r));
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			elsif(alusel="0010") then
				ac <= std_logic_vector(unsigned(ac) - unsigned(r));
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			elsif(alusel="0011") then
				ac <= std_logic_vector(unsigned(ac) + 1);
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			elsif(alusel="0100") then
				ac <= "00000000";
				z <= '1';
			elsif(alusel="0101") then
				ac <= ac and r;
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			elsif(alusel="0110") then
				ac <= ac or r;
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			elsif(alusel="0111") then
				ac <= ac xor r;
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			elsif(alusel="1000") then
				ac <= not ac;
				if(ac="00000000") then
					z <= '1';
				else
					z <= '0';
				end if;
			end if;
		end if;				
	end process signal_control;
	
end;
