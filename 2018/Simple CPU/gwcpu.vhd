library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gwIR_list.all;  -- constants of instruction opcodes

entity gwcpu is
	port(
		    clk: in std_logic;
		    reset: in std_logic;
		    addrbus: out std_logic_vector(15 downto 0);
		    databus: inout std_logic_vector(7 downto 0);
		    read: out std_logic;
		    write: out std_logic
	    );
end entity;

architecture cpu_behav of gwcpu is
	
	signal pc: std_logic_vector(15 downto 0);
	signal ac: std_logic_vector(7 downto 0);
	signal r: std_logic_vector(7 downto 0) ;
	signal ar: std_logic_vector(15 downto 0);
	signal ir: std_logic_vector(7 downto 0);
	signal dr: std_logic_vector(7 downto 0);
	signal tr: std_logic_vector(7 downto 0);
	signal z: std_logic;
	
	signal thebus: std_logic_vector(15 downto 0);
	
	--alu
	signal s: std_logic_vector(3 downto 0);--0000 ac<=thebus;0001 add;0010 sub;0011 and;0100 or;0101 xor;0110 not	
	signal alu: std_logic_vector(7 downto 0); 
	--AR
	signal arinc: std_logic; 
	signal arload: std_logic;
	--PC
	signal pcinc: std_logic;
	signal pcbus: std_logic;
	signal pcload: std_logic;
	--DR
	signal drbus: std_logic;
	signal drload: std_logic;
	--TR
	signal trbus: std_logic;
	signal trload: std_logic;
	--IR
	signal irload: std_logic;
	--R
	signal rbus: std_logic;
	signal rload:  std_logic;
	--AC
	signal acbus: std_logic;
	signal acload: std_logic;
	--M
	signal membus: std_logic;
	signal write1: std_logic;
	
	signal state: std_logic_vector(5 downto 0);
	signal nextstate: std_logic_vector(5 downto 0);
	
	constant fetch1: 	std_logic_vector(5 downto 0) := "000000";-- ar<=pc
	constant fetch2: 	std_logic_vector(5 downto 0) := "000001";-- dr<=m  pc<=pc+1
	constant fetch3: 	std_logic_vector(5 downto 0) := "000010";-- ir<=dr 
	constant fetch4: 	std_logic_vector(5 downto 0) := "000011";-- ar<=pc
	constant clac1: 	std_logic_vector(5 downto 0) := "000100";--ac<=0 z<=1
	constant inac1: 	std_logic_vector(5 downto 0) := "000101";--ac++ z change
	constant add1:		std_logic_vector(5 downto 0) := "000110";--ac=ac+r z change
	constant sub1: 		std_logic_vector(5 downto 0) := "000111";--ac=ac-r z change
	constant and1: 		std_logic_vector(5 downto 0) := "001000";--ac=ac&r z change
	constant or1: 		std_logic_vector(5 downto 0) := "001001";--ac=ac|r z change
	constant xor1: 		std_logic_vector(5 downto 0) := "001010";--ac=ac xor r z change
	constant not1: 		std_logic_vector(5 downto 0) := "001011";--ac=not ac z change
	constant mvac1:		std_logic_vector(5 downto 0) := "001100";--r<=ac
	constant movr1:		std_logic_vector(5 downto 0) := "001101";--ac<=r
	constant ldac1:		std_logic_vector(5 downto 0) := "001110";--dr<=m	pc=pc+1    ar=ar+1
	constant ldac2:		std_logic_vector(5 downto 0) := "001111";--tr<=dr	dr<=m	   pc=pc+1
	constant ldac3:		std_logic_vector(5 downto 0) := "010000";--ar<=dr, tr	
	constant ldac4:		std_logic_vector(5 downto 0) := "010001";--dr<=m
	constant ldac5:		std_logic_vector(5 downto 0) := "010010";--ac<=dr
	constant stac1:		std_logic_vector(5 downto 0) := "010011";--dr<=m  pc++ ar++
	constant stac2:		std_logic_vector(5 downto 0) := "010100";--tr<=dr dr<=m pc++
	constant stac3:		std_logic_vector(5 downto 0) := "010101";--ar<=dr,tr
	constant stac4:		std_logic_vector(5 downto 0) := "010110";--dr<=ac
	constant stac5:		std_logic_vector(5 downto 0) := "010111";--m<=dr
	
	constant jump1:		std_logic_vector(5 downto 0) := "011000";--dr<=m ar++
	constant jump2:		std_logic_vector(5 downto 0) := "011001";--tr<=dr dr<=m
	constant jump3:		std_logic_vector(5 downto 0) := "011010";--pc<=dr tr
	
	constant jmpzy1:		std_logic_vector(5 downto 0) := "011011";--dr<=m  ar++
	constant jmpzy2:		std_logic_vector(5 downto 0) := "011100";--tr<=dr  dr<=m
	constant jmpzy3:		std_logic_vector(5 downto 0) := "011101";--pc<=dr,tr
	constant jmpzn1:		std_logic_vector(5 downto 0) := "011110";--pc++
	constant jmpzn2:		std_logic_vector(5 downto 0) := "011111";--pc++
	
	constant jpnzy1:		std_logic_vector(5 downto 0) := "100000";--dr<=m  ar++
	constant jpnzy2:		std_logic_vector(5 downto 0) := "100001";--tr<=dr  dr<=m
	constant jpnzy3:		std_logic_vector(5 downto 0) := "100010";--pc<=dr,tr
	constant jpnzn1:		std_logic_vector(5 downto 0) := "100011";--pc++
	constant jpnzn2:		std_logic_vector(5 downto 0) := "100100";--pc++
	
	constant nop1: std_logic_vector(5 downto 0) :="111111";--no operation

