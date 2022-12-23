library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blocooperativo_sad is
	generic(
		datawidth: positive;
		addresswidth: positive);
	port(
		-- control in
		ck, reset, zi, ci, cpA, cpB, zsoma, csoma, csad_reg : in std_logic;
		-- data in
		pA, pB: in std_logic_vector(datawidth-1 downto 0);
		-- controll out
		ender: out std_logic_vector(addresswidth-1 downto 0);
		menor: out std_logic;
		sad: out std_logic_vector(datawidth+addresswidth-1 downto 0)
	);
end entity;

architecture archstruct of blocooperativo_sad is
    component registerN is
	generic(width: natural;
	        resetValue: integer := 0 );
	port(clock, reset, load: in std_logic;
	    input: in std_logic_vector(width-1 downto 0);
		output: out std_logic_vector(width-1 downto 0));
    end component;

    component multiplexer2x1 is
    	generic(	width: positive);
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
--	begin
--		assert (isAdder or isSubtractor) report "Pelo menos um dos parametros generic deve ser true" severity error;		
    end component;

    component absN is
	generic(	width: positive );
	port(	input: in std_logic_vector(width-1 downto 0);
			output: out std_logic_vector(width-1 downto 0) );
    end component;
    
    -- sinais
    signal out_addI, out_muxI, out_regI: std_logic_vector(addresswidth downto 0) := (others => '0');
    signal out_regpA, out_regpB, out_subAB: std_logic_vector(datawidth-1 downto 0) := (others => '0');
    signal operandB_sadAdd, out_sadAdd, out_muxSoma, out_soma: std_logic_vector(datawidth+addresswidth-1 downto 0) := (others => '0');
begin
    -- endereco
    muxI: multiplexer2x1
        generic map(width=>addresswidth+1)
        port map(input0=>out_addI, 
            input1=>std_logic_vector(to_unsigned(0, addresswidth+1)), 
            sel=>zi, output=>out_muxI);
    regI: registerN
        generic map(width=>addresswidth+1, resetValue=>0)
        port map(clock=>ck, reset=>reset, load=>ci, input=>out_muxI, 
            output=>out_regI);
    menor <= not out_regI(out_regI'high);
    ender <= out_regI(ender'range);
    addI: addersubtractor
        generic map(N=>addresswidth, isAdder=>true, isSubtractor=>false)
        port map(op=>'0', a=>out_regI(ender'range), 
            b=>std_logic_vector(to_unsigned(1, addresswidth)), 
            result=>out_addI(addresswidth-1 downto 0), 
            ovf=>open, cout=>out_addI(addresswidth));
    
    
    -- calculo do sad
    regpA: registerN
        generic map(width=>datawidth, resetValue=>0)
        port map(clock=>ck, reset=>reset, load=>cpA, input=>pA, 
            output=>out_regpA);
    regpB: registerN
        generic map(width=>datawidth, resetValue=>0)
        port map(clock=>ck, reset=>reset, load=>cpB, input=>pB, 
            output=>out_regpB);
    subAB: addersubtractor
        generic map(N=>datawidth, isAdder=>false, isSubtractor=>true)
        port map(op=>'0', a=>out_regpA, b=>out_regpB, 
            result=>out_subAB, ovf=>open, cout=>open);
    absSub: absN
        generic map(width=>datawidth)
        port map(input=>out_subAB, output=>operandB_sadAdd(datawidth-1 downto 0));
    operandB_sadAdd(datawidth+addresswidth-1 downto datawidth) <= (others=>'0');
    sadAdd: addersubtractor
        generic map(N=>datawidth+addresswidth, isAdder=>true, isSubtractor=>false)
        port map(op=>'0', a=>out_soma, b=>operandB_sadAdd, 
            result=>out_sadAdd, ovf=>open, cout=>open);
    muxSoma: multiplexer2x1
        generic map(width=>addresswidth+datawidth)
        port map(input0=>out_sadAdd, 
            input1=>std_logic_vector(to_unsigned(0, addresswidth+datawidth)), 
            sel=>zsoma, output=>out_muxSoma);
    
    regSoma: registerN
        generic map(width=>addresswidth+datawidth, resetValue=>0)
        port map(clock=>ck, reset=>reset, load=>csoma, input=>out_muxSoma, 
            output=>out_soma);
    
    SAD_reg: registerN
        generic map(width=>addresswidth+datawidth, resetValue=>0)
        port map(clock=>ck, reset=>reset, load=>csad_reg, input=>out_soma, 
            output=>sad);

end architecture;