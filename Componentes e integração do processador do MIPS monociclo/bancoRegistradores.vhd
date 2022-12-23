-- ATENCAO: O Banco de registradores eh sensivel aa borda de descida do clock
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bancoRegistradores is
	generic(
		numBitsDefineReg: positive;
		larguraRegistrador: positive
	);
	port(
		clock,  reset: in std_logic;
		RegASerLido1, RegASerLido2, RegASerEscrito: in std_logic_vector(numBitsDefineReg-1 downto 0);
		DadoDeEscrita: in std_logic_vector(larguraRegistrador-1 downto 0);
		EscReg: in std_logic;
		DadoLido1, DadoLido2: out std_logic_vector(larguraRegistrador-1 downto 0)
	);
end entity;

architecture comportamento of bancoRegistradores is
	type TipoVetorRegistradores is array(0 to 2**numBitsDefineReg-1) of std_logic_vector(larguraRegistrador-1 downto 0);
    signal currentState, nextState: TipoVetorRegistradores;
begin
    -- LP
    process(RegASerEscrito, DadoDeEscrita, EscReg) is
    begin
        nextState <= currentState;
        if EscReg = '1' then
            nextState(to_integer(unsigned(RegASerEscrito))) <= DadoDeEscrita;
        end if;
    end process;
    
    -- EM
    -- ATENCAO: O Banco de registradores eh sensivel aa borda de descida do clock
    process(clock, reset) is
    begin
        if reset = '1' then
            for i in currentState'range loop
                currentState(i) <= (others=>'0');
            end loop;
        elsif falling_edge(clock) and EscReg = '1' then
            currentState <= nextState;
        end if;
    end process;
    
    -- LS
    DadoLido1 <= currentState(to_integer(unsigned(RegASerLido1)));
    DadoLido2 <= currentState(to_integer(unsigned(RegASerLido2)));
end architecture;