-- Complete abaixo com o nome dos alunos que fazem esta avaliacao (sem caracteres especiais nos nomes, como acentos)
-- ALUNO 1:
-- ALUNO 2:

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity moduleCounter is
	generic (
		module : positive := 60;
		generateLoad : boolean := true;
		generateEnb : boolean := true;
		generateInc : boolean := true;
		resetValue : integer := 0 
	);
	port (-- control
		clock, reset : in std_logic;
		load, enb, inc : in std_logic;
		-- data
		input : in std_logic_vector(integer(ceil(log2(real(module)))) - 1 downto 0);
		output : out std_logic_vector(integer(ceil(log2(real(module)))) - 1 downto 0) 
	);
end entity;
architecture behav0 of moduleCounter is
	-- Nao altere as duas linhas abaixo
	subtype state is unsigned(integer(ceil(log2(real(module)))) - 1 downto 0);
	signal nextState, currentState : state;
	-- COMPLETE AQUI, SE NECESSARIO
begin
	-- next-state logic (DO NOT CHANGE OR REMOVE THIS LINE)
	-- isso aqui tá muito feio. tem uma maneira melhor pra fazer sem utilizar process
	-- basicamente, se ele não gerar o load, é como se o load tivesse o valor padrão 0
	-- a mesma coisa para as outras entradas. se ele não gerar o inc, é como se o inc tivesse o valor padrão 1
	-- aí é só conferir qual deve ser o valor do load, inc e enb baseado nisso e aplicar
	process (currentState, load, enb, inc, input) is
	begin
		nextState <= currentState;
		if generateLoad then
			if load = '1' then
				nextState <= unsigned(input);
			else
				if generateEnb then
					if enb = '1' then
						if generateInc then
							if inc = '1' then
								if currentState < module - 1 then
									nextState <= currentState + 1;
								else
									nextState <= (to_unsigned(0, currentState'length));
								end if;
							else
								if currentState > 0 then
									nextState <= currentState - 1;
								else
									nextState <= (to_unsigned(module - 1, currentState'length));
								end if;
							end if;
						else
							if currentState < module - 1 then
								nextState <= currentState + 1;
							else
								nextState <= (to_unsigned(0, currentState'length));
							end if;
						end if;
					end if;
				else
					if generateInc then
						if inc = '1' then
							if currentState < module - 1 then
								nextState <= currentState + 1;
							else
								nextState <= (to_unsigned(0, currentState'length));
							end if;
						else
							if currentState > 0 then
								nextState <= currentState - 1;
							else
								nextState <= (to_unsigned(module - 1, currentState'length));
							end if;
						end if;
					else
						if currentState < module - 1 then
							nextState <= currentState + 1;
						else
							nextState <= (to_unsigned(0, currentState'length));
						end if;
					end if;
				end if;
			end if;
		else
			if generateEnb then
				if enb = '1' then
					if generateInc then
						if inc = '1' then
							if currentState < module - 1 then
								nextState <= currentState + 1;
							else
								nextState <= (to_unsigned(0, currentState'length));
							end if;
						else
							if currentState > 0 then
								nextState <= currentState - 1;
							else
								nextState <= (to_unsigned(module - 1, currentState'length));
							end if;
						end if;
					else
						if currentState < module - 1 then
							nextState <= currentState + 1;
						else
							nextState <= (to_unsigned(0, currentState'length));
						end if;
					end if;
				end if;
			else
				if generateInc then
					if inc = '1' then
						if currentState < module - 1 then
							nextState <= currentState + 1;
						else
							nextState <= (to_unsigned(0, currentState'length));
						end if;
					else
						if currentState > 0 then
							nextState <= currentState - 1;
						else
							nextState <= (to_unsigned(module - 1, currentState'length));
						end if;
					end if;
				else
					if currentState < module - 1 then
						nextState <= currentState + 1;
					else
						nextState <= (to_unsigned(0, currentState'length));
					end if;
				end if;
			end if;
		end if;
	end process;
	-- end-next-state logic (DO NOT CHANGE OR REMOVE THIS LINE)
 
 
	-- memory register (DO NOT CHANGE OR REMOVE THIS LINE)
	process (clock, reset) is
		begin
			if reset = '1' then
				currentState <= (to_unsigned(resetValue, currentState'length));
			elsif rising_edge(clock) then
				currentState <= nextState;
			end if;
		end process;
		-- memory register (DO NOT CHANGE OR REMOVE THIS LINE)
 
 
		-- output-logic (DO NOT CHANGE OR REMOVE THIS LINE)
		output <= std_logic_vector(currentState);
		-- end-output-logic (DO NOT CHANGE OR REMOVE THIS LINE)
end architecture;
