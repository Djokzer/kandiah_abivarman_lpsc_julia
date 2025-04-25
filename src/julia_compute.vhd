library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity julia_compute is
	generic(
		-- SCREEN SIZE
		X_SIZE			: integer := 10;
		Y_SIZE 			: integer := 10;

		-- COMPLEX PLANE
		RE_MIN			: integer := -2;
		RE_MAX			: integer := 2;
		IM_MIN			: integer := -2;
		IM_MAX			: integer := 2;

		-- FIXED POINT  
		FIXED_BITS		: integer := 20;

		-- COMPLEX CONST
		c_re			: integer := 298844;    -- Real = 0.285, with Fixed bits = 0.285 * 2**20
		c_im			: integer := 10485      -- Imaginary = 0.01j, with Fixed bits = 0.01 * 2**20
	);
	port (
		-- GENERAL
		clk				: in std_logic;
		rst				: in std_logic;

		-- JULIA OUTPUT
		escape_counter 	: out std_logic_vector(7 downto 0); -- When counter = 100, Z is in julia set
		address			: out std_logic_vector(31 downto 0);
		valid			: out std_logic
	);
end entity julia_compute;

architecture rtl of julia_compute is
	-- X,Y COORDINATES COUNTER
	signal x_coord			: std_logic_vector(15 downto 0);
	signal y_coord			: std_logic_vector(15 downto 0);
	signal x_count, y_count : integer := 0;
	signal count_enable		: std_logic := '0';

	-- COMPLEX POINT COORDINATE
	signal z_re				: std_logic_vector(31 downto 0);
	signal z_im				: std_logic_vector(31 downto 0);
	
	-- JULIA COMPUTING SIGNALS
	signal z_re_n, z_im_n	: integer := 0; -- JULIA ITER INPUT
	
	-- FSM STATES
	type FSM_STATE_TYPE is (JULIA_COMP, JULIA_OUTPUT, COUNT_COORD);
	signal curr_fsm_state, next_fsm_state : FSM_STATE_TYPE := JULIA_COMP;

begin
	-- ==============  COMPLEX COORDINATE GENERATOR =============== --
	coord_to_complex : entity work.coord_to_complex
	generic map (
		X_SIZE => X_SIZE,
		Y_SIZE => Y_SIZE,
		RE_MIN => RE_MIN,
		RE_MAX => RE_MAX,
		IM_MIN => IM_MIN,
		IM_MAX => IM_MAX,
		FIXED_BITS => FIXED_BITS
	)
	port map (
		x_coord => x_coord,
		y_coord => y_coord,
		z_re => z_re,
		z_im => z_im
	);
	-- ============================================================ --

	-- ============================ FSM =========================== --
	fsm_ctrl : process(curr_fsm_state)
	begin
		-- DEFAULTS
		next_fsm_state <= curr_fsm_state;

		case curr_fsm_state is
			when JULIA_COMP =>

			when JULIA_OUTPUT =>

			when COUNT_COORD =>
		end case;
	
	end process;

	fsm_update : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				curr_fsm_state <= JULIA_COMP;
			else
				curr_fsm_state <= next_fsm_state;
			end if;
		end if;
	end process;
	-- ============================================================ --

	-- =============== JULIA ITERATIONS COMPUTATION =============== --
	julia_iter : process(z_re_n, z_im_n)
	begin
		
	end process;
	-- ============================================================ --

	-- ================ SCREEN COORDINATES COUNTERS =============== -- 
	-- COUNT X COORDINATE FROM 0 TO X_SIZE-1
	x_counter : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				x_count <= 0;
			else
				if count_enable = '1' then
					if x_count = (X_SIZE-1) then
						x_count <= 0;
					else
						x_count <= x_count + 1;
					end if;
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
				y_count <= 0;
			else
				if count_enable = '1' then
					if y_count = (Y_SIZE-1) then
						y_count <= 0;
					elsif x_count = (X_SIZE-1) then
						y_count <= y_count + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- MAP X,Y COUNTER TO COORDINATE INPUT FOR COMPLEX CONVERSION
	x_coord <= std_logic_vector(to_signed(x_count, x_coord'length));
	y_coord <= std_logic_vector(to_signed(y_count, y_coord'length));

	-- ============================================================ --



end architecture;