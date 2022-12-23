library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bc is
	generic(largura: positive := 8);
	port(
		-- control in
		ck, Reset, iniciar: in std_logic;
		Az, Bz: in std_logic;
		-- control out
		mP, cP, mA, cA, cB, cmult, m1, m2, op: buffer std_logic;
		pronto: out std_logic
		-- data in
		-- data out
	);
end entity;

architecture descricaoComportamental of bc is
    type state is (S0, S1, S2, S3, S4, S5);
    signal currentState, nextState: state;
begin
	-- logica de proximo estado
	process(currentState, iniciar, Az, Bz) is
	begin
	    nextState <= currentState;
	    case currentState is
	        when S0 =>
	            if iniciar = '1' then
	                nextState <= S1;
	            end if;
	        when S1 =>
	            nextState <= S2;
	        when S2 =>
                if Az = '1' or Bz = '1' then
                    nextState <= S5;
                else
                    nextState <= S3;
                end if;
	        when S3 =>
	            nextState <= S4;
	        when S4 =>
	            nextState <= S2;
	        when S5 =>
	            nextState <= S0;
	    end case;
	end process;
	
	-- estado interno (registrador)
	process(ck, Reset) is
	begin
	    if Reset = '1' then
	        currentState <= S0;
	    elsif rising_edge(ck) then
	        currentState <= nextState;
	    end if;
	end process;
	-- logicas de saida
	mP <= '1' when currentState = S1 else '0';
	cP <= '1' when currentState = S1 or currentState = S3 else '0';
	mA <= '1' when currentState = S1 else '0';
	cA <= '1' when currentState = S1 or currentState = S4 else '0';
	cB <= '1' when currentState = S1 else '0';
	m1 <= '1' when currentState = S4 else '0';
	m2 <= '1' when currentState = S4 else '0';
	op <= '1' when currentState = S4 else '0';
	cmult <= '1' when currentState = S5 else '0';
	pronto <= '1' when currentState = S0 else '0';
end architecture;
