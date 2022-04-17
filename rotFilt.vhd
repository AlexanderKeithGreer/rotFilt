-- ------------------------------------------------
-- This is a one tap FIR that takes complex data, 
--		and uses complex coefficients.
-- ------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.typeIQ.all;


entity rotFilt is
	port( i_mixed 	: in t_iq16;
			i_interf	: in t_iq16;
			i_clk		: in std_logic;
			i_rst		: in std_logic;
			i_strobe	: in std_logic;
			o_err		: out t_iq16;
			o_debug	: out t_iq16);
end rotFilt;


architecture arch of rotFilt is
	--Constants
	constant c_mu : integer:=8;	
	constant c_shift : integer:= 8; --Should never change!
	--Signals
	signal s_err : t_iq16; 
	signal s_tap : t_iq16; 
	signal s_interf : t_iq16;
	signal s_mixed : t_iq16;
	--Intermediate signals (pipelining / function connection)
	signal s_conv : t_iq16;
	signal s_schur : t_iq16;
	signal s_schurDiv : t_iq16;
	
begin

	--LMS equations are:
	-- o = m - t*i 	--Convolution in vector case (use SR)
	--	t = t + mu*o*i --Schur Product in vector case
	s_interf <= i_interf;
	s_mixed <= i_mixed;
	o_err <= s_err;
	o_debug <= s_tap;
	
	SOLE: process (i_clk, i_rst)
	begin
		if (i_rst = '1') then
			s_tap <= (others => (others =>'0'));
			s_conv <= (others => (others =>'0'));
			s_schur <= (others => (others =>'0'));
			s_schurDiv <= (others => (others =>'0'));
			s_err <= (others => (others =>'0'));
		elsif (rising_edge(i_clk)) then
			--This is getting pipelined out of sheer necessity.
			s_conv <= multIQ16(s_interf, s_tap, c_shift);
			s_err <=  subIQ16(s_mixed, s_conv);
			s_schur <= multIQ16(s_interf, s_err, c_shift);
			s_schurDiv <= divIQ16(s_schur, c_mu);
			s_tap <= addIQ16(s_err, s_schurDiv);
		end if;
	end process SOLE;
end arch;
