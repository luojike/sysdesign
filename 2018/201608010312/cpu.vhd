
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
	
	signal bus16: std_logic_vector(15 downto 0);
	signal s: std_logic_vector(3 downto 0);
	signal aluResult: std_logic_vector(7 downto 0); 
	signal pcinc: std_logic;
	signal acreset: std_logic;
	signal acinc: std_logic;
	signal arinc: std_logic; 
	signal write1: std_logic;
	signal pcbus: std_logic;
	signal membus: std_logic;
	signal rbus: std_logic;
	signal acbus: std_logic;
	signal trbus: std_logic;
	signal drbus: std_logic;
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
	
	constant fetch1: 	std_logic_vector(5 downto 0) := "000000";
	constant fetch2: 	std_logic_vector(5 downto 0) := "000001";
	constant fetch3: 	std_logic_vector(5 downto 0) := "000010";
	constant clac1: 	std_logic_vector(5 downto 0) := "000100";
	constant incac1: 	std_logic_vector(5 downto 0) := "000101";
	constant add1:		std_logic_vector(5 downto 0) := "000110";
	constant sub1: 		std_logic_vector(5 downto 0) := "000111";
	constant and1: 		std_logic_vector(5 downto 0) := "001000";
	constant or1: 		std_logic_vector(5 downto 0) := "001001";
	constant xor1: 		std_logic_vector(5 downto 0) := "001010";
	constant not1: 		std_logic_vector(5 downto 0) := "001011";
	constant mvac1:		std_logic_vector(5 downto 0) := "001100";
	constant movr1:		std_logic_vector(5 downto 0) := "001101";
	constant ldac1:		std_logic_vector(5 downto 0) := "001110";
	constant ldac2:		std_logic_vector(5 downto 0) := "001111";
	constant ldac3:		std_logic_vector(5 downto 0) := "010000";
	constant ldac4:		std_logic_vector(5 downto 0) := "010001";
	constant ldac5:		std_logic_vector(5 downto 0) := "010010"; 
	constant stac1:		std_logic_vector(5 downto 0) := "010011";
	constant stac2:		std_logic_vector(5 downto 0) := "010100";
	constant stac3:		std_logic_vector(5 downto 0) := "010101";
	constant stac4:		std_logic_vector(5 downto 0) := "010110";
	constant stac5:		std_logic_vector(5 downto 0) := "010111";
	
	constant jump1:		std_logic_vector(5 downto 0) := "011000"; 
	constant jump2:		std_logic_vector(5 downto 0) := "011001";
	constant jump3:		std_logic_vector(5 downto 0) := "011010";
	
	constant jmpzy1:		std_logic_vector(5 downto 0) := "011011";
	constant jmpzy2:		std_logic_vector(5 downto 0) := "011100";
	constant jmpzy3:		std_logic_vector(5 downto 0) := "011101";
	constant jmpzn1:		std_logic_vector(5 downto 0) := "011110";
	constant jmpzn2:		std_logic_vector(5 downto 0) := "011111";
	
	constant jpnzy1:		std_logic_vector(5 downto 0) := "100000";
	constant jpnzy2:		std_logic_vector(5 downto 0) := "100001";
	constant jpnzy3:		std_logic_vector(5 downto 0) := "100010";
	constant jpnzn1:		std_logic_vector(5 downto 0) := "100011";
	constant jpnzn2:		std_logic_vector(5 downto 0) := "100100";
	
	constant nop1: std_logic_vector(5 downto 0) :="111111";

