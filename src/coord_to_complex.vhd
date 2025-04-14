library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity coord_to_complex is
	generic (
		-- SCREEN SIZE
		X_SIZE		: integer := 10;
		Y_SIZE 		: integer := 10;

		-- COMPLEX PLANE
		RE_MIN		: integer := -2;
		RE_MAX		: integer := 2;
		IM_MIN		: integer := -2;
		IM_MAX		: integer := 2;

		-- FIXED POINT
		FIXED_BITS	: integer := 20
	);
	port (
		-- X,Y COORDINATES
		x_coord		: in std_logic_vector(15 downto 0);
		y_coord		: in std_logic_vector(15 downto 0);

		-- COMPLEX COORDINATE
		z_re    	: out std_logic_vector(31 downto 0);
		z_im    	: out std_logic_vector(31 downto 0)
	);
end entity coord_to_complex;

architecture rtl of coord_to_complex is

	-- COMPLEX STEP CONSTANTS
	constant RE_RANGE	: integer := RE_MAX - RE_MIN;
	constant IM_RANGE	: integer := IM_MAX - IM_MIN;

	constant STEP_HORI : integer := integer((RE_RANGE * 2**FIXED_BITS) / (X_SIZE-1));
	constant STEP_VERT : integer := integer((IM_RANGE * 2**FIXED_BITS) / (Y_SIZE-1));

	constant FIXED_RE_MIN : integer := (RE_MIN * 2**FIXED_BITS);
	constant FIXED_IM_MIN : integer := (IM_MIN * 2**FIXED_BITS);
begin

	-- CONVERT X,Y COORDINATES TO COMPLEX PLANE
	compute_complex : process(x_coord, y_coord)
		variable x, y		: integer;
		variable real_val 	: integer;
		variable imag_val 	: integer;
	begin
		x := to_integer(unsigned(x_coord));
		y := to_integer(unsigned(y_coord));

		real_val := FIXED_RE_MIN + (x * STEP_HORI);
		imag_val := FIXED_IM_MIN + (y * STEP_VERT);

		z_re <= std_logic_vector(to_signed(real_val, z_re'length));
		z_im <= std_logic_vector(to_signed(imag_val, z_im'length));
	end process;

end architecture;