begin
	addrbus <= ar;
	databus <= thebus(7 downto 0) when write1='1' else "ZZZZZZZZ";
	
	--the bus
	thebus<=pc						when pcbus='1'		else	"ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&databus		when membus='1'		else	"ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&r			when rbus='1'		else	"ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&ac			when acbus='1'		else	"ZZZZZZZZZZZZZZZZ";
	thebus<=dr&tr					when(trbus='1' and drbus='1')	else	"ZZZZZZZZZZZZZZZZ";
	thebus<="00000000"&dr			when (drbus='1' and trbus/='1')		else	"ZZZZZZZZZZZZZZZZ";
	
	--alu
	alu<=thebus(7 downto 0)											when s="0000"	else
		std_logic_vector(unsigned(ac)+unsigned(thebus(7 downto 0))) when s="0001"	else--ac+R
		std_logic_vector(unsigned(ac)-unsigned(thebus(7 downto 0))) when s="0010"	else--ac-R
		ac and thebus(7 downto 0)									when s="0011"	else--ac and R
		ac or thebus(7 downto 0)									when s="0100"	else--ac or R		
		ac xor thebus(7 downto 0)									when s="0101"	else--ac xor R
		not ac														when s="0110"	else--not ac
		std_logic_vector(unsigned(ac)+1) 							when s="0111"	else--ac+1
		"00000000" 													when s="1000"	else--ac=0
		thebus(7 downto 0);
	
	-- update pc, state and other registers 
	update_regs: process(clk)
	begin
		if(rising_edge(clk)) then
			--update registers
			if(pcinc='1')	then pc<=std_logic_vector(unsigned(pc) + 1); end if;
			if(arinc='1')	then ar<=std_logic_vector(unsigned(ar) + 1); end if;
			if(arload='1')	then	ar<=thebus; end if;
			if(drload='1')	then	dr<=thebus(7 downto 0); end if;
			if(irload='1')	then	ir<=dr; end if;
			if(acload='1')	then
				ac<=alu;
				if(s="0001" or s="0010" or s="0011" or s="0100" or s="0101" or s="0110" or s="0111" or s="1000") then	
					if(alu="00000000")	then z<='1';
					else	z<='0';
					end if;
				end if;
			end if;
			if(rload='1')	then	r<=thebus(7 downto 0); end if;
			if(trload='1')	then	tr<=dr; end if;
			if(pcload='1')	then	pc<=thebus; end if;
			if(reset='1') then
				pc <= "0000000000000000";
				state <= fetch1;
			else
				state <= nextstate;
			end if;
		end if;

	end process update_regs;
	
	-- generate control signals for each state
	for_nextstate: process(state, ir, z)
	begin
	
		if(state=fetch1)	then 	nextstate<=fetch2;
		elsif(state=fetch2)	then	nextstate<=fetch3;
		elsif(state=fetch3)	then	nextstate<=fetch4;
		elsif(state=fetch4)	then
			if(ir=RSCLAC)		then	nextstate<=clac1;
			elsif(ir=RSINAC)	then	nextstate<=inac1;
			elsif(ir=RSADD)		then	nextstate<=add1;
			elsif(ir=RSSUB)		then	nextstate<=sub1;
			elsif(ir=RSAND)		then	nextstate<=and1;
			elsif(ir=RSOR)		then	nextstate<=or1;
			elsif(ir=RSXOR)		then	nextstate<=xor1;
			elsif(ir=RSNOT)		then	nextstate<=not1;
			elsif(ir=RSMVAC)	then	nextstate<=mvac1;
			elsif(ir=RSMOVR)	then	nextstate<=movr1;
			elsif(ir=RSLDAC)	then	nextstate<=ldac1;
			elsif(ir=RSSTAC)	then	nextstate<=stac1;
			elsif(ir=RSJUMP)	then	nextstate<=jump1;
			
			elsif(ir=RSJMPZ)	then	
				if(z='1')	then
					nextstate<=jmpzy1;
				else
					nextstate<=jmpzn1;
				end if;
			
			elsif(ir=RSJPNZ)	then
				if(z='0')	then
					nextstate<=jpnzy1;
				else
					nextstate<=jpnzn1;
				end if;
			
			else	nextstate<=fetch1;
			end if;
		end if;
		--ac
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
		if(state=fetch1)	then --AR<-- PC
			arload<='1';pcbus<='1';pcinc<='0';drload<='0';membus<='0';irload<='0';--ar<=pc
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=fetch2)	then --DR<--M PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';-- dr<=m  pc<=pc+1
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=fetch3)	then	--IR<--DR
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='1';--ir<=dr	
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=fetch4)	then	-- AR<--PC
			arload<='1';pcbus<='1';pcinc<='0';drload<='0';membus<='0';irload<='0';--ar<=pc
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=clac1)	then	--AC<--0 Z<--1
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';--ac<=0	z<=1
			rbus<='0';s<="1000";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=inac1)	then --AC<--AC+1
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';--ac++ z change
			rbus<='0';s<="0111";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=add1)	then --AC<--AC+R
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='1';s<="0001";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=sub1)	then --AC<--AC-R
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='1';s<="0010";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=and1)	then --AC<--AC and R
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='1';s<="0011";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=or1)	then --AC<--AC 0r R
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='1';s<="0100";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=xor1)	then --AC xor R
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='1';s<="0101";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=not1)	then --not AC
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0110";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=mvac1)	then --R<--AC
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='1';acbus<='1';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=movr1)	then --AC<--R
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='1';s<="0000";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		--load ac
		elsif(state=ldac1)	then --DR<--M PC<--PC+1 AR<--AR+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac2)	then --TR<--DR DR<--M PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac3)	then --AR<--DR&TR
			arload<='1';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac4)	then --DR<--M
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac5)	then --AC<--DR
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='1';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		--store ac
		elsif(state=stac1)	then --DR<--M PC<--PC+1 AR<--AR+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=stac2)	then --TR<--DR DR<--M PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=stac3)	then --AR<--DR&TR
			arload<='1';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=stac4)	then --DR<--AC
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='1';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=stac5)	then --M<--DR
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='1';trload<='0';
			read<='0';write1<='1';write<='1';pcload<='0';
		--jump
		elsif(state=jump1)	then	--DR<--M AR<--AR+1
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jump2)	then	--TR<--DR DR<--M
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
			read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jump3)	then	--PC<--DR,TR
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='1';
		--jmpz
		elsif(state=jmpzy1)	then	--DR<--M AR<--AR+1
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jmpzy2)	then	--TR<--DR DR<--M
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jmpzy3)	then	--PC<--DR,TR
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='1';
		elsif(state=jmpzn1)	then	--PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jmpzn2)	then	--PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		--jpnz
		elsif(state=jpnzy1)	then	--DR<--M AR<--AR+1
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jpnzy2)	then	--TR<--DR DR<--M
			arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jpnzy3)	then	--PC<--DR,TR
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='1';
		elsif(state=jpnzn1)	then	--PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=jpnzn2)	then	--PC<--PC+1
			arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=nop1)	then	
			arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';
			rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
			read<='0';write1<='0';write<='0';pcload<='0';
		end if;
	end process gen_controls;
end;
