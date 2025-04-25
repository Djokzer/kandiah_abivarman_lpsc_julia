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

		-- JULIA ESCAPE ALGORITHM ARGS
		ITERATIONS		: integer := 100;
		THRESHOLD		: integer := 2;

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
	-- CONSTANTS
	constant FIXED_THRESHOLD : integer := (THRESHOLD**2) * 2**FIXED_BITS;

	-- X,Y COORDINATES COUNTER
	signal x_coord			: std_logic_vector(15 downto 0);
	signal y_coord			: std_logic_vector(15 downto 0);
	signal x_count, y_count : integer := 0;
	signal count_enable		: std_logic := '0';

	-- COMPLEX POINT COORDINATE
	signal z_re				: std_logic_vector(31 downto 0);
	signal z_im				: std_logic_vector(31 downto 0);
	
	-- JULIA COMPUTING SIGNALS
	signal julia_count	 	: integer := 0;
	signal julia_enable		: std_logic := '0';
	signal julia_init		: std_logic := '0';

	signal z_re_n, z_im_n	: integer := 0; -- JULIA ITER INPUT
	signal z_re_n1, z_im_n1	: integer := 0; -- JULIA ITER OUTPUT
	signal z_norm 			: integer := 0; -- COMPLEX NORM, TO CHECK STOP CONDITION
	
	-- FSM STATES
	type FSM_STATE_TYPE is (JULIA_INI, JULIA_COMP, JULIA_OUTPUT, COUNT_COORD);
	signal curr_fsm_state, next_fsm_state : FSM_STATE_TYPE := JULIA_COMP;
	signal data_valid : std_logic := '0';

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
	fsm_ctrl : process(curr_fsm_state, julia_count, z_norm)
	begin
		-- DEFAULTS
		next_fsm_state 	<= curr_fsm_state;
		count_enable 	<= '0';
		julia_enable 	<= '0';
		julia_init		<= '0';
		data_valid		<= '0';

		case curr_fsm_state is
			when JULIA_INI =>
				julia_init <= '1';
				next_fsm_state <= JULIA_COMP;

			when JULIA_COMP =>
				julia_enable <= '1';
				if julia_count < ITERATIONS then
					if z_norm > FIXED_THRESHOLD then
						-- Z ESCAPED
						next_fsm_state <= JULIA_OUTPUT;
					end if;
				else
					-- Z IS IN JULIA SET
					next_fsm_state <= JULIA_OUTPUT;
				end if;

			when JULIA_OUTPUT =>
				-- DATA OUT VALID
				data_valid <= '1';
				next_fsm_state <= COUNT_COORD;
			when COUNT_COORD =>
				-- ENABLE X,Y COUNTER
				count_enable <= '1';
				next_fsm_state <= JULIA_INI;
		end case;
	end process;

	fsm_update : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				curr_fsm_state <= JULIA_INI;
			else
				curr_fsm_state <= next_fsm_state;
			end if;
		end if;
	end process;
	-- ============================================================ --

	-- =============== JULIA ITERATIONS COMPUTATION =============== --
	julia_counter : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				z_re_n <= 0;
				z_im_n <= 0;
				julia_count <= 0;
			else
				if julia_enable = '1' then
					-- UPDATE Z and COUNTER
					z_re_n <= z_re_n1;
					z_im_n <= z_im_n1;
					julia_count <= julia_count + 1;
				end if;

				if julia_init = '1' then
					-- INIT Z and COUNTER
					z_re_n <= to_integer(signed(z_re));
					z_im_n <= to_integer(signed(z_im));
					julia_count <= 0;
				end if;
			end if;
		end if;
	end process;

	julia_iter : process(z_re_n, z_im_n)
		variable z_re_sq, z_im_sq, xy : integer;
	begin
		z_re_sq := to_integer(shift_right(to_signed(z_re_n * z_re_n, 32), FIXED_BITS));		-- z_re^2
		z_im_sq := to_integer(shift_right(to_signed(z_im_n * z_im_n, 32), FIXED_BITS));		-- z_im^2
		xy 		:= to_integer(shift_right(to_signed(z_re_n * z_im_n, 32), FIXED_BITS - 1)); -- 2 * z_re * z_im

		z_re_n1 <= z_re_sq - z_im_sq + c_re;	-- z_re_n+1 = z_re^2 - z_im^2 + C_RE 
		z_im_n1 <= xy + c_im;					-- z_im_n+1 = 2 * z_re * z_im + C_IM
		z_norm	<= z_re_sq + z_im_sq;			-- z_re^2 + z_im^2
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

	-- ========================== OUTPUT ========================== --
	escape_counter <= std_logic_vector(to_unsigned(julia_count, escape_counter'length));
	address <= std_logic_vector(to_unsigned(x_count + y_count * X_SIZE, address'length));
	valid <= data_valid;
	-- ============================================================ --
end architecture;