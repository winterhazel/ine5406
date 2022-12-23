library ieee;
use ieee.std_logic_1164.all;

entity sd_sad is
	generic(
		datawidth: positive;
		addresswidth: positive);
	port(
		-- control in
		ck, reset, iniciar: in std_logic;
		-- data in
		pA, pB: in std_logic_vector(datawidth-1 downto 0);
		-- controll out
		ender: out std_logic_vector(addresswidth-1 downto 0);
		readmem, pronto: out std_logic;
		sad: out std_logic_vector(datawidth+addresswidth-1 downto 0)
	);
end entity;

architecture archstruct of sd_sad is
    component blococontrole_sad is
	port(
		-- control in
		ck, reset, iniciar, 
		menor : in std_logic;
		-- data in
		-- controll out
		zi, ci, cpA, cpB, zsoma, csoma, csad_reg, 
		readmem, pronto: out std_logic
		-- data out
	);
    end component;
    
    component blocooperativo_sad is
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
    end component;
    
    signal s_menor, s_zi, s_ci, s_cpA, s_cpB, s_zsoma, s_csoma, s_csad_reg: std_logic;
begin
    bc_sad: blococontrole_sad
        port map(ck=>ck, reset=>reset, iniciar=>iniciar, menor=>s_menor, 
            zi=>s_zi, ci=>s_ci, cpA=>s_cpA, cpB=>s_cpB, zsoma=>s_zsoma, 
            csoma=>s_csoma, csad_reg=>s_csad_reg, readmem=>readmem, 
            pronto=>pronto);
            
    bo_sad: blocooperativo_sad
        generic map(datawidth=>datawidth, addresswidth=>addresswidth)
        port map(ck=>ck, reset=>reset, zi=>s_zi, ci=>s_ci, cpA=>s_cpA, cpB=>s_cpB, 
            zsoma=>s_zsoma, csoma=>s_csoma, csad_reg=>s_csad_reg, pA=>pA, 
            pB=>pB, ender=>ender, menor=>s_menor, sad=>sad);
            
    
end architecture;