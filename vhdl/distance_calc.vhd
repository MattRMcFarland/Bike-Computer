----------------------------------------------------------------------------------
-- Company: 14X Engs 31 Project
-- Engineer: Joshua Lang and Matt McFarland
-- 
-- Create Date:    16:50:21 08/10/2014 
-- Design Name: 
-- Module Name:    distance_calc - Behavioral  
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity distance_calc is
    Port ( CLK : in  STD_LOGIC;
			  dist_clear : in STD_LOGIC;										--clears the distance count
           wheel_click_in : in  STD_LOGIC;								--signal that the magnet passed by the hall effect sensor
           miles_dist : out  STD_LOGIC_VECTOR (15 downto 0));		--distance in tenths of miles
end distance_calc;

architecture Behavioral of distance_calc is
signal cm_dist : unsigned (29 downto 0):= (others => '0'); --need to have 30 bits to cover the max possible number of cm
signal unshifted_mi_dist: unsigned (44 downto 0) := (others => '0');
signal mi_dist: unsigned (31 downto 0) := (others => '0');

begin

DataUpdate: process (CLK) 
begin 
 
	if rising_edge(CLK) then
		if (dist_clear = '1')  then cm_dist <= (others => '0'); -- clear to zero
		elsif (wheel_click_in = '1') then cm_dist <= cm_dist + 220; -- increment by one wheel tick (220 cm)           
		end if;
	end if;
	
end process DataUpdate;
 
--convert cm to tenths of miles using strength reduction
unshifted_mi_dist <= resize((cm_dist * 16680), 45);
mi_dist <= resize(unshifted_mi_dist(44 downto 28), 32); --shift right by 28 bits
miles_dist <= std_logic_vector(mi_dist(15 downto 0)); 	--output the distance travelled in tenths of miles


end Behavioral;