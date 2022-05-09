-- This is a testbench for the typeIQ package
-- Basic checks, a little different to standard _tb's.
-- Basically a playground until I can work out how to make arbitrary precision
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.typeIQ.all;

entity typeIQ_tb is
end typeIQ_tb;

architecture arch of typeIQ_tb is


	--Initial definitions
	constant c_width : integer:= 16;
	constant c_halfT : time:= 10ns;

	signal s_clk : std_logic;

	signal s_a : t_iq (c_width-1 downto 0);
	signal s_b : t_iq (c_width-1 downto 0);
	signal s_x : t_iq (c_width-1 downto 0);
	signal s_y : t_iq (c_width*2-1 downto 0);
	signal s_z : t_iq (c_width-1 downto 0);

	type t_stimulus is record
		s_A : t_iq (c_width-1 downto 0);
		s_B : t_iq (c_width-1 downto 0);
	end record;

	type t_stimuli is array (natural range <>) of t_stimulus;
	constant c_stimuli : t_stimuli := (
	(x"0101", x"0000"),
	(x"0101", x"0001"),
	(x"FF00", x"0200"),
	(x"0001", x"0002")
	);

	
begin

	SOLE: process
	begin
		for S in c_stimuli'range loop
			s_a <= c_stimuli(S).s_A;
			s_b <= c_stimuli(S).s_B;
			s_clk <= '0';
			wait for c_halfT;
			s_clk <= '1';
			wait for c_halfT;
		end loop;
		wait;
	end process SOLE;
	
	s_x <= s_a + s_b;
	s_y <= s_a * s_b;
	s_z <= j(s_a);

end arch;
