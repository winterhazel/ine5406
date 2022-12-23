library ieee;
use ieee.std_logic_1164.all;

entity datapath is
	port(
	    -- control inputs
	    clock, clock_ram, reset: in std_logic;
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: in std_logic;
		ULAOp: in std_logic_vector(1 downto 0);
        -- control outputs
		Opcode: out std_logic_vector(5 downto 0);
		-- externalizando saídas das memorias, do banco de registradores e da ULA (PARA TESTES)
		InstrucaoLida, DadoLido, RegLido1, RegLido2, ULAResultado: out std_logic_vector(31 downto 0)
	);
end entity;

architecture estrutura of datapath is
	COMPONENT multiplexer2x1 IS
		GENERIC (width : POSITIVE);
		PORT (
			input0, input1 : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			sel : IN STD_LOGIC;
			output : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0));
	END COMPONENT;
	COMPONENT addersubtractor IS
		GENERIC (
			N : POSITIVE;
			isAdder : BOOLEAN;
			isSubtractor : BOOLEAN);
		PORT (
			op : IN STD_LOGIC;
			a, b : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			result : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			ovf, cout : OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT registerN IS
		GENERIC (
			width : NATURAL;
			resetValue : INTEGER := 0);
		PORT (
			clock, reset, load : IN STD_LOGIC;
			input : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0));
	END COMPONENT;
	COMPONENT ramInstrucoes IS
		GENERIC (
			datawidth: positive := 32; -- deixe sempre em 32 para o projeto do MIPS
			addresswidth: positive := 32 -- deixe sempre em 32 para o projeto do MIPS (esse valor sera simplesmente ignorado)
		);
		PORT (
			-- control in
			ck, reset, readd, writee : IN STD_LOGIC;
			-- data in
			datain : IN STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0);
			address : IN STD_LOGIC_VECTOR(addresswidth - 1 DOWNTO 0);
			-- controll out
			dataout : OUT STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ramDados IS
		GENERIC (
			datawidth: positive := 32; -- deixe sempre em 32 para o projeto do MIPS
		addresswidth: positive := 32 -- deixe sempre em 32 para o projeto do MIPS (esse valor sera simplesmente ignorado)
		);
		PORT (
			-- control in
			ck, reset, readd, writee : IN STD_LOGIC;
			-- data in
			datain : IN STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0);
			address : IN STD_LOGIC_VECTOR(addresswidth - 1 DOWNTO 0);
			-- controll out
			dataout : OUT STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT deslocador IS
		GENERIC (
			larguraDados : POSITIVE;
			numBitsDeslocar : INTEGER;
			deslocaParaDireita : BOOLEAN;
			deslocaParaEsquerda : BOOLEAN
		);
		PORT (
			Entrada : IN STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
			direcao : IN STD_LOGIC; --0: deslocaParaDireita, 1: deslocaParaEsquerda
			Saida : OUT STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT extensaoSinal IS
		GENERIC (
			larguraSaida : INTEGER;
			larguraEntrada : INTEGER);
		PORT (
			entrada : IN STD_LOGIC_VECTOR(larguraEntrada - 1 DOWNTO 0);
			saida : OUT STD_LOGIC_VECTOR(larguraSaida - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT bancoRegistradores IS
		GENERIC (
			numBitsDefineReg : POSITIVE;
			larguraRegistrador : POSITIVE
		);
		PORT (
			clock,  reset: in std_logic;
			RegASerLido1, RegASerLido2, RegASerEscrito: in std_logic_vector(numBitsDefineReg-1 downto 0);
			DadoDeEscrita: in std_logic_vector(larguraRegistrador-1 downto 0);
			EscReg: in std_logic;
			DadoLido1, DadoLido2: out std_logic_vector(larguraRegistrador-1 downto 0)
		);
	END COMPONENT;
	COMPONENT operacaoULA IS
		PORT (
			ULAOp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ULA IS
		GENERIC (width : POSITIVE);
		PORT (
			op : IN STD_LOGIC_VECTOR(2 DOWNTO 0); --000:AND , 001:OR , 010:ADD, 110:SUB, 111:SLT
			a, b : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			zero : OUT STD_LOGIC;
			res : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0)
		);
	END COMPONENT;
    -- COMPLETE 
    
    -- PC e Memoria de Instrucoes
    signal cPC, FontePC: std_logic;
    signal ent_PC, out_PC, instrucao, PC_4, shift_deslocam,
           jump_address, beq_address, PC_4_or_beq_address: std_logic_vector(31 downto 0);
    signal shift_jump_const: std_logic_vector(27 downto 0);
    
    -- Registradores
    signal reg_a_ser_escrito: std_logic_vector(4 downto 0);
    signal reg_dado_escrita, dado_lido1, dado_lido2 : std_logic_vector(31 downto 0);
    
    -- ULA
    signal funct_deslocam_ext, ULA_b, ULA_resultado: std_logic_vector(31 downto 0);
    signal ULA_op: std_logic_vector(2 downto 0);
    signal ULA_zero: std_logic;
    
    -- Memoria dado
    signal dado_lido: std_logic_vector(31 downto 0);
begin
    PC: RegisterN
		generic map(width => 32)
		port map(
			clock => clock, reset => reset, load => cPC,
			input => ent_PC, output => out_PC
		);

    mem_instrucoes: ramInstrucoes
		port map(
			-- control in
			ck => clock_ram, reset => reset, readd => '1', writee => '0',
			-- data in
			datain => (others => '0'),
			address => out_PC,
			-- controll out
			dataout => instrucao
		);
	
	InstrucaoLida <= instrucao;
	Opcode <= instrucao(31 downto 26);
	
	
	reg_a_ser_escrito <= instrucao(15 downto 11) when RegDst = '1' else instrucao(20 downto 16);
	
	
    reg_dado_escrita <= dado_lido when MemParaReg = '1' else ULA_resultado;
	
	regs: bancoRegistradores
		generic map(
			numBitsDefineReg => 5,
			larguraRegistrador => 32
		)
		port map(
			clock => clock,  reset => reset,
			RegASerLido1 => instrucao(25 downto 21),
			RegASerLido2 => instrucao(20 downto 16),
			RegASerEscrito => reg_a_ser_escrito,
			DadoDeEscrita => reg_dado_escrita,
			EscReg => EscReg,
			DadoLido1 => dado_lido1,
			DadoLido2 => dado_lido2
		);


	ext_funct: extensaoSinal
		generic map(
			larguraEntrada => 16,
			larguraSaida => 32
		)
		port map(
			entrada => instrucao(15 downto 0),
			saida => funct_deslocam_ext
		);
	
	ULA_b <= funct_deslocam_ext when ULAFOnte = '1' else dado_lido2;

	opula: operacaoULA
		port map(
			ULAOp => ULAOp,
			Funct => instrucao(5 downto 0),
			op => ULA_op
		);

	ulaa: ULA
		generic map(width => 32)
		port map(
			op => ULA_op,
			a => dado_lido1,
			b => ULA_b,
			zero => ULA_zero,
			res => ULA_resultado
		);


    mem_dados: ramDados
		port map(
			-- control in
			ck => clock_ram, reset => reset, readd => LerMem, writee => EscMem,
			-- data in
			datain => dado_lido2,
			address => ULA_resultado,
			-- controll out
			dataout => dado_lido
		);



	pc_adder: addersubtractor
		generic map(
			N => 32,
			isAdder => true,
			isSubtractor => false
		)
		port map(
			a => out_PC, b => (2=>'1', others=>'0'),
			result => PC_4,
			op => '0', ovf => open, cout => open
		);
	
	shift_jump_const <= instrucao(25 downto 0) & "00";
	
	jump_address <= shift_jump_const & PC_4(31 downto 28);
	
	
	shift_deslocam <= funct_deslocam_ext(funct_deslocam_ext'high - 2 downto 0) & "00";
	
	beq_adder: addersubtractor
		generic map(
			N => 32,
			isAdder => true,
			isSubtractor => false
		)
		port map(
			a => PC_4, b => shift_deslocam,
			result => beq_address,
			op=>'0', ovf => open, cout => open
		);
		
	FontePC <= ULA_zero and DvCeq;
	PC_4_or_beq_address <= beq_address when FontePC = '1' else PC_4;
	
	ent_PC <= jump_address when DVI = '1' else PC_4_or_beq_address;
end architecture;