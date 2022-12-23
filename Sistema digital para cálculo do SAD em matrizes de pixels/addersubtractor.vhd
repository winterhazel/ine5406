library ieee;
use ieee.std_logic_1164.all;

entity addersubtractor is
	generic(	N: positive;
				isAdder: boolean;
				isSubtractor: boolean );
	port(	op: in std_logic;
			a, b: in std_logic_vector(N-1 downto 0);
			result: out std_logic_vector(N-1 downto 0);
			ovf, cout: out std_logic );
	begin
		assert (isAdder or isSubtractor) report "Pelo menos um dos parametros generic deve ser true" severity error;		
end entity;

architecture arch1 of addersubtractor is
    signal operandB: std_logic_vector(N-1 downto 0);
    signal carry: std_logic_vector(N downto 0);
begin
	generateAdder: if isAdder and not isSubtractor generate
    	carry(0) <= '0';
    	operandB <= b;
	end generate;
	generateSubtractor: if not isAdder and isSubtractor generate
        carry(0) <= '1';
    	operandB <= not b;
	end generate;
	generateBoth: if isAdder and isSubtractor generate
    	carry(0) <= op;
    	operandB <= b when op = '0' else not b;
	end generate;
	generateResult: for i in result'range generate
	    result(i) <= a(i) xor operandB(i) xor carry(i);
	    carry(i+1) <= (a(i) and carry(i)) or (operandB(i) and carry(i)) or (a(i) and operandB(i));
	end generate;
	ovf <= carry(N) xor carry(N-1);
	cout <= carry(N);
end architecture;