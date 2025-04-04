library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity gen_complex_coord is
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
		-- GENERAL
		clk			: in std_logic;
		rst			: in std_logic;

		-- COMPLEX
		c_re    	: out std_logic_vector(31 downto 0);
		c_im    	: out std_logic_vector(31 downto 0)
	);
end entity gen_complex_coord;

architecture rtl of gen_complex_coord is

	-- COMPLEX STEP CONSTANTS
	constant RE_RANGE	: integer := RE_MAX - RE_MIN;
	constant IM_RANGE	: integer := IM_MAX - IM_MIN;

	constant STEP_HORI : integer := integer(RE_RANGE * 2**FIXED_BITS / X_SIZE-1);
	constant STEP_VERT : integer := integer(IM_RANGE * 2**FIXED_BITS / Y_SIZE-1);
	
	-- COORDINATES COUNTER
	signal x_coord : integer := 0;
	signal y_coord : integer := 0;

begin
	-- COUNT X COORDINATE FROM 0 TO X_SIZE-1
	x_counter : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				x_coord <= 0;
			else
				if x_coord = (X_SIZE-1) then
					x_coord <= 0;
				else
					x_coord <= x_coord + 1;
				end if;
			end if;
		end if;
	end process;

	-- COUNT Y COORDINATE FROM 0 TO Y_SIZE-1
	-- WHEN X FINISHED A LOOP
	y_counter : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				y_coord <= 0;
			else
				if y_coord = (Y_SIZE-1) then
					y_coord <= 0;
				elsif x_coord = (X_SIZE-1) then
					y_coord <= y_coord + 1;
				end if;
			end if;
		end if;
	end process;

	-- CONVERT X,Y COORDINATES TO COMPLEX PLANE
	compute_complex : process(x_coord, y_coord)
		variable real_val : integer;
		variable imag_val : integer;
	begin
		real_val := X_SIZE + x_coord * STEP_HORI;
		imag_val := Y_SIZE + y_coord * STEP_VERT;

		c_re <= std_logic_vector(to_signed(real_val, c_re'length));
		c_im <= std_logic_vector(to_signed(imag_val, c_im'length));
	end process;

end architecture;