begin
	addrbus <= ar;
	databus <= bus16(7 downto 0) when write1='1' else "ZZZZZZZZ";
	
	bus16<=pc						when pcbus='1'		else	"ZZZZZZZZZZZZZZZZ";
	bus16<="00000000"&databus		when membus='1'		else	"ZZZZZZZZZZZZZZZZ";
	bus16<="00000000"&r			when rbus='1'		else	"ZZZZZZZZZZZZZZZZ";
	bus16<="00000000"&ac			when acbus='1'		else	"ZZZZZZZZZZZZZZZZ";
	bus16<=dr&tr					when(trbus='1' and drbus='1')	else	"ZZZZZZZZZZZZZZZZ";
	bus16<="00000000"&dr			when (drbus='1' and trbus/='1')		else	"ZZZZZZZZZZZZZZZZ";

	aluResult<=bus16(7 downto 0)										when s="0000"	else
	std_logic_vector(unsigned(ac)+unsigned(bus16(7 downto 0))) 		when s="0001"	else
	std_logic_vector(unsigned(ac)-unsigned(bus16(7 downto 0))) 		when s="0010"	else
	ac and bus16(7 downto 0)											when s="0011"	else
	ac or bus16(7 downto 0)											when s="0100"	else					
	ac xor bus16(7 downto 0)											when s="0101"	else
	not ac																when s="0110"	else
	bus16(7 downto 0);
	
	-- update pc, state and other registers 
	update_regs: process(clk)
	begin
		if(rising_edge(clk)) then
			--update registers
			if(pcinc='1')	then	pc<=std_logic_vector(unsigned(pc) + 1);
			end if;
			if(acinc='1')	then	ac<=std_logic_vector(unsigned(ac) + 1);
				if(ac="11111111")	then	z<='1';
				else	z<='0';
				end if;
			end if;
			if(arinc='1')	then	ar<=std_logic_vector(unsigned(ar) + 1);
			end if;
			
			if(arload='1')	then	ar<=bus16;
			end if;
			if(drload='1')	then	dr<=bus16(7 downto 0);
			end if;
			if(irload='1')	then	ir<=dr;
			end if;
			if(acload='1')	then
				ac<=aluResult;
				if(s="0001" or s="0010" or s="0011" or s="0100" or s="0101" or s="0110")	then	
					if(aluResult="00000000")	then z<='1';
					else	z<='0';
					end if;
				end if;
			end if;
			if(rload='1')	then	r<=bus16(7 downto 0);
			end if;
			if(trload='1')	then	tr<=dr;
			end if;
			if(pcload='1')	then	pc<=bus16;
			end if;
			
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
			
		end if;

	end process update_regs;
	
	-- generate control signals for each state
	for_nextstate: process(state, ir, z)
	begin
	
		if(state=fetch1)	then 	nextstate<=fetch2;
		elsif(state=fetch2)	then	nextstate<=fetch3;
		elsif(state=fetch3)	then
			if(dr=RSCLAC)		then	nextstate<=clac1;
			elsif(dr=RSINAC)	then	nextstate<=incac1;
			elsif(dr=RSADD)		then	nextstate<=add1;
			elsif(dr=RSSUB)		then	nextstate<=sub1;
			elsif(dr=RSAND)		then	nextstate<=and1;
			elsif(dr=RSOR)		then	nextstate<=or1;
			elsif(dr=RSXOR)		then	nextstate<=xor1;
			elsif(dr=RSNOT)		then	nextstate<=not1;
			elsif(dr=RSMVAC)	then	nextstate<=mvac1;
			elsif(dr=RSMOVR)	then	nextstate<=movr1;
			elsif(dr=RSLDAC)	then	nextstate<=ldac1;
			elsif(dr=RSSTAC)	then	nextstate<=stac1;
			elsif(dr=RSJUMP)	then	nextstate<=jump1;
			
			elsif(dr=RSJMPZ)	then	
				if(z='1')	then
					nextstate<=jmpzy1;
				else
					nextstate<=jmpzn1;
				end if;
			
			elsif(dr=RSJPNZ)	then
				if(z='0')	then
					nextstate<=jpnzy1;
				else
					nextstate<=jpnzn1;
				end if;
			
			else	nextstate<=fetch1;
			end if;
		end if;
		
		if(state=clac1)		then	nextstate<=fetch1;
		elsif(state=incac1)	then	nextstate<=fetch1;
		
		elsif(state=add1)	then	nextstate<=fetch1;
		elsif(state=sub1)	then	nextstate<=fetch1;
		elsif(state=and1)	then	nextstate<=fetch1;
		elsif(state=or1)	then	nextstate<=fetch1;
		elsif(state=xor1)	then	nextstate<=fetch1;
		elsif(state=not1)	then	nextstate<=fetch1;
		
		elsif(state=mvac1)	then	nextstate<=fetch1;
		elsif(state=movr1)	then	nextstate<=fetch1;
		
		elsif(state=ldac1)	then	nextstate<=ldac2;
		elsif(state=ldac2)	then	nextstate<=ldac3;
		elsif(state=ldac3)	then	nextstate<=ldac4;
		elsif(state=ldac4)	then	nextstate<=ldac5;
		elsif(state=ldac5)	then	nextstate<=fetch1;

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
		if(state=fetch1)	then	
		arload<='1';
		pcbus<='1';
		pcinc<='0';
		drload<='0';
		membus<='0';
		irload<='0';
		acreset<='0';
		acinc<='0';
		rbus<='0';
		s<="0000";acload<='0';
		rload<='0';acbus<='0';
		arinc<='0';trbus<='0';
		drbus<='0';trload<='0';
		read<='0';write1<='0';
		write<='0';pcload<='0';
		
		elsif(state=fetch2)	then	
		arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='1';write1<='0';write<='0';pcload<='0';
		
		elsif(state=fetch3)	then	
		arload<='1';pcbus<='1';pcinc<='0';drload<='0';membus<='0';irload<='1';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';

		elsif(state=clac1)	then	
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='1';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=incac1)	then	
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='1';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=add1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0001";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=sub1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0010";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=and1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0011";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=or1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0100";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=xor1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0101";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=not1)	then--alu e
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0110";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=mvac1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='1';acbus<='1';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=movr1)	then
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='1';s<="0000";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		--load ac
		elsif(state=ldac1)	then--dr<=m	pc=pc+1    ar=ar+1
		arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
		read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac2)	then--tr<=dr	dr<=m	   pc=pc+1
		arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
		read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac3)	then--ar<=dr, tr
		arload<='1';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac4)	then--dr<=m
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=ldac5)	then--ac<=dr
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='1';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='1';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		--store ac
		elsif(state=stac1)	then--dr<=m	pc=pc+1    ar=ar+1
		arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
		read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=stac2)	then--tr<=dr	dr<=m	   pc=pc+1
		arload<='0';pcbus<='0';pcinc<='1';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
		read<='1';write1<='0';write<='0';pcload<='0';
		elsif(state=stac3)	then--ar<=dr, tr
		arload<='1';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=stac4)	then--dr<=ac
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='1';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=stac5)	then--m<=dr
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='1';trload<='0';
		read<='0';write1<='1';write<='1';pcload<='0';
		
		--jump
		elsif(state=jump1)	then	--dr<=m ar++
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jump2)	then	--tr<=dr dr<=m
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jump3)	then	--pc<=dr,tr
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='1';
		
		--jmpz
		elsif(state=jmpzy1)	then	--dr<=m ar++
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jmpzy2)	then	--tr<=dr dr<=m
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jmpzy3)	then	--pc<=dr,tr
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='1';
		elsif(state=jmpzn1)	then	--dr<=m ar++
		arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jmpzn2)	then	--tr<=dr dr<=m
		arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		--jpnz
		elsif(state=jpnzy1)	then	--dr<=m ar++
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='1';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jpnzy2)	then	--tr<=dr dr<=m
		arload<='0';pcbus<='0';pcinc<='0';drload<='1';membus<='1';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='1';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jpnzy3)	then	--pc<=dr,tr
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='1';drbus<='1';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='1';
		elsif(state=jpnzn1)	then	--dr<=m ar++
		arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		elsif(state=jpnzn2)	then	--tr<=dr dr<=m
		arload<='0';pcbus<='0';pcinc<='1';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		
		elsif(state=nop1)	then	
		arload<='0';pcbus<='0';pcinc<='0';drload<='0';membus<='0';irload<='0';acreset<='0';acinc<='0';
		rbus<='0';s<="0000";acload<='0';rload<='0';acbus<='0';arinc<='0';trbus<='0';drbus<='0';trload<='0';
		read<='0';write1<='0';write<='0';pcload<='0';
		end if;
	end process gen_controls;
end;
