library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
	generic(width: positive );
	port(
		op: in std_logic_vector(2 downto 0);  --000:AND , 001:OR , 010:ADD, 110:SUB, 111:SLT
		a, b: in std_logic_vector(width-1 downto 0);
		zero: out std_logic;
		res: out std_logic_vector(width-1 downto 0)
	);
end entity;

architecture Behavioral of ULA is
    signal s_res, slt: std_logic_vector(res'range);
begin
    slt <= (0=>'1', others=>'0') when signed(a) < signed(b) else (others=>'0');
    s_res <= a and b when (op = "000") else
        a or b when (op="001") else
        std_logic_vector(signed(a) + signed(b)) when (op="010") else
        std_logic_vector(signed(a) - signed(b)) when (op="110") else
        slt;
	zero <= '1' when to_integer(unsigned(s_res)) = 0 else '0';
	res <= s_res;
end architecture;