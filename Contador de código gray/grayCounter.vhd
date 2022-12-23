-- Complete abaixo com o nome dos alunos que fazem esta avaliacao (sem caracteres especiais nos nomes, como acentos)
-- ALUNO 1:
-- ALUNO 2:

-- Um codificador gray recebe um valor binario B de N bits e devolve um valor gray G de N bits, em que cada bit i do codigo gray eh dado por G[i] = b[i+1] xor b[i]. Considere B[N]=0
-- Um decodificador gray recebe um valor gray G de N bits e devolve um valor binario B de N bits, em que cada bit i do valor binario eh dado por B[i] = B[i+1] xor G[i]. Considere B[N]=0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grayCounter is
	generic(	width: positive := 16;
				generateLoad: boolean := true;
				generateEnb: boolean := true;
				generateInc: boolean := true;
				resetValue: integer := 0 );
	port(	-- control
			clock, reset, load: in std_logic;
			enb, inc: in std_logic;
			-- data
			input: in std_logic_vector(width-1 downto 0);
			output: out std_logic_vector(width-1 downto 0)	);
end entity;


architecture behav0 of grayCounter is
    -- Nao altere as duas linhas abaixo
    subtype state is signed(width-1 downto 0);
    signal nextState, currentState: state;
    -- COMPLETE AQUI, SE NECESSARIO
begin
	-- next-state logic (DO NOT CHANGE OR REMOVE THIS LINE)
	-- isso aqui tá muito feio. tem uma maneira melhor pra fazer sem utilizar process
	-- basicamente, se ele não gerar o load, é como se o load tivesse o valor padrão 0
	-- a mesma coisa para as outras entradas. se ele não gerar o inc, é como se o inc tivesse o valor padrão 1
	-- aí é só conferir qual deve ser o valor do load, inc e enb baseado nisso e aplicar
	process(currentState, nextState, input, load, enb, inc) is
	begin
	    -- TTT
	    nextState <= currentState;
	    if generateLoad and generateEnb and generateInc then
	        if load = '1' then
	            for i in nextState'range loop
	                if i = nextState'high then
	                    nextState(i) <= input(i);
	                else
	                    nextState(i) <= nextState(i+1) xor input(i);
	                end if;
	            end loop;
	        else 
	            if enb = '1' then
                    if inc = '1' then
                        nextState <= currentState + 1;
                    else
                        nextState <= currentState - 1;
                    end if;
	            end if;
	        end if;
	    end if;
	    -- TTF
	    -- TFT
	    -- FTT
	    if (not generateLoad) and generateEnb and generateInc then
	        if enb = '1' then
                    if inc = '1' then
                        nextState <= currentState + 1;
                    else
                        nextState <= currentState - 1;
                    end if;
	            end if;
	    end if;
	    -- FFT
	    if (not generateLoad) and (not generateEnb) and generateInc then
	        if inc = '1' then
                        nextState <= currentState + 1;
                    else
                        nextState <= currentState - 1;
                    end if;
	    end if;
	    -- FTF
	    -- TFF
	    -- FFF
	    if (not generateLoad) and (not generateEnb) and (not generateInc) then
	        nextState <= currentState + 1;
	    end if;
	end process;
	-- end-next-state logic (DO NOT CHANGE OR REMOVE THIS LINE)
	
	
	-- memory register (DO NOT CHANGE OR REMOVE THIS LINE)
	process(clock, reset) is
	begin
		if reset='1' then
			currentState <= (to_signed(resetValue, currentState'length));
		elsif rising_edge(clock) then
			currentState <= nextState;
		end if;
	end process;
	-- memory register (DO NOT CHANGE OR REMOVE THIS LINE)
	
	
	-- output-logic (DO NOT CHANGE OR REMOVE THIS LINE)
    x: for i in currentState'range generate
        y: if i = currentState'high generate
            output(i) <= std_logic(currentState(i));
        end generate;
        z: if i /= currentState'high generate
            output(i) <= std_logic(currentState(i+1) xor currentState(i));
        end generate;
    end generate;
    -- end-output-logic (DO NOT CHANGE OR REMOVE THIS LINE)
end architecture;
