-- Test Bench for rotFilt
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.typeIQ.all;


entity rotFilt_tb is
end rotFilt_tb;

architecture tb of rotFilt_tb is

	component rotFilt is
		generic (g_width : integer);
		port( i_mixed 	: in t_iq (g_width-1 downto 0);
				i_interf	: in t_iq (g_width-1 downto 0);
				i_clk		: in std_logic;
				i_rst		: in std_logic;
				i_strobe	: in std_logic;
				o_err		: out t_iq (g_width-1 downto 0);
				o_debug	: out t_iq (g_width-1 downto 0));
	end component;

	constant c_width  : integer:=64;
	constant c_period : time:=10ns;

	file f_data : text;

	signal s_mixed : t_iq (c_width-1 downto 0);
	signal s_interf: t_iq (c_width-1 downto 0);
	signal s_clk	: std_logic := '0';
	signal s_rst	: std_logic := '1'; --Don't use for now
	signal s_strobe: std_logic := '1'; --Leave alone too please
	signal s_out	: t_iq (c_width-1 downto 0);
	signal s_debug : t_iq (c_width-1 downto 0);

	--signal s_out	: t_iq(c_width*2-1 downto 0);
	signal s_outR	: integer;
	signal s_outI	: integer;
	
begin

	LOAD: process
		variable v_dataLine : line;
		variable v_comma : character;
		variable v_intI : integer;
		variable v_intQ	: integer;
		variable v_iqInt : t_iq(c_width-1 downto 0);
		variable v_iqMix : t_iq(c_width-1 downto 0);
	begin

		file_open(f_data, "C:\Users\Alexander Greer\Documents\mono\input_rotFilt.csv", read_mode);

		while not endfile(f_data) loop
			readline(f_data,v_dataLine);

			if (v_dataLine'length /= 0) then
				read(v_dataLine, v_intI);
				read(v_dataLine, v_comma);
				read(v_dataLine, v_intQ);
				s_interf <= to_iq(v_intI, v_intQ, c_width);
				
				read(v_dataLine, v_comma);
				read(v_dataLine, v_intI);
				read(v_dataLine, v_comma);
				read(v_dataLine, v_intQ);
				s_mixed <= to_iq(v_intI, v_intQ, c_width);
				
				wait for c_period;
				s_clk <= '1';
				wait for c_period;
				s_clk <= '0';
				s_rst <= '0';

			end if;
		end loop;
		wait;

	end process LOAD;

	UUT: rotFilt generic map (g_width=>c_width) 
					 port map (i_mixed=>s_mixed, i_interf=>s_interf, o_err=>s_out,
												i_clk=>s_clk, i_rst=>s_rst, i_strobe=>'0',
												o_debug=>s_debug);
	
	s_outR <= to_integer(realSN(s_debug));
	s_outI <= to_integer(imagSN(s_debug));

end tb;
