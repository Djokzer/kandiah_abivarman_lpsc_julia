library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity julia_compute is
    generic(
        -- FIXED POINT  
		FIXED_BITS	    : integer := 20;

        -- COMPLEX CONST
        c_re            : integer := 298844;    -- Real = 0.285, with Fixed bits = 0.285 * 2**20
        c_im            : integer := 10485      -- Imaginary = 0.01j, with Fixed bits = 0.01 * 2**20
    );
    port (
        -- GENERAL
        clk             : in std_logic;
        reset           : in std_logic;
        
        -- COMPLEX POINT
		z_re            : in std_logic_vector(31 downto 0);
		z_im            : in std_logic_vector(31 downto 0);

        -- JULIA OUTPUT
        escape_counter  : out std_logic_vector(7 downto 0); -- When counter = 100, Z is in julia set
        address         : out std_logic_vector(31 downto 0);
        valid           : out std_logic
    );
end entity julia_compute;

architecture rtl of julia_compute is

begin

    

end architecture;