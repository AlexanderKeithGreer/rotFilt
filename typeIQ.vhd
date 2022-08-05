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

	-- ----------------------------
	-- t_iq16 related definitions
	-- ----------------------------
	-- This is a subtype of std_logic_vector intended to
	--  represent complex numbers
	-- ----------------------------
	subtype t_iq is std_logic_vector;

	function "+"  (L, R : t_iq) return t_iq;
	function "-"  (L, R : t_iq) return t_iq;
	function "-" (ARG : t_iq) return t_iq;
	function "*"  (L, R : t_iq) return t_iq;
	function "<" (ARG : t_iq; S : integer) return t_iq; --Shift, not bool
	function ">" (ARG : t_iq; S : integer) return t_iq; --Shift, not bool
	function "="  (L, R : t_iq) return BOOLEAN;
	function "/=" (L, R : t_iq) return BOOLEAN;
	--function "||" (   R : t_iq) return unsigned; --This one's hard
	function j (   ARG : t_iq) return t_iq;
	function conj (ARG : t_iq) return t_iq;
	function to_iq (inI, inQ, L : integer) return t_iq;
	function realSN (ARG : t_iq) return signed;
	function imagSN (ARG : t_iq) return signed;
	function realIQ (ARG : t_iq) return t_iq;
	function imagIQ (ARG : t_iq) return t_iq;
	function negSection (ARG : t_iq) return t_iq;
	function slice (ARG : t_iq ; A, B : integer) return t_iq;
	function sgn (ARG : t_iq) return t_iq;

end package;


-- ----------------------------------------------
package body  typeIQ is

-- ----------------------------------------------
-- Base Arithmetic
-- ----------------------------------------------

	function "+" (
		L,R : t_iq)
	return t_iq is
		constant I : integer:=L'length;
		constant Q : integer:=L'length/2;
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q) := std_logic_vector(
								 signed(L(I-1 downto Q)) + signed(R(I-1 downto Q)) );
		O(Q-1 downto 0) := std_logic_vector(
								 signed(L(Q-1 downto 0)) + signed(R(Q-1 downto 0)) );
		return O;
	end;
	
	
	function "-" (
		L,R : t_iq)
	return t_iq is
		constant I : integer:=L'length;
		constant Q : integer:=L'length/2;
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q) := std_logic_vector(
								 signed(L(I-1 downto Q)) - signed(R(I-1 downto Q)) );
		O(Q-1 downto 0) := std_logic_vector(
								 signed(L(Q-1 downto 0)) - signed(R(Q-1 downto 0)) );
		return O;
	end;
	
	
	function "-" (
		ARG : t_iq)
	return t_iq is
		constant I : integer:=ARG'length;
		--constant Q : integer:=L'length/2;
		constant zero : t_iq (I-1 downto 0) :=(others=>'0');
		variable O : t_iq (I-1 downto 0);
	begin
		O := zero - ARG;
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

-- ----------------------------------------------
-- Shifts
-- ----------------------------------------------
	function "<" (
		ARG : t_iq;
		S	 : integer)
	return t_iq is
		variable I : integer:=ARG'length;
		variable Q : integer:=ARG'length/2;
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q):= std_logic_vector(
								shift_left(signed(ARG(I-1 downto Q)),S));
		O(Q-1 downto 0):= std_logic_vector(
								shift_left(signed(ARG(Q-1 downto 0)),S));
		return O;
	end;
	
	function ">" (
		ARG : t_iq;
		S	 : integer)
	return t_iq is
		variable I : integer:=ARG'length;
		variable Q : integer:=ARG'length/2;
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q):= std_logic_vector(
								shift_right(signed(ARG(I-1 downto Q)),S));
		O(Q-1 downto 0):= std_logic_vector(
								shift_right(signed(ARG(Q-1 downto 0)),S));
		return O;
	end;

-- ----------------------------------------------
-- Equality
-- ----------------------------------------------

	function "="  (L, R : t_iq) 
	return BOOLEAN is
		variable I : integer:=L'length;
		variable Q : integer:=L'length/2;
		variable O : BOOLEAN;
	begin
		O := signed(L(I-1 downto Q)) = signed(R(I-1 downto Q));
		O := O and signed(L(Q-1 downto 0)) = signed(R(Q-1 downto 0));
		return O;
	end;
	
	function "/="  (L, R : t_iq) 
	return BOOLEAN is
		variable I : integer:=L'length;
		variable Q : integer:=L'length/2;
		variable O : BOOLEAN;
	begin
		O := signed(L(I-1 downto Q)) /= signed(R(I-1 downto Q));
		O := O or signed(L(Q-1 downto 0)) /= signed(R(Q-1 downto 0));
		return O;
	end;

