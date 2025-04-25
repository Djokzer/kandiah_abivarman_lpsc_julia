library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use std.env.finish;

entity julia_compute_tb is
end;

architecture testbench of julia_compute_tb is
	-- CONSTANTS
	constant clk_period : time := 5 ns;

	-- Generics
	constant X_SIZE      : integer := 1000;
	constant Y_SIZE      : integer := 1000;
	constant RE_MIN      : integer := -2;
	constant RE_MAX      : integer := 2;
	constant IM_MIN      : integer := -2;
	constant IM_MAX      : integer := 2;
	constant FIXED_BITS  : integer := 20;
	constant ITERATIONS  : integer := 100;
	constant THRESHOLD   : integer := 2;
	constant C_RE_FIXED  : integer := integer(0.285 * 2.0**FIXED_BITS);
	constant C_IM_FIXED  : integer := integer(0.01 * 2.0**FIXED_BITS);

	-- SIGNALS
	signal clk            : std_logic := '0';
	signal rst            : std_logic;

	signal escape_counter : std_logic_vector(7 downto 0);
	signal address        : std_logic_vector(31 downto 0);
	signal valid          : std_logic;

	-- CONTROL SIGNAL
	signal finished       : boolean := false;

	-- FILE OUTPUT
	file output_file : text open write_mode is "/home/abi/Documents/other/master/fpga_julia/output/julia_output.csv";

begin
	-- CLOCK AND RESET CONTROL
	clk <= not clk after clk_period / 2;
	rst <= '1', '0'  after CLK_PERIOD * 10;

	-- UNIT UNDER TEST
	uut : entity work.julia_compute
	generic map (
		X_SIZE     => X_SIZE,
		Y_SIZE     => Y_SIZE,
		RE_MIN     => RE_MIN,
		RE_MAX     => RE_MAX,
		IM_MIN     => IM_MIN,
		IM_MAX     => IM_MAX,
		FIXED_BITS => FIXED_BITS,
		ITERATIONS => ITERATIONS,
		THRESHOLD  => THRESHOLD,
		c_re       => C_RE_FIXED,
		c_im       => C_IM_FIXED
	)
	port map (
		clk            => clk,
		rst            => rst,
		escape_counter => escape_counter,
		address        => address,
		valid          => valid
	);

	-- CAPTURE AND FILE OUTPUT
	write_output : process(clk)
		variable L      : line;
		variable val : integer;
	begin
		if rising_edge(clk) then
			if rst = '0' and valid = '1' then
				val := to_integer(unsigned(escape_counter));
				write(L, val);
				writeline(output_file, L);

				if address = std_logic_vector(to_unsigned(X_SIZE * Y_SIZE - 1, 32)) then
					report "-- All pixels written --";
					finish;
				end if;
			end if;
		end if;
	end process;
end architecture;
