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
	--Record based type, with 16 bits, 8 per axis.
	type t_iq8 is record
		i : signed (7 downto 0);
		q : signed (7 downto 0);
	end record t_iq8;

	function addIQ8(
		 A : in t_iq8;
		 B : in t_iq8)
		return t_iq8;
	--Record based type, with 32 bits, 16 per axis.
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
		
	-- ----------------------------
	-- t_iq16 related definitions
	-- ----------------------------
	-- This is a subtype of std_logic_vector intended to 
	--  represent complex numbers
	-- ----------------------------
	subtype t_iq is std_logic_vector;
	

	
	function "+"  (L, R : t_iq) return t_iq;
	--function "-"  (L, R : t_iq) return t_iq;
	function "*"  (L, R : t_iq) return t_iq;
	--function "="  (L, R : t_iq) return BOOLEAN;
	--function "/=" (L, R : t_iq) return BOOLEAN;
	--function "||" (   R : t_iq) return unsigned; --This one's hard
	function j (   ARG : t_iq) return t_iq;
	--function to_iq (ARG : signed) return t_iq;
	--function f_real (ARG : t_iq) return signed;
	--function f_imag (ARG : t_iq) return signed;
	--function slice (ARG : t_iq ;start, stop : integer) return t_iq;
	
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
	end subIQ16;

	
	function multIQ16 (
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
	
	
	function "+" (
		L,R : t_iq) 
	return t_iq is
		variable I : integer:=L'length;
		variable Q : integer:=L'length/2;
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q) := std_logic_vector(
								 signed(L(I-1 downto Q)) + signed(R(I-1 downto Q)) );
		O(Q-1 downto 0) := std_logic_vector(
								 signed(L(Q-1 downto 0)) + signed(R(Q-1 downto 0)) );
		return O;
	end;
	
	function "*" (
		L,R : t_iq) 
	return t_iq is
		variable I : integer:=L'length;
		variable Q : integer:=L'length/2;
		variable O : t_iq (2*I-1 downto 0);
	begin
		O(I*2-1 downto Q*2) := std_logic_vector(
									  signed(L(I-1 downto Q)) * signed(R(I-1 downto Q)) 
									  - signed(L(Q-1 downto 0)) * signed(R(Q-1 downto 0)) );
		O(Q*2-1 downto 0)   := std_logic_vector(
								     signed(L(I-1 downto Q)) * signed(R(Q-1 downto 0))
									  + signed(L(Q-1 downto 0)) * signed(R(I-1 downto Q)) );
		return O;
	end;
	
	function j (
		ARG : t_iq) 
	return t_iq is
		variable I : integer:=ARG'length;		
		variable Q : integer:=ARG'length/2;	
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q) := std_logic_vector( -signed(ARG(I-1 downto Q)) );
		O(Q-1 downto 0) := ARG(Q-1 downto 0);
		return O;
	end j;
	
end typeIQ;
