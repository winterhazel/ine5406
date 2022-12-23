library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blocoOperativo4T is
	generic(width_ent: positive;
			width_n: positive);
	port(
		-- control in
		clock, reset: in std_logic;
		-- control in (command signals from BC)
		scont, ccont, zAC, cAC, cT: in std_logic;		
		-- control out (status signals to BC)
		zero, ov: out std_logic;
		-- data in
		ent: in std_logic_vector(width_ent-1 downto 0);
		n: in std_logic_vector(width_n-1 downto 0);
		-- data out
		soma: out std_logic_vector(width_ent-1 downto 0) 
	);
end entity;


architecture descricaoEstrutural of blocoOperativo4T is
	component multiplexer2x1 is
		generic (	width: positive );
		port(	input0, input1: in std_logic_vector(width-1 downto 0);
				sel: in std_logic;
				output: out std_logic_vector(width-1 downto 0) );
	end component;
	component addersubtractor is
		generic (	N: positive;
					isAdder: boolean;
					isSubtractor: boolean;
					generateOvf: boolean);
		port(	op: in std_logic;
				a, b: in std_logic_vector(N-1 downto 0);
				result: out std_logic_vector(N-1 downto 0);
				ovf, cout: out std_logic );
	end component;
	component registerN is
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
	-- COMPLETE COM EVENTUAIS SINAIS INTERNOS
	signal out_sub0, out_muxcont, out_cont: std_logic_vector(width_n-1 downto 0);
	signal out_adder0, out_muxAC, out_AC, out_T: std_logic_vector(width_ent-1 downto 0);
begin
	-- COMPLETE COM EVENTUAIS COMANDOS CONCORRENTES
    -- COMPLETE OS COMANDOS DE INSTANCIACAO ABAIXO
	mux0: multiplexer2x1 
			generic map(width=>width_n)
			port map(input0=>out_sub0, input1=>n, sel=>scont, 
			output=>out_muxcont);
	cont: component registerN 
			generic map(width=>width_n)
			port map(clock=>clock, reset=>reset, load=>ccont,
				input=>out_muxcont,	output=>out_cont);
	subtractor0: addersubtractor 
			generic map(N=>width_n, isAdder=>false, isSubtractor=>true, 
			generateOvf=>false)
			port map(op=>'0', a=>out_cont, 
			b=>std_logic_vector(to_unsigned(1, width_n)), result=>out_sub0, 
			ovf=>open, cout=>open);
	compare0: compare
			generic map (width=>width_n, isSigned=>false, 
			generateLessThan=>false,generateEqual=>true)
			port map (input0=>out_cont, 
			input1=>std_logic_vector(to_unsigned(0, width_n)), 
			lessThan=>open, equal=>zero);
			
	mux1: multiplexer2x1 
			generic map(width=>width_ent)
			port map(input0=>out_adder0, 
			input1=>std_logic_vector(to_unsigned(0, width_ent)), sel=>zAC, 
			output=>out_muxAC);
	AC: component registerN 
			generic map(width=>width_ent)
			port map(clock=>clock, reset=>reset, load=>cAC,
			input=>out_muxAC,output=>out_AC);
	T: component registerN 
			generic map(width=>width_ent)
			port map(clock=>clock, reset=>reset, load=>cT,
            input=>ent, output=>out_T);
    adder0: addersubtractor 
			generic map(N=>width_ent, isAdder=>true, isSubtractor=>false, 
			generateOvf=>true)
			port map(op=>'0', a=>out_AC, b=>out_T, result=>out_adder0, ovf=>open, 
			cout=>ov);
	soma <= out_AC;
end architecture;
