-- Complete abaixo com o nome dos alunos que fazem esta avaliacao (sem caracteres especiais nos nomes, como acentos)
-- ALUNO 1:
-- ALUNO 2:


library ieee;
use ieee.std_logic_1164.all;
use work.BC_State.all;

entity blocoControle4T is
	port(
		-- control in
		clock, reset, iniciar: in std_logic;
		-- control in (status signals from BC)
		zero, ov: in std_logic;
		-- control out 
		erro, pronto: out std_logic;
		-- control out (command signals to BC)
		scont, ccont, zAC, cAC, cT: out std_logic;
		-- Tests
		stateBC: out State
	);
end entity;

architecture descricaoComportamental of blocoControle4T is
    -- não acrescente nada aqui. State está definido no package work.BC_State
    signal nextState, currentState: State;
begin
	-- next-state logic (DO NOT CHANGE OR REMOVE THIS LINE)
	process(currentState, iniciar, zero, ov)
	begin
	    nextState <= currentState;
	    
	    if currentState = S0 or currentState = E then
	        if iniciar = '1' then
	            nextState <= S1;
	        end if;
	   elsif currentState = S1 then
	        nextState <= S2;
	   elsif currentState = S2 then
	        if zero = '1' then
	            nextState <= S0;
	        else
	            nextState <= S3;
	       end if;
	   elsif currentState = S3 then
	        if ov = '0' then
	            nextState <= S2;
	        else
	            nextState <= E;
	       end if;
	    end if;
	end process;
	-- end-next-state logic (DO NOT CHANGE OR REMOVE THIS LINE)
	
	
	-- memory register (DO NOT CHANGE OR REMOVE THIS LINE)
	process(clock, reset)
	begin
	    if reset = '1' then
	        currentState <= S0;
	    else
	        if rising_edge(clock) then
	            currentState <= nextState;
	        end if;
	    end if;
	end process;
	-- memory register (DO NOT CHANGE OR REMOVE THIS LINE)
	
	
	-- output-logic (DO NOT CHANGE OR REMOVE THIS LINE)
	stateBC <= currentState;
	erro <= '1' when currentState = E else '0';
	pronto <= '1' when (currentState = S0 or currentState = E) else '0';
	scont <= '1' when (currentState = S1) else '0';
	ccont <= '1' when (currentState = S1 or currentState = S3) else '0';
	zAC <= '1' when (currentState = S1) else '0';
	cAC <= '1' when (currentState = S1 or currentState = S3) else '0';
	cT <= '1' when (currentState = S1 or currentState = S3) else '0';
    -- end-output-logic (DO NOT CHANGE OR REMOVE THIS LINE)
end architecture;
