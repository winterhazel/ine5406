library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grayEncoder is
	generic(width: natural);
	port(	binInput: in std_logic_vector(width-1 downto 0);
			grayOutput: out std_logic_vector(width-1 downto 0) );
end entity;

architecture concurrent_behav0 of grayEncoder is
	signal localInput: std_logic_vector(width downto 0);
begin
	localInput <= std_logic_vector(resize(unsigned(binInput), width+1));
	gBits: for i in binInput'range generate
		grayOutput(i) <= localInput(i) xor localInput(i+1);
	end generate;
end architecture;