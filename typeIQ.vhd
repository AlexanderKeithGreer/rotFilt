-- ----------------------------
-- typeIQ: Contains specific IQ
--		type implementations
--	Functionally a wrapper around
--		specific methods
-- ----------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package typeIQ is
	type t_iq8 is record
		i : signed (7 downto 0);
		q : signed (7 downto 0);
	end record t_iq8;

	function addIQ8(
		 A : in t_iq8;
		 B : in t_iq8)
		return t_iq8;

	type t_iq16 is record
		i : signed (15 downto 0);
		q : signed (15 downto 0);
	end record t_iq16;

	function addIQ16(
		 A : in t_iq16;
		 B : in t_iq16)
		return t_iq16;

	function subIQ16 (
		 A : t_iq16 ;
		 B : t_iq16) 
		return t_iq16;
	
	function multIQ16(
		 A : in t_iq16;
		 B : in t_iq16;
		 s : in integer)
		return t_iq16;
	
	function divIQ16(
		 A : in t_iq16;
		 s : in integer)
		return t_iq16;

end package;


-- ----------------------------------------------
package body  typeIQ is

	function addIQ8(
		 A : in t_iq8;
		 B : in t_iq8)
	return t_iq8 is
		variable C : t_iq8;
	begin
		C.i := A.i + B.i;
		C.q := A.q + B.q;
		return C;
	end addIQ8;

	-- ------------------------
	-- t_iq16 related functions
	-- ------------------------
	function addIQ16 (
		 A : in t_iq16;
		 B : in t_iq16)
	return t_iq16 is
		variable C : t_iq16;
	begin
		C.i := A.i + B.i;
		C.q := A.q + B.q;
		return C;
	end addIQ16;
	

	function subIQ16 (
		A : t_iq16;
		B : t_iq16) 
	return t_iq16 is
		variable C : t_iq16;
	begin
		C.i := A.i - B.i;
		C.q := A.q - B.q;
		return C;
	end;

	
	function multIQ16(
		 A : in t_iq16;
		 B : in t_iq16;
		 s : in integer)
	return t_iq16 is
		variable C : t_iq16;
		variable v_i : signed (31 downto 0);
		variable v_q : signed (31 downto 0);
	begin
		v_i := A.i*B.i - A.q*B.q;
		v_q := A.i*B.q + A.q*B.i;
		C.i := v_i(s+15 downto s);
		C.q := v_q(s+15 downto s);
		return C;
	end multIQ16;
	
	function divIQ16(
		 A : in t_iq16;
		 s : in integer)
	return t_iq16 is
		variable C : t_iq16;
	begin
		C.i := shift_left(A.i, s);
		C.q := shift_left(A.q, s);
		return C;
	end divIQ16;

end typeIQ;
