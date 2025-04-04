library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity gen_complex_coord is
	generic (
		-- SCREEN SIZE
		X_SIZE	: integer := 10;
		Y_SIZE 	: integer := 10;

		-- COMPLEX PLANE
		X_RE_MIN: integer := -2;
		X_IM_MIN: integer := 2;
		Y_RE_MIN: integer := -2;
		Y_IM_MIN: integer := 2
	);
	port (
		-- GENERAL
		clk		: in std_logic;
		rst		: in std_logic;

		-- COMPLEX
		x_re    : in std_logic_vector(31 downto 0);
		x_im    : in std_logic_vector(31 downto 0);
		y_re    : in std_logic_vector(31 downto 0);
		y_im    : in std_logic_vector(31 downto 0)
	);
end entity gen_complex_coord;

architecture rtl of gen_complex_coord is

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

end architecture;