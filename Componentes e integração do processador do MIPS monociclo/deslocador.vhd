library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deslocador is
	generic(
		larguraDados: positive;
		numBitsDeslocar: integer;
		deslocaParaDireita: boolean;
		deslocaParaEsquerda: boolean
	);
	port(
		Entrada: in std_logic_vector(larguraDados-1 downto 0);
		direcao: in std_logic; --0: deslocaParaDireita, 1: deslocaParaEsquerda
		Saida: out std_logic_vector(larguraDados-1 downto 0)
	);
end entity;

architecture comportamento of Deslocador is
begin
    direita: if deslocaParaDireita and not deslocaParaEsquerda generate
        Saida <= std_logic_vector(shift_right(unsigned(Entrada), numBitsDeslocar));
    end generate;
    
    esquerda: if deslocaParaEsquerda and not deslocaParaDireita generate
        Saida <= std_logic_vector(shift_left(unsigned(Entrada), numBitsDeslocar));
    end generate;
    
    ambos: if deslocaParaDireita and deslocaParaEsquerda generate
        Saida <= std_logic_vector(shift_right(unsigned(Entrada), numBitsDeslocar)) when direcao = '0' else std_logic_vector(shift_left(unsigned(Entrada), numBitsDeslocar));
    end generate;
end architecture;