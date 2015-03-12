--ES 31, 14X Final Project
--Matt McFarland and Josh Lang

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity avg_speed_calc is
    Port ( wheel_click : in  STD_LOGIC;
           clear : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           ride_en : in  STD_LOGIC;
           hmph : out  STD_LOGIC_VECTOR (15 downto 0)); --hundreths of miles per hour
end avg_speed_calc;

architecture Behavioral of avg_speed_calc is
signal thousandths_clicks : unsigned (29 downto 0) := (others => '0'); --counter for click total
		--need to be thousandths of clicks to maintain significant figure
signal seconds : unsigned (19 downto 0) := (others => '0');         --second counter for time
signal pulse_count : unsigned (23 downto 0) := (others => '0');     --counter for pulse to determine a second
signal quotient : unsigned (29 downto 0):= (others => '0'); 	--clicks per second
signal update : STD_LOGIC := '0';	
signal unshifted_hmph : unsigned (49 downto 0);						--hmph before shifted as part of strength reduction
signal shifted_hmph : unsigned (31 downto 0);						--hundreths of miles per hour after strength reduction
 
begin
 
TimerUpdate: process (CLK)
 
begin
	if rising_edge(CLK) then 
		update <= '0'; --default
 
	--clear
	if (clear = '1') then
		seconds <= (others => '0');
		pulse_count <= (others => '0');
		thousandths_clicks <= (others => '0');
		quotient <= (others => '0');
	else 
		--check wheel clicks
		if (wheel_click = '1') then
			thousandths_clicks <= thousandths_clicks + 1000; --increment wheel clicks
		end if;
 
		--check if ride enable
		if (ride_en = '1') then 
			pulse_count <= pulse_count + 1;	--increment the pulse count
		else
			pulse_count <= (others => '0');  --if not riding, 0 the pulse count
		end if;
 
		--check if the pulse count has reached a second yet 
		if (pulse_count = 1000000-1) then --number of clock cycles in a second
			pulse_count <= (others => '0');
			seconds <= seconds + 1;
			update <= '1';
		end if;
	end if;
 
--update the quotient every second, since update will be put high every second
	if (update = '1') then
		quotient <= resize(thousandths_clicks/seconds, 30);
	end if;
 
end if;
end process TimerUpdate;

--convert clicks per second to hundreths of meters per hour via strength reduction
unshifted_hmph <= resize((quotient * 1032065), 50);
shifted_hmph <= resize(unshifted_hmph(49 downto 21), 32); --shift right by 21 bits
hmph <= std_logic_vector(shifted_hmph(15 downto 0));

end Behavioral;