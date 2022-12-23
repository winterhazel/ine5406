library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity operacaoULA is
	port(
		ULAOp: in std_logic_vector(1 downto 0);
		Funct: in std_logic_vector(5 downto 0);
		op: out std_logic_vector(2 downto 0)
	);
end entity;

architecture Behavioral of operacaoULA is
begin
    op <= "010" when ULAOp="00" else 
        "110" when ULAOp="01" else 
		"111" when Funct="101010" else 
		"001" when Funct = "100101" else 
		"000" when Funct = "100100" else 
		"010" when Funct = "100000" else 
		"110";
end architecture;