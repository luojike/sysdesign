library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rsisa.all;  -- constants of instruction opcodes

entity cpu is
	port(
		    clk: in std_logic;
		    reset: in std_logic;
		    addrbus: out std_logic_vector(15 downto 0);
		    databus: inout std_logic_vector(7 downto 0);
		    read: out std_logic;
		    write: out std_logic
	    );
end entity;

architecture cpu_behav of cpu is
	
	signal pc: std_logic_vector(15 downto 0);
	signal ac: std_logic_vector(7 downto 0);
	signal r: std_logic_vector(7 downto 0) ;
	signal ar: std_logic_vector(15 downto 0);
	signal ir: std_logic_vector(7 downto 0);
	signal dr: std_logic_vector(7 downto 0);
	signal tr: std_logic_vector(7 downto 0);
	signal z: std_logic;	
	signal thebus: std_logic_vector(15 downto 0);
	--alu signal
	signal s: std_logic_vector(2 downto 0);--000 ac<=thebus;001 add;010 sub;011 and;100 or;101 xor;110 not	
	signal aluResult: std_logic_vector(7 downto 0); 
	--other signal
	signal pcinc: std_logic;
	signal acreset: std_logic;
	signal acinc: std_logic;
	signal arinc: std_logic; 
	signal write1: std_logic;
	--bus signal
	signal pcbus: std_logic;
	signal membus: std_logic;
	signal rbus: std_logic;
	signal acbus: std_logic;
	signal trbus: std_logic;
	signal drbus: std_logic;
	--load signal
	signal pcload: std_logic;
	signal arload: std_logic;
	signal drload: std_logic;
	signal irload: std_logic;
	signal acload: std_logic;
	signal rload:  std_logic;
	signal trload: std_logic;
	signal nextpc: std_logic_vector(15 downto 0);
	signal state: std_logic_vector(5 downto 0);
	signal nextstate: std_logic_vector(5 downto 0);
	constant fetch1: std_logic_vector(5 downto 0) := "000000";-- ar<=pc
	constant fetch2: std_logic_vector(5 downto 0) := "000001";-- dr<=m  pc<=pc+1
	constant fetch3: std_logic_vector(5 downto 0) := "000010";-- ir<=dr 
	constant fetch4: std_logic_vector(5 downto 0) := "000011";-- ar<=pc
	constant clac1: std_logic_vector(5 downto 0) := "000100";--ac<=0 z<=1
	constant incac1: std_logic_vector(5 downto 0) := "000101";--ac++ z change
	constant add1:	std_logic_vector(5 downto 0) := "000110";--ac=ac+r z change
	constant sub1: 	std_logic_vector(5 downto 0) := "000111";--ac=ac-r z change
	constant and1: 	std_logic_vector(5 downto 0) := "001000";--ac=ac&r z change
	constant or1: 	std_logic_vector(5 downto 0) := "001001";--ac=ac|r z change
	constant xor1: 	std_logic_vector(5 downto 0) := "001010";--ac=ac xor r z change
	constant not1: 	std_logic_vector(5 downto 0) := "001011";--ac=not ac z change
	constant mvac1:	std_logic_vector(5 downto 0) := "001100";--r<=ac
	constant movr1:	std_logic_vector(5 downto 0) := "001101";--ac<=r
	constant ldac1:	std_logic_vector(5 downto 0) := "001110";--dr<=m	pc=pc+1    ar=ar+1
	constant ldac2:	std_logic_vector(5 downto 0) := "001111";--tr<=dr	dr<=m	   pc=pc+1
	constant ldac3:	std_logic_vector(5 downto 0) := "010000";--ar<=dr, tr	
	constant ldac4:	std_logic_vector(5 downto 0) := "010001";--dr<=m
	constant ldac5:	std_logic_vector(5 downto 0) := "010010";--ac<=dr
	constant stac1:	std_logic_vector(5 downto 0) := "010011";--dr<=m  pc++ ar++
	constant stac2:	std_logic_vector(5 downto 0) := "010100";--tr<=dr dr<=m pc++
	constant stac3:	std_logic_vector(5 downto 0) := "010101";--ar<=dr,tr
	constant stac4:	std_logic_vector(5 downto 0) := "010110";--dr<=ac
	constant stac5:	std_logic_vector(5 downto 0) := "010111";--m<=dr
	constant jump1:	std_logic_vector(5 downto 0) := "011000";--dr<=m ar++
	constant jump2:	std_logic_vector(5 downto 0) := "011001";--tr<=dr dr<=m
	constant jump3:	std_logic_vector(5 downto 0) := "011010";--pc<=dr tr
	constant jmpzy1:std_logic_vector(5 downto 0) := "011011";--dr<=m  ar++
	constant jmpzy2:std_logic_vector(5 downto 0) := "011100";--tr<=dr  dr<=m
	constant jmpzy3:std_logic_vector(5 downto 0) := "011101";--pc<=dr,tr
	constant jmpzn1:std_logic_vector(5 downto 0) := "011110";--pc++
	constant jmpzn2:std_logic_vector(5 downto 0) := "011111";--pc++
	constant jpnzy1:std_logic_vector(5 downto 0) := "100000";--dr<=m  ar++
	constant jpnzy2:std_logic_vector(5 downto 0) := "100001";--tr<=dr  dr<=m
	constant jpnzy3:std_logic_vector(5 downto 0) := "100010";--pc<=dr,tr
	constant jpnzn1:std_logic_vector(5 downto 0) := "100011";--pc++
	constant jpnzn2:std_logic_vector(5 downto 0) := "100100";--pc++
	constant nop1: std_logic_vector(5 downto 0) :="111111";--no operation
