--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:37:42 08/23/2014
-- Design Name:   
-- Module Name:   O:/ES31/BikeComputer/BikeComputer_TB.vhd
-- Project Name:  BikeComputer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TopLevel
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY BikeComputer_TB IS
END BikeComputer_TB;
 
ARCHITECTURE behavior OF BikeComputer_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TopLevel
    PORT(
         clk : IN  std_logic;
         WheelSensor : IN  std_logic;
         Unlock : IN  std_logic;
         ChangeMode : IN  std_logic;
         RESET : IN  std_logic;
         RideEnabledOUT : OUT  std_logic;
         Locked : OUT  std_logic;
         CurrentSpeedMode : OUT  std_logic;
         DistanceMode : OUT  std_logic;
         TimerMode : OUT  std_logic;
         AverageSpeedMode : OUT  std_logic;
         segmentsMode : OUT  std_logic_vector(6 downto 0);
         anodesMode : INOUT  std_logic_vector(3 downto 0);
         DecimalPointOut : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal WheelSensor : std_logic := '0';
   signal Unlock : std_logic := '0';
   signal ChangeMode : std_logic := '0';
   signal RESET : std_logic := '0';

	--BiDirs
   signal anodesMode : std_logic_vector(3 downto 0);

 	--Outputs
   signal RideEnabledOUT : std_logic;
   signal Locked : std_logic;
   signal CurrentSpeedMode : std_logic;
   signal DistanceMode : std_logic;
   signal TimerMode : std_logic;
   signal AverageSpeedMode : std_logic;
   signal segmentsMode : std_logic_vector(6 downto 0);
   signal DecimalPointOut : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TopLevel PORT MAP (
          clk => clk,
          WheelSensor => WheelSensor,
          Unlock => Unlock,
          ChangeMode => ChangeMode,
          RESET => RESET,
          RideEnabledOUT => RideEnabledOUT,
          Locked => Locked,
          CurrentSpeedMode => CurrentSpeedMode,
          DistanceMode => DistanceMode,
          TimerMode => TimerMode,
          AverageSpeedMode => AverageSpeedMode,
          segmentsMode => segmentsMode,
          anodesMode => anodesMode,
          DecimalPointOut => DecimalPointOut
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*100;

      WheelSensor <= '1';
		wait for clk_period * 10;
		WheelSensor <= '0';
		
		wait for clk_period*(10*494705);
		
--		WheelSensor <= '1';
--		wait for clk_period * 10;
--		WheelSensor <= '0';
--
--		wait for clk_period*(10*600000);
--		
--		WheelSensor <= '1';
--		wait for clk_period * 10;
--		WheelSensor <= '0';
--
--		wait for clk_period*(10*800000);
--		
--		WheelSensor <= '1';
--		wait for clk_period * 10;
--		WheelSensor <= '0';
--
--		wait for clk_period*(10*1000000);
		
		WheelSensor <= '1';
		wait for clk_period * 10;
		WheelSensor <= '0';

		wait for clk_period*(10*1640771);
		
		WheelSensor <= '1';
		wait for clk_period * 10;
		WheelSensor <= '0';

		wait for clk_period*10*1000;
		RESET <= '1';
		wait for clk_period*10;
		RESET <= '0';
		
		wait for clk_period*10*1000;
		Unlock <= '1';
		wait for clk_period*10;
		Unlock <= '0';
		
		wait for clk_period*10*1000;
		ChangeMode <= '1';
		wait for clk_period*10;
		ChangeMode <= '0';		
		
      wait;

      wait;
   end process;

END;
