library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

------------------
-- ** ATENCAO !!!!! **
-- PREENCHA O NOME DOS ALUNOS QUE ESTAO FAZENDO ESTA AVALIACAO
-- ** SE O NOME NAO FOR PREENCHIDO, A NOTA DA AVALIACAO SERAH ZERO **
-- 
-- NOME DO ALUNO 1: 
-- NOME DO ALUNO 2:

entity MatAccControlBlock is
	port(
		-- control inputs
		clock, reset: in std_logic;
		init: in std_logic;
		-- control outputs
		done: out std_logic;
		-- status intputs (from operational block)
		sttMemOpsDone, sttMemLoad: in std_logic;
		-- command outputs (to operational block)
		cmdLoadInputs, cmdEnbCount, cmdEnbMemOp: out std_logic
	);	
end entity;

architecture behav of MatAccControlBlock is
	type State is (GettingMemoryData, LoadingInputs, SettingMemoryOperation, Waiting);
	signal currentState, nextState: State;
begin
	-- next-state logic
	process(currentState, sttMemOpsDone, sttMemLoad, init) is
	begin
	    nextState <= currentState;
	    case currentState is
	        when GettingMemoryData =>
	            nextState <= SettingMemoryOperation;
	        when LoadingInputs =>
	            nextState <= SettingMemoryOperation;
	        when SettingMemoryOperation =>
	            if sttMemOpsDone = '1' then
	                nextState <= Waiting;
	            else
	                if sttMemLoad = '1' then
	                    nextState <= GettingMemoryData;
	                end if;
	            end if;
	        when Waiting =>
	            if init = '1' then
	                nextState <= LoadingInputs;
	            end if;
	    end case;
	end process;
	
	-- state-register
	process(reset, clock) is
	begin
		if reset='1' then
			currentState <= Waiting;
		elsif rising_edge(clock) then
			currentState <= nextState;
		end if;
	end process;
	
	-- output-logic
	done <= '1' when currentState = Waiting else '0';
	cmdLoadInputs <= '1' when currentState = LoadingInputs else '0';
	cmdEnbCount <= '1' when currentState = GettingMemoryData else '0';
	cmdEnbMemOp <= '1' when currentState = SettingMemoryOperation else '0';
end;