begin
	addrbus <= ar;
	databus <= thebus(7 downto 0) when write1='1' else "ZZZZZZZZ";
	--the bus
	thebus<=pc when pcbus='1'		              else "ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&databus when membus='1'            else "ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&r	when rbus='1'	              else "ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&ac	when acbus='1'	              else "ZZZZZZZZZZZZZZZZ";
	thebus<=dr&tr         when(trbus='1' and drbus='1')   else "ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&dr when (drbus='1' and trbus/='1') else "ZZZZZZZZZZZZZZZZ";
	--alu
	aluResult<=thebus(7 downto 0)				   when s="000"else
	std_logic_vector(unsigned(ac)+unsigned(thebus(7 downto 0)))when s="001"else
	std_logic_vector(unsigned(ac)-unsigned(thebus(7 downto 0)))when s="010"else
	ac and thebus(7 downto 0)when s="011"else	
	ac or thebus(7 downto 0)when s="100"else			
	ac xor thebus(7 downto 0)when s="101"else 
	not ac	when s="110"else
	thebus(7 downto 0);
	-- update pc, state and other registers 
	update_regs: process(clk)
	begin
		if(rising_edge(clk)) then
			--update registers
			if(acreset='1')	then
				ac<="00000000";
				z<='0';
			end if;
			if(reset='1') then
				pc <= "0000000000000000";
				state <= fetch1;
			else
				state <= nextstate;
			end if;	
			if(pcinc='1')then	
				pc<=std_logic_vector(unsigned(pc) + 1);
			end if;
			if(acinc='1')then	
				ac<=std_logic_vector(unsigned(ac) + 1);
				if(ac="11111111")then	
				z<='1';
				else	
				z<='0';
				end if;
			end if;
			if(arinc='1')then	
				ar<=std_logic_vector(unsigned(ar) + 1);
			end if;	
			if(arload='1')then	
				ar<=thebus;
			end if;
			if(drload='1')then	
				dr<=thebus(7 downto 0);
			end if;
			if(irload='1')	then	
				ir<=dr;
			end if;
			if(acload='1')	then
				ac<=aluResult;
				if(s="001" or s="010" or s="011" or s="100" or s="101" or s="110")then	
					if(aluResult="00000000")then 
						z<='1';
					else	
						z<='0';
					end if;
				end if;
			end if;
			if(rload='1')then	
				r<=thebus(7 downto 0);
			end if;
			if(trload='1')then	
				tr<=dr;
			end if;
			if(pcload='1')then	
				pc<=thebus;
			end if;			
		end if;
	end process update_regs;
	
	-- generate control signals for each state
	for_nextstate: process(state, ir, z)
	begin
		case state is
			when fetch1=>
				nextstate<=fetch2;
			when fetch2=>
				nextstate<=fetch3;
			when fetch3=>
				nextstate<=fetch4;
			when fetch4=>
				case ir is	
					when RSCLAC=>		
						nextstate<=clac1;
					when RSINAC=>
						nextstate<=incac1;
					when RSADD=>
						nextstate<=add1;
					when RSSUB=>
						nextstate<=sub1;
					when RSAND=>
						nextstate<=and1;
					when RSOR=>		
						nextstate<=or1;
					when RSXOR=>		
						nextstate<=xor1;
					when RSNOT=>
						nextstate<=not1;
					when RSMVAC=>
						nextstate<=mvac1;
					when RSMOVR=>
						nextstate<=movr1;
					when RSLDAC=>
						nextstate<=ldac1;
					when RSSTAC=>
						nextstate<=stac1;
					when RSJUMP=>	
						nextstate<=jump1;
					when RSJMPZ=>	
						if(z='1')	then
						nextstate<=jmpzy1;
						else
						nextstate<=jmpzn1;
						end if;
			
					when RSJPNZ=>
						if(z='0')	then
						nextstate<=jpnzy1;
						else
						nextstate<=jpnzn1;
						end if;
					when others=>
						nextstate<=fetch1;
				end case;
		--ac
			when clac1=>
				nextstate<=fetch1;
			when incac1=>
				nextstate<=fetch1;
		--alu
			when add1=>
				nextstate<=fetch1;
			when sub1=>
				nextstate<=fetch1;
			when and1=>	
				nextstate<=fetch1;
			when or1=>
				nextstate<=fetch1;
			when xor1=>
				nextstate<=fetch1;
			when not1=>
				nextstate<=fetch1;
		--mov
			when mvac1=>
				nextstate<=fetch1;
			when movr1=>
				nextstate<=fetch1;
		--load
			when ldac1=>
				nextstate<=ldac2;
			when ldac2=>
				nextstate<=ldac3;
			when ldac3=>
				nextstate<=ldac4;
			when ldac4=>
				nextstate<=ldac5;
			when ldac5=>
				nextstate<=fetch1;
		--store
			when stac1=>
				nextstate<=stac2;
			when stac2=>
				nextstate<=stac3;
			when stac3=>
				nextstate<=stac4;
			when stac4=>
				nextstate<=stac5;
			when stac5=>
				nextstate<=fetch1;
		--jmp
			when jump1=>
				nextstate<=jump2;
			when jump2=>
				nextstate<=jump3;
			when jump3=>
				nextstate<=fetch1;
		--jmpz
			when jmpzy1=>
				nextstate<=jmpzy2;
			when jmpzy2=>
				nextstate<=jmpzy3;
			when jmpzy3=>
				nextstate<=fetch1;
			when jmpzn1=>
				nextstate<=jmpzn2;
			when jmpzn2=>
				nextstate<=fetch1;
		--jpnz
			when jpnzy1=>
				nextstate<=jpnzy2;
			when jpnzy2=>
				nextstate<=jpnzy3;
			when jpnzy3=>
				nextstate<=fetch1;
			when jpnzn1=>
				nextstate<=jpnzn2;
			when jpnzn2=>
				nextstate<=fetch1;
			when others=>
				NULL;		
		end case;	
	end process for_nextstate;


	-- generate control signals for each state 
	gen_controls: process(state)
	begin
		case state is
			when fetch1=>	
				arload<='1';pcbus<='1';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when fetch2=>
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';-- dr<=m  pc<=pc+1
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when fetch3=>	
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='1';
				acreset<='0';acinc<='0';rbus<='0';--ir<=dr	
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when fetch4=>	
				arload<='1';pcbus<='1';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';--ar<=pc
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when clac1=>	
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='1';acinc<='0';rbus<='0';--ac<=0	z<=1
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when incac1=>		
				arload<='0';pcbus<='0';pcinc<='0';	
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='1';rbus<='0';--ac++ z change
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when add1=>--alu s
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="001";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when sub1=>
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="010";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when and1=>
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="011";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when or1=>
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="100";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when xor1=>
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="101";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when not1=>--alu e
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="110";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when mvac1=>
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='1';		
				acbus<='1';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when movr1=>
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='1';
				s<="000";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
		--load ac
			when ldac1=>--dr<=m	pc=pc+1    ar=ar+1
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='1';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when ldac2=>--tr<=dr	dr<=m	   pc=pc+1
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='1';read<='1';
				write1<='0';write<='0';pcload<='0';
			when ldac3=>--ar<=dr, tr
				arload<='1';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='1';
				drbus<='1';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when ldac4=>--dr<=m
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when ldac5=>--ac<=dr
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='1';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='1';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
		--store ac
			when stac1=>--dr<=m	pc=pc+1    ar=ar+1
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='1';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when stac2=>--tr<=dr	dr<=m	   pc=pc+1
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='1';read<='1';
				write1<='0';write<='0';pcload<='0';
			when stac3=>--ar<=dr, tr
				arload<='1';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='1';
				drbus<='1';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when stac4=>--dr<=ac
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='1';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
			when stac5=>--m<=dr
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='1';trload<='0';read<='0';
				write1<='1';write<='1';pcload<='0';
		--jump
			when jump1=>	--dr<=m ar++
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='1';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jump2=>	--tr<=dr dr<=m
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='1';read<='0';
				write1<='0';write<='0';pcload<='0';
			when jump3=>	--pc<=dr,tr
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='1';
				drbus<='1';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='1';
		--jmpz
			when jmpzy1=>	--dr<=m ar++
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='1';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jmpzy2=>	--tr<=dr dr<=m
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='1';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jmpzy3=>--pc<=dr,tr
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='1';
				drbus<='1';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='1';
			when jmpzn1=>	--dr<=m ar++
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jmpzn2=>--tr<=dr dr<=m
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
		--jpnz
			when jpnzy1=>	--dr<=m ar++
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='1';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jpnzy2=>--tr<=dr dr<=m
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='1';membus<='1';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='1';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jpnzy3=>	--pc<=dr,tr
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='1';
				drbus<='1';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='1';
			when jpnzn1=>	--dr<=m ar++
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when jpnzn2=>	--tr<=dr dr<=m
				arload<='0';pcbus<='0';pcinc<='1';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='1';
				write1<='0';write<='0';pcload<='0';
			when others=>	
				arload<='0';pcbus<='0';pcinc<='0';
				drload<='0';membus<='0';irload<='0';
				acreset<='0';acinc<='0';rbus<='0';
				s<="000";acload<='0';rload<='0';
				acbus<='0';arinc<='0';trbus<='0';
				drbus<='0';trload<='0';read<='0';
				write1<='0';write<='0';pcload<='0';
		end case;
	end process gen_controls;
end;
