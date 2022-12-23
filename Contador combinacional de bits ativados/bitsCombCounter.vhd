library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity bitsCombCounter is
	generic(
	    N: positive ;
        count1s: boolean := true
	);
	port(   
	    input: in std_logic_vector(N-1 downto 0);
		output: out std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0) 
	);
end entity;

architecture sequential_behavour_thats_a_hint of bitsCombCounter is
begin
	process(input)
		variable ones: integer := 0;
	begin
		ones := 0;
		for i in input'range loop
			if input(i) = '1' then
				ones := ones + 1;
			end if;
		end loop;
		if count1s then
			output <= std_logic_vector(to_unsigned(ones, integer(ceil(log2(real(N))))));
		else
			output <= std_logic_vector(to_unsigned(N-ones, integer(ceil(log2(real(N))))));
		end if;
	end process;
end architecture;