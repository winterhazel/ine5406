library ieee;
use ieee.std_logic_1164.all;

entity multiseq is
	generic(largura: positive := 8);
	port(
		-- control in
		ck, Reset, iniciar: in std_logic;
		-- control out
		pronto: out std_logic;
		-- data in
		entA, entB: in std_logic_vector(largura-1 downto 0);
		-- data out
		mult: out std_logic_vector(largura-1 downto 0)
	);
end entity;

architecture descricaoEstrutural of multiseq is
	component bo is
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
    end component;
    component bc is
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
    end component;
    
    signal s_Az, s_Bz, s_mP, s_cP, s_mA, s_cA, s_cB, s_cmult, s_m1, s_m2, s_op: std_logic;
begin
    m_bc: bc
        generic map(largura=>largura)
        port map(ck=>ck, Reset=>Reset, iniciar=>iniciar, Az=>s_Az, Bz=>s_Bz, 
        mP=>s_mP, cP=>s_cP, mA=>s_mA, cA=>s_cA, cB=>s_cB, cmult=>s_cmult, 
        m1=>s_m1, m2=>s_m2, op=>s_op);
    m_bo: bo
        generic map(largura=>largura)
        port map(ck=>ck, Reset=>Reset, mP=>s_mP, cP=>s_cP, mA=>s_mA, cA=>s_cA, 
        cB=>s_cB, cmult=>s_cmult, m1=>s_m1, m2=>s_m2, op=>s_op, Az=>s_Az, Bz=>s_Bz,
        entA=>entA, entB=>entB, mult=>mult);
end architecture;
