library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerN is
	generic(	width: natural;
				resetValue: integer := 0 );
	port(	-- control
			clock, reset, load: in std_logic;
			-- data
			input: in std_logic_vector(width-1 downto 0);
			output: out std_logic_vector(width-1 downto 0));
end entity;

architecture behav0 of registerN is
    subtype state is unsigned(input'range);
    signal currentState, nextState: state;
begin
	-- logica de proximo estado
	nextState <= unsigned(input) when load = '1' 
	    else to_unsigned(resetValue, input'length) when reset = '1'
	    else currentState;

	-- estado interno (registrador)
	process(clock) is
	begin
	    if rising_edge(clock) then
	        currentState <= nextState;
	    end if;
	end process;
	
	-- logicas de saida
	output <= std_logic_vector(currentState);
end architecture;