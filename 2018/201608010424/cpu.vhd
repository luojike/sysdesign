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
		    read1: out std_logic;
		    write1: out std_logic
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
	
	signal thebus: std_logic_vector(15 downto 0);
	signal alu_result: std_logic_vector(7 downto 0);

	signal cle: std_logic;
	signal pcinc: std_logic;
	signal arinc: std_logic;	
	signal acinc: std_logic;
	signal arload: std_logic;
	signal pcload: std_logic;
	signal drload: std_logic;
	signal trload: std_logic;
	signal irload: std_logic;
	signal rload: std_logic;
	signal acload: std_logic;
	
	signal membus: std_logic;
	signal busmem: std_logic;
	signal pcbus: std_logic;
	signal drbus: std_logic;
	signal trbus: std_logic;
	signal rbus: std_logic;
	signal acbus: std_logic;

	signal nextpc: std_logic_vector(15 downto 0);
	signal state: std_logic_vector(5 downto 0);
	signal nextstate: std_logic_vector(5 downto 0);

	constant fetch1: std_logic_vector(5 downto 0) := "000000";
	constant fetch2: std_logic_vector(5 downto 0) := "000001";
	constant fetch3: std_logic_vector(5 downto 0) := "000010";
	constant fetch4: std_logic_vector(5 downto 0) := "000011";

	constant nop1: std_logic_vector(5 downto 0)  := "000100";
	                                             
	constant ldac1: std_logic_vector(5 downto 0) := "000101";
	constant ldac2: std_logic_vector(5 downto 0) := "000110";
	constant ldac3: std_logic_vector(5 downto 0) := "000111";
	constant ldac4: std_logic_vector(5 downto 0) := "001000";
	constant ldac5: std_logic_vector(5 downto 0) := "001001";
	                                             
	constant stac1: std_logic_vector(5 downto 0) := "001010";
	constant stac2: std_logic_vector(5 downto 0) := "001011";
	constant stac3: std_logic_vector(5 downto 0) := "001100";
	constant stac4: std_logic_vector(5 downto 0) := "001101";
	constant stac5: std_logic_vector(5 downto 0) := "001110";
	                                             
	constant mvac1: std_logic_vector(5 downto 0) := "001111";
	                                             
	constant movr1: std_logic_vector(5 downto 0) := "010000";
	                                             
	constant jump1: std_logic_vector(5 downto 0)  := "010001";
	constant jump2: std_logic_vector(5 downto 0)  := "010010";
	constant jump3: std_logic_vector(5 downto 0)  := "010011";
	                                              
	constant jmpzn1: std_logic_vector(5 downto 0) := "010100";
	constant jmpzn2: std_logic_vector(5 downto 0) := "010101";
	                                              
	constant jpnzn1: std_logic_vector(5 downto 0) := "010110";
	constant jpnzn2: std_logic_vector(5 downto 0) := "010111";
	                                              
	constant jmpzy1: std_logic_vector(5 downto 0) := "011000";
	constant jmpzy2: std_logic_vector(5 downto 0) := "011001";
	constant jmpzy3: std_logic_vector(5 downto 0) := "011010";
	                                              
	constant jpnzy1: std_logic_vector(5 downto 0) := "011011";
	constant jpnzy2: std_logic_vector(5 downto 0) := "011100";
	constant jpnzy3: std_logic_vector(5 downto 0) := "011101";
	                                              
	constant add1: std_logic_vector(5 downto 0)   := "011110";
	constant sub1: std_logic_vector(5 downto 0)   := "011111";
	constant inac1: std_logic_vector(5 downto 0)  := "100000";
	constant clac1: std_logic_vector(5 downto 0)  := "100001";
	constant and1: std_logic_vector(5 downto 0)   := "100010";
	constant or1: std_logic_vector(5 downto 0)    := "100011";
	constant xor1: std_logic_vector(5 downto 0)   := "100100";
	constant not1: std_logic_vector(5 downto 0)   := "100101";

