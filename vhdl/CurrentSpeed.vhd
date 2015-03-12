----------------------------------------------------------------------------------
-- Company: ES 31 Final Project 14X
-- Engineer: Matt McFarland and Josh Lang
-- 
-- Create Date:    23:21:14 08/12/2014  
-- Description: Outputs 4 4-bit BCD in a 16 bit bus for current speed 10, 1 , 1/10 , 1/100
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity CurrentSpeed is
    Port ( clk : in  STD_LOGIC;
           WheelTick : in  STD_LOGIC;
           RideEn : out  STD_LOGIC;
           CurrentSpeedOut : out  STD_LOGIC_VECTOR (15 downto 0));
end CurrentSpeed;

architecture Behavioral of CurrentSpeed is
	signal firstwheeltick : STD_LOGIC := '0';
	signal pulses, oldpulse : unsigned (23 downto 0) := (others => '1');
	signal speed : unsigned ( 28 downto 0) := (others => '0');
	signal RideEn_w : STD_LOGIC := '0';
	constant HMPHONETICK : unsigned (28 downto 0) := "11101010101101101101000100000"; -- 492,231,200 hundreths MPH / N clock cycles
	constant MINSPEED : unsigned (23 downto 0) := "100101100011011110010000"; -- maximum number of clock cycles before computer decides rider is stopped. (.5 mph)
	--constant MINSPEED : unsigned (23 downto 0) := "000000000000011110010000"; -- smaller number for debugging

begin

-- counts pulses between wheel sensor ticks and assigns ride enable signal
UpdatePulse : process(clk, WheelTick, pulses)
begin
	if rising_edge(clk) then -- rising edge
		if (FirstWheelTick = '0' AND WheelTick = '1') then	-- ignore first wheel tick when initialized
			FirstWheelTick <= '1';
		else
			if (WheelTick = '1') then 	-- completed wheel rotation
				oldpulse <= pulses; -- load old pulses register with pulse count
				pulses <= (others => '0');	-- reset pulse count
				if (pulses <= MINSPEED) then -- if pulses < minspeed then ride enable is high
					RideEn_w <= '1';
				else 
					RideEn_w <= '0';
				end if;
			else -- not completed wheel rotation
				if (pulses <= MINSPEED and FirstWheelTick = '1') then -- pulse count still lower than cut off and first tick ahs occurred
					pulses <= pulses + 1; -- add a pulse
					RideEn_w <= '1'; -- ride enable still high
				else 
					RideEn_w <= '0';
				end if;
			end if;
		end if;
	end if;
end process;

UpdateSpeed : process (oldpulse, pulses, WheelTick, RideEn_w)
begin
	if RideEn_w = '1' then -- keep current speed updated whenever wheel sensor goes around and still riding
		speed <= resize(HMPHONETICK / oldpulse, 29); -- old pulses updates every wheel rotation
	else
		speed <= (others => '0'); -- if ride enable is zero, set current speed to zero
	end if;
end process;

CurrentSpeedOut <= STD_LOGIC_VECTOR(speed (15 downto 0));
RideEn <= RideEn_w;

end Behavioral;

