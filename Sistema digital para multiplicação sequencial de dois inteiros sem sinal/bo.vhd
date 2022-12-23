library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bo is
	generic(largura: positive := 8);
	port(
		-- control in
		ck, Reset: in std_logic;
		mP, cP, mA, cA, cB, cmult, m1, m2, op: in std_logic;
		-- control out
		Az, Bz: out std_logic;
		-- data in
		entA, entB: in std_logic_vector(largura-1 downto 0);
		-- data out
		mult: out std_logic_vector(largura-1 downto 0)
	);
end entity;

architecture descricaoEstrutural of bo is
component  registerN is
	generic(	width: natural;
				resetValue: integer := 0 );
	port(	-- control
			clock, reset, load: in std_logic;
			-- data
			input: in std_logic_vector(width-1 downto 0);
			output: out std_logic_vector(width-1 downto 0));
	end component;
	component compare is
	generic(	width: natural;
				isSigned: boolean;
				generateLessThan: boolean;
				generateEqual: boolean );
	port(	input0, input1: in std_logic_vector(width-1 downto 0);
			lessThan, equal: out std_logic );
	end component;
	component multiplexer2x1 is
	generic(	width: positive );
	port(	input0, input1: in std_logic_vector(width-1 downto 0);
			sel: in std_logic;
			output: out std_logic_vector(width-1 downto 0) );
	end component;
	component addersubtractor is
	generic(	N: positive;
				isAdder: boolean;
				isSubtractor: boolean );
	port(	op: in std_logic;
			a, b: in std_logic_vector(N-1 downto 0);
			result: out std_logic_vector(N-1 downto 0);
			ovf, cout: out std_logic );
	end component;
	
	signal out_addsub, out_muxP, out_regP, out_muxA, out_regA, out_mux1, 
	out_regB, out_mux2: std_logic_vector(largura-1 downto 0);
begin
    muxP: multiplexer2x1 
        generic map(width=>largura)
        port map(input0=>out_addsub, 
        input1=>std_logic_vector(to_unsigned(0, largura)), sel=>mP, 
        output=>out_muxP);
    regP: registerN 
        generic map(width=>largura)
        port map(clock=>ck, reset=>Reset, load=>cP, input=>out_muxP, 
        output=>out_regP);
    
    muxA: multiplexer2x1 
        generic map(width=>largura)
        port map(input0=>out_addsub, input1=>entA, sel=>mA, output=>out_muxA);
    regA: registerN 
        generic map(width=>largura)
        port map(clock=>ck, reset=>Reset, load=>cA, input=>out_muxA, 
        output=>out_regA);
    comparaA: compare
        generic map(width=>largura, isSigned=>false, generateLessThan=>false, 
        generateEqual=>true)
        port map(input0=>out_regA, 
        input1=>std_logic_vector(to_unsigned(0, largura)), lessThan=>open,
        equal=>Az);

    mux1: multiplexer2x1 
        generic map(width=>largura)
        port map(input0=>out_regP, input1=>out_regA, sel=>m1, output=>out_mux1);
    
    regB: registerN 
        generic map(width=>largura)
        port map(clock=>ck, reset=>Reset, load=>cB, input=>entB, 
        output=>out_regB);
    comparaB: compare
        generic map(width=>largura, isSigned=>false, generateLessThan=>false, 
        generateEqual=>true)
        port map(input0=>out_regB, 
        input1=>std_logic_vector(to_unsigned(0, largura)), lessThan=>open,
        equal=>Bz);
        
    mux2: multiplexer2x1 
        generic map(width=>largura)
        port map(input0=>out_regB, 
        input1=>std_logic_vector(to_unsigned(1, largura)), sel=>m2, 
        output=>out_mux2);
    
    addsub: addersubtractor
        generic map(N=>largura, isAdder=>true, isSubtractor=>true)
        port map(op=>op, a=>out_mux1, b=>out_mux2, result=>out_addsub, ovf=>open,
        cout=>open);
    
    regMult: registerN
        generic map(width=>largura)
        port map(clock=>ck, reset=>Reset, load=>cmult, input=>out_muxP, 
        output=>mult);
end architecture;
