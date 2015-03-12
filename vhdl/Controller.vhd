----------------------------------------------------------------------------------
-- Company: ES 31, 14X Final Project
-- Engineer: Matt McFarland and Josh Lang
-- 
-- Create Date:    10:48:41 08/14/2014 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity Controller is
    Port ( clk : in  STD_LOGIC;		-- 1 MHz clock
           Unlock_MP : in  STD_LOGIC;
           CHGMode_MP : in  STD_LOGIC;
           RESET_MP : in  STD_LOGIC;
			  locked_p : out STD_LOGIC;
           clear : out  STD_LOGIC;
           RideEn_IN : in  STD_LOGIC;
           RideEn_OUT : out  STD_LOGIC;
           Mux : out  STD_LOGIC_VECTOR (1 downto 0));
end Controller;

architecture Behavioral of Controller is
	type statetype is (Startup, locked, unlocked, ClearState, ChangeModeState);
	signal CurrentState, NextState : statetype := startup;
	
	-- clock counter signals
	signal count_en, count_clr, Mux_en, StartEn : STD_LOGIC := '0';
	signal counter : unsigned (23 downto 0) := (others => '0');
	signal startcounter : unsigned (9 downto 0) := (others => '0');
	
	-- multiplexer select bits
	signal MuxBits : unsigned (1 downto 0) := "00";
	
	-- time constants for counters
	--constant LockTime : integer := 12000000 -1 ;-- 12 seconds * 10^7 clk cycles per second
	constant LockTime : integer := 100; -- smaller lock period for debugging
	constant StartTime : integer := 1000 - 1; -- wait 1000 clk cycles on start up.
	
begin

RideEn_OUT <= RideEn_IN; -- pass ride enable to other modules
Mux <= STD_LOGIC_VECTOR(MuxBits); -- assign mux select bits

StateUpdate: process (clk, NextState)
begin
	if (rising_edge(clk)) then
		CurrentState <= NextState;
	end if;
end process;

Combinational : process (Unlock_MP, CHGMode_MP, RESET_MP, CurrentState, Counter, StartCounter)
begin

	-- defaults
	StartEn <= '0';
	clear <= '0';
	count_en <= '0';
	Mux_en <= '0';
	LOCKED_p <= '0';
	count_clr <= '1';
	NextState <= CurrentState;
	
	case CurrentState is 
		
		when StartUp => -- wait 1000 clk cycles to ignore erroneous start up signals
			StartEn <= '1';
			clear <= '1';
			if startcounter = StartTime then NextState <= Locked;
			end if;
	
		when Locked => -- stay locked unless unlock is pressed
			Locked_p <= '1';
			if (Unlock_MP = '1') then 
				NextState <= Unlocked;
			end if;
		
		when Unlocked =>
			count_clr <= '0'; -- allow unlock counter to count
			count_en <= '1';
						
			if (counter > LockTime) then -- 12 * 10^7 clk cycles is a 12 second wait period		
				NextState <= Locked;
			end if;
			
			if (Reset_MP = '1') then -- reset input moves to clear state
				NextState <= ClearState;				
			end if;
			
			if (CHGMode_MP = '1') then -- change mode moves to change mode state
				NextState <= ChangeModeState;
			end if;
		
		-- button presses reset unlock counter
		when ClearState =>
			clear <= '1';
			NextState <= Unlocked;

		when ChangeModeState =>
			NextState <= Unlocked;
			Mux_en <= '1';
			
		end case;
end process;
			
-- clock counter for unlocked state	
-- moves from unlocked to locked after 12 seconds of inactivity and no button presses		
LockCounter : process (clk, count_clr, count_en)
begin
	if rising_edge(clk) then
		if (count_clr = '1') then
			counter <= (others => '0');
		elsif (count_en = '1') then
			counter <= counter + 1;
		end if;
	end if;
end process;

-- clock counter for start up
StartUpCounter : process (clk, StartEn)
begin
	if rising_edge(clk) then
		if (StartEn = '1' and CurrentState = StartUp) then
			StartCounter <= StartCounter + 1;
		end if;
	end if;
end process;

-- four display modes needs two mux bits
MuxCounter : process (clk, Mux_en)
begin
	if rising_edge(clk) then
		if (Mux_en = '1') then
			MuxBits <= MuxBits + 1;
		end if;
	end if;
end process;

end Behavioral;