-- ----------------------------------------------
-- Conversions
-- ----------------------------------------------
	
	function to_iq (
		inI, inQ, L : integer) 
	return t_iq is
		variable I : integer:=L;  --Lets keep to 
		variable Q : integer:=L/2;-- existing notation
		variable O : t_iq (I-1 downto 0);
	begin
		O(I-1 downto Q) := std_logic_vector(to_signed(inI, I-Q));
		O(Q-1 downto 0) := std_logic_vector(to_signed(inQ, Q));
		return O;
	end;
	
	
	function realSN (
		ARG : t_iq)
	return signed is
		constant I : integer:=ARG'length;
		constant Q : integer:=ARG'length/2;
		variable O : signed (I/2-1 downto 0);
	begin
		O := signed(ARG(I-1 downto Q));
		return O;
	end;
	
	
	function imagSN (
		ARG : t_iq) 
	return signed is
		constant I : integer:=ARG'length;
		constant Q : integer:=ARG'length/2;
		variable O : signed (I/2-1 downto 0);
	begin
		O := signed(ARG(Q-1 downto 0));
		return O;
	end;
	
	function realIQ (
		ARG : t_iq) 
	return t_iq is
		constant I : integer:=ARG'length;
		constant Q : integer:=ARG'length/2;
		variable O : t_iq(I-1 downto 0);
	begin
		O(Q-1 downto 0) := (others=>'0');
		O(I-1 downto Q) := ARG(I-1 downto Q);
		return O;
	end;
	
	function imagIQ (
		ARG : t_iq) 
	return t_iq is
		constant I : integer:=ARG'length;
		constant Q : integer:=ARG'length/2;
		variable O : t_iq(I-1 downto 0);
	begin
		O(Q-1 downto 0) := (others=>'0');
		O(I-1 downto Q) := ARG(Q-1 downto 0);
		return O;
	end;
	
	function j (
		ARG : t_iq)
	return t_iq is
		variable I : integer:=ARG'length;
		variable Q : integer:=ARG'length/2;
		variable O : t_iq (I-1 downto 0);		
	begin
		O(Q-1 downto 0) := ARG(I-1 downto Q); --Let Q-1 downto 0 be overwritten
		O(I-1 downto Q) := negSection(ARG(Q-1 downto 0));
		
		return O;
	end j;

	function conj (
		ARG : t_iq)
	return t_iq is
		variable I : integer:=ARG'length;
		variable Q : integer:=ARG'length/2;
		variable O : t_iq (I-1 downto 0);		
	begin
		O(I-1 downto Q) := ARG(I-1 downto Q);
		O(Q-1 downto 0) := negSection(ARG(Q-1 downto 0));
		return O;
	end conj;

	
	function sgn (
		ARG : t_iq)
	return t_iq is
		variable I : integer:=ARG'length;
		variable Q : integer:=ARG'length/2;
		variable O : t_iq (3 downto 0) := (others=>'0');
	begin
		if (signed(ARG(I-1 downto Q)) > to_signed(0, I-Q)) then
			O(4-1 downto 2) := b"01";
		elsif (signed(ARG(I-1 downto Q)) < to_signed(0, I-Q)) then
			O(4-1 downto 2) := b"11";
		end if;
		
		if (signed(ARG(Q-1 downto 0)) > to_signed(0, I-Q)) then
			O(2-1 downto 0) := b"01";
		elsif (signed(ARG(Q-1 downto 0)) < to_signed(0, Q-0)) then
			O(2-1 downto 0) := b"11";
		end if;
		
		return O;
	end sgn;
	
-- ----------------------------------------------
-- Helpers
-- ----------------------------------------------

	function slice (
		ARG : t_iq ;
		A, B : integer)
	return t_iq is
		variable I : integer:=ARG'length;
		variable Q : integer:=ARG'length/2;
		variable INew : integer:=2*(A-B+1);
		variable QNew : integer:=A-B+1;
		variable O : t_iq (INew-1 downto 0);
	begin
		O(INew-1 downto QNew) := ARG(A+Q downto B+Q);
		O(QNew-1 downto 0)    := ARG(A downto B);
		return O;
	end;
	
	function negSection (
		ARG : t_iq)
	return t_iq is
		constant I : integer:=ARG'length;
		constant Q : integer:=ARG'length/2;
		variable O : t_iq(I-1 downto 0);
	begin
		O := std_logic_vector(-signed(ARG));
		return O;
	end;

end typeIQ;

