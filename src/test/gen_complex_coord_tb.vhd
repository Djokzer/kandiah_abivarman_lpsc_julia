library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use std.env.finish;

entity gen_complex_coord_tb is
end;

architecture testbench of gen_complex_coord_tb is
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
	-- DUT Ports
	signal clk : std_logic := '0';
	signal rst : std_logic;
	signal z_re : std_logic_vector(31 downto 0);
	signal z_im : std_logic_vector(31 downto 0);
	
	-- File for output
	file output_file : text open write_mode is "/home/abi/Documents/other/master/fpga_julia/output/complex_output.csv";
begin
	-- CLOCK AND RESET CONTROL
	clk <= not clk after clk_period/2;
	rst <= '1', '0'  after CLK_PERIOD * 10;
	
	-- DEVICE UNDER TEST
	dut : entity work.gen_complex_coord
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
		clk => clk,
		rst => rst,
		z_re => z_re,
		z_im => z_im
	);

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