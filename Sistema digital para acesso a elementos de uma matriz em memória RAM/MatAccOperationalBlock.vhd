library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity MatAccOperationalBlock is
	generic(	NumBitsI, numBitsJ, numBitsAddr: positive;
				NL: positive;
				MC: positive;
				BaseAddr: positive;
				Bytes: positive);
	port(
		-- control inputs
		clock, reset: in std_logic;
		wren, lden: in std_logic; -- write enable, load enable (can be activated by one pulse only)
		-- data inputs
		i: in  std_logic_vector(NumBitsI-1 downto 0); -- line position to be accessed
		j: in  std_logic_vector(NumBitsJ-1 downto 0); -- column position position to be accessed
		dataIn: in std_logic_vector(8*Bytes-1 downto 0); -- data to be written
		-- data outputs
		dataOut: out std_logic_vector(8*Bytes-1 downto 0); -- data readed
		-- command inputs (from control block)
		cmdLoadInputs, cmdEnbCount, cmdEnbMemOp: in std_logic;
		-- status outputs (to control block)
		sttMemOpsDone, sttMemLoad: out std_logic;
		-- interface to external RAM memory contaning the matrix
		memQ: in std_logic_vector(7 downto 0);
		memData: out std_logic_vector(7 downto 0);
		memAddress: out std_logic_vector(numBitsAddr-1 downto 0);
		memWren: out std_logic
	);	
end entity;

architecture structural of MatAccOperationalBlock  is
	component registerN is
		generic(	width: positive;
					resetValue: integer := 0 );
		port(	-- control
				clock, reset, load: in std_logic;
				-- data
				input: in std_logic_vector(width-1 downto 0);
				output: out std_logic_vector(width-1 downto 0));
	end component;

	component moduleCounter is
		generic(	module: positive;
					generateLoad: boolean;
					generateEnb: boolean;
					generateInc: boolean;
					resetValue: integer := 0 );
		port(	-- control
				clock, reset: in std_logic;
				load, enb, inc: in std_logic;
				-- data
				input: in std_logic_vector(integer(ceil(log2(real(module))))-1 downto 0);
				output: out std_logic_vector(integer(ceil(log2(real(module))))-1 downto 0)	);
	end  component;
    -- internal signals
	signal addressElement: integer := 0;
	signal offsetIntValue: integer := 0;
	signal init: std_logic_vector(1 downto 0) := "00"; --[1]:wren, [0]:lden 
	signal RegWrenLden_output: std_logic_vector(1 downto 0) := "00"; --[1]:wren, [0]:lden
	signal RegI_output: std_logic_vector(i'length-1 downto 0) := (others=>'0');
	signal RegJ_output: std_logic_vector(j'length-1 downto 0) := (others=>'0');
	signal RegDataIn_output: std_logic_vector(dataIn'length-1 downto 0) := (others=>'0');
	signal Offset_output: std_logic_vector(integer(ceil(log2(real(Bytes))))-1 downto 0) := (others=>'0');
	signal loadRegDataOut: std_logic_vector(Bytes-1 downto 0) := (others=>'0');
begin
	-- save input data
	init <= wren & lden;
	RegWrenLden: registerN generic map(width=>2) port map(clock, reset, load=>cmdLoadInputs, input=>init, output=>RegWrenLden_output);
	RegI: registerN generic map(width=>i'length) port map(clock, reset, load=>cmdLoadInputs, input=>i, output=>RegI_output);
	RegJ: registerN generic map(width=>j'length) port map(clock, reset, load=>cmdLoadInputs, input=>j, output=>RegJ_output);
	RegDataIn: registerN generic map(width=>dataIn'length) port map(clock, reset, load=>cmdLoadInputs, input=>dataIn, output=>RegDataIn_output);
	-- offset
	Offset: moduleCounter generic map(module=>Bytes, generateLoad=>true, generateEnb=>true, generateInc=>false)
					port map(clock=>clock, reset=>reset, load=>cmdLoadInputs, enb=>cmdEnbCount, inc=>'0', input=>std_logic_vector(to_unsigned(0, integer(ceil(log2(real(Bytes)))))), output=>Offset_output);



	-- calculate element memory address
	offsetIntValue <= to_integer(unsigned(Offset_output));
	addressElement <= BaseAddr + Bytes*(to_integer(unsigned(RegI_output))*MC + to_integer(unsigned(RegJ_output))) + offsetIntValue;

	-- set address to the memory
	memAddress <= std_logic_vector(to_unsigned(addressElement, numBitsAddr));

	-- set data to the memory (for writing ops)
	memData <= RegDataIn_output(7+(offsetIntValue*8) downto (offsetIntValue*8));

	-- set memory operation
	memWren <= '1' when cmdEnbMemOp = '1' and RegWrenLden_output(1) = '1' else '0';

	-- generate element data out registers 
	genRegDataOut: for x in 0 to Bytes-1 generate
		RegDataOut_x:  registerN generic map(width=>8) port map(clock, reset, load=>loadRegDataOut(x), input=>memQ, output=>dataOut((x+1)*8-1 downto x*8));
	end generate;

	-- define if (and which) data out register will be loaded
	genLoadRegDataOut: for x in 0 to Bytes-1 generate
		loadRegDataOut(x) <= '1' when (x = offsetIntValue and RegWrenLden_output(0) = '1') else '0';
	end generate;

	-- set status
	sttMemOpsDone <= '1' when offsetIntValue = Bytes-1 else '0';
	sttMemLoad <= '1' when RegWrenLden_output(0) = '1' else '0';
end;
