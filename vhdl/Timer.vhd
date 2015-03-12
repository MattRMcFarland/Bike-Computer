----------------------------------------------------------------------------------
-- Company: 14X Engs 31 Final Project
-- Engineer: Joshua Lang and Matt McFarland
-- 
-- Create Date:    20:56:59 08/10/2014 
-- Design Name: 
-- Module Name:    timer - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port ( CLK : in  STD_LOGIC;	-- 1 MHz
           ride_en : in  STD_LOGIC;
           clear : in  STD_LOGIC;
           time_out : out  STD_LOGIC_VECTOR(15 downto 0) );
end timer;

architecture Behavioral of timer is
signal hours : unsigned( 7 downto 0) := (others => '0');
signal minutes : unsigned( 7 downto 0) := (others => '0');
signal seconds : unsigned (7 downto 0) := (others => '0');
signal pulse_count : unsigned (23 downto 0) := (others => '0');
 
begin
 
TimerUpdate: process (CLK)
 
begin
	if rising_edge(CLK) then 

		if (clear = '1') then	-- synchronized clear dominant over increment
		hours <= (others => '0');
		minutes <= (others => '0');
		seconds <= (others => '0');
		pulse_count <= (others => '0');

		elsif (ride_en = '1') then -- if enabled, increment pulse
		pulse_count <= pulse_count + 1;

			if (pulse_count = 1000000 - 1) then --number of clock cycles in a second  (if (pulse_count = 10000000 - 1) then)
				pulse_count <= (others => '0');
				seconds <= seconds + 1;
				
				if (seconds = 59) then -- wrap at 60 seconds
					seconds <= (others => '0');
					minutes <= minutes + 1;
					
					if (minutes = 59) then -- wrap minutes
						minutes <= (others => '0');
						hours <= hours + 1;
						
						if (hours = 98) then -- wrap hours
						hours <= (others => '0');
						
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
end process TimerUpdate;
 
-- concatenate hours and minutes 
time_out <= std_logic_vector(hours) & std_logic_vector(minutes);
 
end Behavioral;