begin
	-- address and data bus
	addrbus <= ar;
	databus <= dr when busmem='1' else "ZZZZZZZZ";
		
	--the bus
	thebus<=pc						when pcbus='1'		else
		    "00000000"&databus		when membus='1'		else
		    "00000000"&r			when rbus='1'		else
		    "00000000"&ac			when acbus='1'		else
		    dr&tr					when (trbus='1' and drbus='1')		else
		    "00000000"&dr			when (drbus='1' and trbus/='1')		else	
		    "ZZZZZZZZZZZZZZZZ";

		
	alu_result <= std_logic_vector(unsigned(ac)-unsigned(thebus(7 downto 0))) when state=sub1 else
				  std_logic_vector(unsigned(ac)+unsigned(thebus(7 downto 0)))  when state=add1 else
				  std_logic_vector(ac and thebus(7 downto 0)) when state=and1 else
				  std_logic_vector(ac or thebus(7 downto 0)) when state=or1 else
				  std_logic_vector(ac xor thebus(7 downto 0)) when state=xor1 else
				  std_logic_vector( not ac) when state=not1 else
				  thebus(7 downto 0);
	
	-- update pc, state and other registers
	update_regs: process(clk)
	begin
		if(rising_edge(clk)) then
			
			if(arload='1') then
				ar <= thebus;
			end if;
			if(pcload='1') then
				pc <= thebus;
			end if;
			if(drload='1') then
				dr <= thebus(7 downto 0);
			end if;
			if(trload='1') then
				tr <= dr;
			end if;
			if(irload='1') then
				ir <= dr;
			end if;
			if(rload='1') then
				r <= thebus(7 downto 0);
			end if;
			if(acload='1') then
				ac <= alu_result;
				if(state=ADD1 or state=SUB1 or state=NOT1 or state=AND1 or state=OR1 or state=XOR1) then
				if(alu_result="00000000") then
					z<='1';
				else
					z<='0';
				end if;
				end if;
			end if;
			
			if(arinc='1') then
				ar <= std_logic_vector(unsigned(ar)+1);
			end if;
			if(pcinc='1') then
				pc <= std_logic_vector(unsigned(pc)+1);
			end if;
			if(acinc='1') then
				ac <= std_logic_vector(unsigned(ac)+1);
				if(ac="11111111")	then	z<='1';
				else	z<='0';
				end if;
			end if;
			if(cle='1') then
				ac <= "00000000";
				z  <='1';
			end if;		
			
			if(reset='1') then
				pc <= X"0000";
				state <= fetch1;
			else
				--pc <= nextpc;
				state <= nextstate;
			end if;	

		end if;

	end process update_regs;

	-- generate nextstate by current state and other conditions
	for_nextstate: process(state, ir)
	begin
		case state is
			when fetch1 =>
				nextstate <= fetch2;
			when fetch2 =>
				nextstate <= fetch3;
			when fetch3 =>
				nextstate <= fetch4;
			when fetch4 =>
				case ir is
					when RSNOP =>
						nextstate <= nop1;
					when RSCLAC =>
						nextstate <= clac1;
					when RSSTAC=>
						nextstate <= stac1;
					when RSLDAC=>
						nextstate <= ldac1;
					when RSINAC=>
						nextstate <= inac1;	
					when RSMVAC=>
						nextstate <= mvac1;	
					when RSADD=>
						nextstate <= add1;
					when RSSUB=>
						nextstate <= sub1;
					when RSJPNZ=>
						if z='0' then
							nextstate <= jpnzy1;
						else
							nextstate <= jpnzn1;
						end if;
					when RSJMPZ=>
						if z='1' then
							nextstate <= jmpzy1;
						else
							nextstate <= jmpzn1;
						end if;
					
					when others =>
						nextstate <= fetch1;
				end case;

			when others =>
				nextstate <= fetch1;

		end case;
		
		if(state=clac1)		then	nextstate<=fetch1;
		elsif(state=inac1)	then	nextstate<=fetch1;
		--alu
		elsif(state=add1)	then	nextstate<=fetch1;
		elsif(state=sub1)	then	nextstate<=fetch1;
		elsif(state=and1)	then	nextstate<=fetch1;
		elsif(state=or1)	then	nextstate<=fetch1;
		elsif(state=xor1)	then	nextstate<=fetch1;
		elsif(state=not1)	then	nextstate<=fetch1;
		--mov
		elsif(state=mvac1)	then	nextstate<=fetch1;
		elsif(state=movr1)	then	nextstate<=fetch1;
		--load
		elsif(state=ldac1)	then	nextstate<=ldac2;
		elsif(state=ldac2)	then	nextstate<=ldac3;
		elsif(state=ldac3)	then	nextstate<=ldac4;
		elsif(state=ldac4)	then	nextstate<=ldac5;
		elsif(state=ldac5)	then	nextstate<=fetch1;
		--store
		elsif(state=stac1)	then	nextstate<=stac2;
		elsif(state=stac2)	then	nextstate<=stac3;
		elsif(state=stac3)	then	nextstate<=stac4;
		elsif(state=stac4)	then	nextstate<=stac5;
		elsif(state=stac5)	then	nextstate<=fetch1;
		--jmp
		elsif(state=jump1)	then	nextstate<=jump2;
		elsif(state=jump2)	then	nextstate<=jump3;
		elsif(state=jump3)	then	nextstate<=fetch1;
		--jmpz
		elsif(state=jmpzy1)	then	nextstate<=jmpzy2;
		elsif(state=jmpzy2)	then	nextstate<=jmpzy3;
		elsif(state=jmpzy3)	then	nextstate<=fetch1;
		elsif(state=jmpzn1)	then	nextstate<=jmpzn2;
		elsif(state=jmpzn2)	then	nextstate<=fetch1;
		--jpnz
		elsif(state=jpnzy1)	then	nextstate<=jpnzy2;
		elsif(state=jpnzy2)	then	nextstate<=jpnzy3;
		elsif(state=jpnzy3)	then	nextstate<=fetch1;
		elsif(state=jpnzn1)	then	nextstate<=jpnzn2;
		elsif(state=jpnzn2)	then	nextstate<=fetch1;
		
		end if;

	end process for_nextstate;

	-- generate control signals for each state
	gen_controls: process(state)
	begin	
		case state is
			when fetch1 =>     --AR←PC
				arload <= '1';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '1';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';

			when fetch2 =>     --DR←M，PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when fetch3 =>     --IR←DR
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '1';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';

			when fetch4 =>     --AR←PC
				arload <= '1';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '1';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '1';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when nop1 =>     --
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when ldac1 =>     --DR←M，PC←PC＋1，AR←AR＋1
				arload <= '0';
				arinc  <= '1';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
			
			when ldac2 =>     --TR←DR，DR←M，PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '1';
				trload <= '1';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when ldac3 =>     --AR←DR，TR
				arload <= '1';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '1';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when ldac4 =>     -- DR←M
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when ldac5 =>     --AC←DR
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when stac1 =>     -- DR←M，PC←PC＋1，AR←AR＋1
				arload <= '0';
				arinc  <= '1';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when stac2 =>     --TR←DR，DR←M，PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '1';
				trload <= '1';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when stac3 =>     --AR←DR，TR
				arload <= '1';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '1';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when stac4 =>     --DR←AC
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '1';
				cle    <= '0';
				busmem <= '0';
				
			when stac5 =>     --M←DR
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '1';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '1';
				
			when mvac1 =>     --R←AC
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '1';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '1';
				cle    <= '0';
				busmem <= '0';
				
			when movr1 =>     --AC←R
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';	
				
			when jump1 =>     --DR←M，AR←AR+1
				arload <= '0';
				arinc  <= '1';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jump2 =>     --TR←DR，DR←M
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '1';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';	
				cle    <= '0';
				busmem <= '0';
			
			when jump3 =>     --PC←DR，TR
				arload <= '0';
				arinc  <= '0';
				pcload <= '1';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '1';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
			
			when jmpzn1 =>     --PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jmpzn2 =>     --PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jmpzy1 =>     --DR←M，AR←AR＋1
				arload <= '0';
				arinc  <= '1';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jmpzy2 =>     --TR←DR，DR←M
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '1';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jmpzy3 =>     --PC←DR，TR
				arload <= '0';
				arinc  <= '0';
				pcload <= '1';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '1';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jpnzn1 =>     --PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jpnzn2 =>     --PC←PC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '1';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jpnzy1 =>     --DR←M，AR←AR＋1
				arload <= '0';
				arinc  <= '1';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jpnzy2 =>     --TR←DR，DR←M
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '1';
				trload <= '1';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '1';
				membus <= '1';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when jpnzy3 =>     --PC←DR，TR
				arload <= '0';
				arinc  <= '0';
				pcload <= '1';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '1';
				trbus  <= '1';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when add1 =>     --AC←AC＋R
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when sub1 =>     --AC←AC－R
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when inac1 =>     --AC←AC＋1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '1';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when clac1 =>     --AC←0,  Z←1
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '1';
				busmem <= '0';
			
			when and1 =>     --AC←AC∧R
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
			
			when or1 =>     --AC←AC∨R
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when xor1 =>     --AC←AC⊕R
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';

			when not1 =>     --AC←AC'
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '1';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '1';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
			when others =>     
				arload <= '0';
				arinc  <= '0';
				pcload <= '0';
				pcinc  <= '0';
				drload <= '0';
				trload <= '0';
				irload <= '0';
				rload  <= '0';
				acload <= '0';
				acinc  <= '0';
				write1  <= '0';
				read1   <= '0';
				membus <= '0';
				pcbus  <= '0';
				drbus  <= '0';
				trbus  <= '0';
				rbus   <= '0';
				acbus  <= '0';
				cle    <= '0';
				busmem <= '0';
				
		end case;

	end process gen_controls;
end;

