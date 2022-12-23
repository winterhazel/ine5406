library ieee;
use ieee.std_logic_1164.all;

entity addersubtractor is
	generic(	N: positive;
				isAdder: boolean;
				isSubtractor: boolean;
				generateOvf: boolean );
	port(	op: in std_logic;
			a, b: in std_logic_vector(N-1 downto 0);
			result: out std_logic_vector(N-1 downto 0);
			ovf, cout: out std_logic );
	begin
	    assert (isAdder or isSubtractor) report "O circuito deve pelo menos ou somar ou subtrair" severity error;		
end entity;

architecture arch1 of addersubtractor is
	component fulladder1bit is
		port(	cin, a, b: in std_logic;
				sum: out std_logic;
				cout: out std_logic );
	end component;
	signal carry: std_logic_vector(N downto 0);
	signal operandB: std_logic_vector(N-1 downto 0);
begin
	gera: for i in result'range generate
    	-- COMPLETE COM COMANDOS CONCORRENTES
    	result(i) <= carry(i) xor a(i) xor operandB(i);
		carry(i+1) <= (carry(i) and a(i)) or (carry(i) and operandB(i)) or (a(i) and operandB(i));
	end generate;
	generateAdder: if isAdder and not isSubtractor generate
    	-- COMPLETE COM COMANDOS CONCORRENTES
    	carry(0) <= '0';
		operandB <= b;
	end generate;
	generateSubtractor: if not isAdder and isSubtractor generate
    	-- COMPLETE COM COMANDOS CONCORRENTES
    	carry(0) <= '1';
		operandB <= not b;
	end generate;
	generateBoth: if isAdder and isSubtractor generate
    	carry(0) <= op;
		operandB <= b when op='0' else not b;
	end generate;
	generateOverflow: if generateOvf generate
	-- COMPLETE COM COMANDOS CONCORRENTES
	    ovf <= carry(N) xor carry(N-1);
	end generate;
	-- COMPLETE COM COMANDOS CONCORRENTES
	cout <= carry(N);
end architecture;