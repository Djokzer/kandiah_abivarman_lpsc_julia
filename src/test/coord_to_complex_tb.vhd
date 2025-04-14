library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use std.env.finish;

entity coord_to_complex_tb is
end;

architecture testbench of coord_to_complex_tb is
	-- CONSTANTS
	-- Clock period
	constant clk_period : time := 5 ns;
	-- Generics
	constant X_SIZE : integer := 1000;
	constant Y_SIZE : integer := 1000;
	constant RE_MIN : integer := -2;
	constant RE_MAX : integer := 2;
	constant IM_MIN : integer := -2;
	constant IM_MAX : integer := 2;
	constant FIXED_BITS : integer := 20;

	-- SIGNALS
	-- UUT Ports
	signal clk : std_logic := '0';
	signal rst : std_logic;
	signal z_re : std_logic_vector(31 downto 0);
	signal z_im : std_logic_vector(31 downto 0);
	signal x_coord : std_logic_vector(15 downto 0);
	signal y_coord : std_logic_vector(15 downto 0);
	
	-- X,Y COORDINATES COUNTER
	signal x,y : integer := 0;

	-- File for output
	file output_file : text open write_mode is "/home/abi/Documents/other/master/fpga_julia/output/complex_output.csv";
begin
	-- CLOCK AND RESET CONTROL
	clk <= not clk after clk_period/2;
	rst <= '1', '0'  after CLK_PERIOD * 10;
	
	-- UNIT UNDER TEST
	uut : entity work.coord_to_complex
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

	-- COUNT X COORDINATE FROM 0 TO X_SIZE-1
	x_counter : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				x <= 0;
			else
				if x = (X_SIZE-1) then
					x <= 0;
				else
					x <= x + 1;
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
				y <= 0;
			else
				if y = (Y_SIZE-1) then
					y <= 0;
				elsif x = (X_SIZE-1) then
					y <= y + 1;
				end if;
			end if;
		end if;
	end process;
	
	-- MAP X,Y COUNTER TO DUT INPUT
	x_coord <= std_logic_vector(to_signed(x, x_coord'length));
	y_coord <= std_logic_vector(to_signed(y, y_coord'length));

	-- OUTPUT COMPLEX COORD IN A FILE
	stimuli : process
		variable L : line;
		variable re_val, im_val : integer;
	begin
	-- Wait for reset to be released
	wait until rst = '0';

	-- Loop over all pixels
	for i in 0 to (X_SIZE * Y_SIZE - 1) loop
		-- Convert to integer (fixed-point)
		re_val := to_integer(signed(z_re));
		im_val := to_integer(signed(z_im));

		-- Write CSV: re_val,im_val
		write(L, re_val);
		write(L, string'(","));
		write(L, im_val);
		writeline(output_file, L);
		
		wait for CLK_PERIOD;
	end loop;

	report "-- Simulation completed successfully --";
	finish; -- End simulation
	end process;
end;