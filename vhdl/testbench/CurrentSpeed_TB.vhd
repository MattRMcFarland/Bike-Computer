--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:55:58 08/13/2014
-- Design Name:   
-- Module Name:   O:/ES31/BikeComputer/CurrentSpeed_TB.vhd
-- Project Name:  BikeComputer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CurrentSpeed
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
 
ENTITY CurrentSpeed_TB IS
END CurrentSpeed_TB;
 
ARCHITECTURE behavior OF CurrentSpeed_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CurrentSpeed
    PORT(
         clk : IN  std_logic;
         WheelTick : IN  std_logic;
         RideEn : OUT  std_logic;
         CurrentSpeedOut : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal WheelTick : std_logic := '0';

 	--Outputs
   signal RideEn : std_logic;
   signal CurrentSpeedOut : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CurrentSpeed PORT MAP (
          clk => clk,
          WheelTick => WheelTick,
          RideEn => RideEn,
          CurrentSpeedOut => CurrentSpeedOut
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

      wait for clk_period*70;
		
		WheelTick <= '1';
		wait for clk_period*1;
		WheelTick <= '0';
		
		wait for clk_period*1;
		WheelTick <= '1';
		wait for clk_period*1;
		WheelTick <= '0';

      wait for clk_period*161387;
		
		WheelTick <= '1';
		
		wait for clk_period*1;
		
		WheelTick <= '0';
		
		wait for clk_period*70000;
		
		WheelTick <= '1';
		
		wait for clk_period*1;
		
		WheelTick <= '0';


      wait;
   end process;

END;
