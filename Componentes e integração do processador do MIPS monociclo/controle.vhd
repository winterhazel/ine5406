library ieee;
use ieee.std_logic_1164.all;

entity controle is
	port(
	    -- control inputs (status)
		Opcode: in std_logic_vector(5 downto 0);
		-- control outputs (commands)
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: out std_logic;
		ULAOp: out std_logic_vector(1 downto 0)
	);
end entity;

architecture comportamento of controle is
    constant tipo_r: std_logic_vector(Opcode'range) := "000000";
    constant load: std_logic_vector(Opcode'range) := "100011";
    constant store: std_logic_vector(Opcode'range) := "101011";
    constant beq: std_logic_vector(Opcode'range) := "000100";
    constant jump: std_logic_vector(Opcode'range) := "000010";
    constant bne: std_logic_vector(Opcode'range) := "000101";
    constant addI: std_logic_vector(Opcode'range) := "001000";
begin
    RegDst <= '1' when Opcode = tipo_r else '0';
	DvCeq <= '1' when Opcode = beq else '0';
	DvCne <= '0';
	DvI <= '1' when Opcode = jump else '0';
	LerMem <= '1' when Opcode = load else '0';
	MemParaReg <= '1' when Opcode = load else '0';
	EscMem <= '1' when Opcode = store else '0';
	ULAFonte <= '1' when Opcode = load or Opcode = store else '0';
	EscReg <= '1' when Opcode = tipo_r or Opcode = load or OpCode = addI else '0';
    ULAOp <= "00" when Opcode = load or Opcode = store else
        "01" when Opcode = beq or Opcode = bne else
        "10";
end architecture;