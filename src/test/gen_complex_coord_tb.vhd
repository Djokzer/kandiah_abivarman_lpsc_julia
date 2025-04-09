library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_complex_coord_tb is
end;

architecture testbench of gen_complex_coord_tb is
	-- Clock period
	constant clk_period : time := 5 ns;
	-- Generics
	constant X_SIZE : integer := 10;
	constant Y_SIZE : integer := 10;
	constant RE_MIN : integer := -2;
	constant RE_MAX : integer := 2;
	constant IM_MIN : integer := -2;
	constant IM_MAX : integer := 2;
	constant FIXED_BITS : integer := 20;
	-- Ports
	signal clk : std_logic;
	signal rst : std_logic;
	signal z_re : std_logic_vector(31 downto 0);
	signal z_im : std_logic_vector(31 downto 0);
	
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

	stimuli : process
	begin
		
	end process;
end;