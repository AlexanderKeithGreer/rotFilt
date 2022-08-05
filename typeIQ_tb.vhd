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
	constant c_width : integer:= 8;
	constant c_halfT : time:= 10ns;

	signal s_clk : std_logic;

	signal s_a : t_iq (c_width-1 downto 0);
	signal s_b : t_iq (c_width-1 downto 0);
	signal s_i : integer range 7 downto -8;
	signal s_q : integer range 7 downto -8;

	
	signal s_add : t_iq (c_width-1 downto 0);
	signal s_sub : t_iq (c_width-1 downto 0);
	signal s_mult : t_iq (c_width*2-1 downto 0);
	signal s_slice : t_iq (c_width/2-1 downto 0);
	signal s_conv : t_iq (c_width-1 downto 0);
	signal s_real : integer;
	signal s_imag : integer;
	signal s_cnjI : integer;
	signal s_cnjQ : integer;
	signal s_j 	  : t_iq (c_width-1 downto 0);
	signal s_lshf : t_iq (c_width-1 downto 0);
	signal s_rshf : t_iq (c_width-1 downto 0);
	signal s_eq	  : boolean;
	signal s_neq  : boolean;
	signal s_sgn  : t_iq (4-1 downto 0);

	type t_stimulus is record
		s_A : t_iq (c_width-1 downto 0);
		s_B : t_iq (c_width-1 downto 0);
		s_i : integer range 7 downto -8;
		s_q : integer range 7 downto -8;
	end record;

	type t_stimuli is array (natural range <>) of t_stimulus;
	constant c_stimuli : t_stimuli := (
	(x"64", x"00",  1, -2),
	(x"25", x"01", -1,  0),
	(x"F0", x"20",  2,  2),
	(x"04", x"02", -2,  3)
	);


begin

	SOLE: process
	begin
		for S in c_stimuli'range loop
			s_a <= c_stimuli(S).s_A;
			s_b <= c_stimuli(S).s_B;
			s_i <= c_stimuli(S).s_i;
			s_q <= c_stimuli(S).s_q;
			s_clk <= '0';
			wait for c_halfT;
			s_clk <= '1';
			wait for c_halfT;
		end loop;
		wait;
	end process SOLE;

	s_add <= s_a + s_b;
	s_mult <= s_a * s_b;
	s_slice <= slice(s_b, 1, 0);
	s_sub <= -s_b;
	s_conv <= to_iq(s_i, s_q, c_width);
	s_j <= j(s_conv);
	s_sgn <= sgn(s_conv);
	s_real <= to_integer(realSN(s_conv));
	s_imag <= to_integer(imagSN(s_conv));
	s_lshf <= s_a < 1;
	s_rshf <= s_a > 1;
	
	s_cnjI <= to_integer(realSN(s_j));
	s_cnjQ <= to_integer(imagSN(s_j));
	s_eq <= (s_a = s_b);
	s_neq <= (s_a /= s_b);
	
	
end arch;
