--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:19:47 08/15/2014
-- Design Name:   
-- Module Name:   O:/ES31/BikeComputer/avg_speed_TB.vhd
-- Project Name:  BikeComputer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: avg_speed_calc
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
 
ENTITY avg_speed_TB IS
END avg_speed_TB;
 
ARCHITECTURE behavior OF avg_speed_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT avg_speed_calc
    PORT(
         wheel_click : IN  std_logic;
         clear : IN  std_logic;
         CLK : IN  std_logic;
         ride_en : IN  std_logic;
         hmph : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal wheel_click : std_logic := '0';
   signal clear : std_logic := '0';
   signal CLK : std_logic := '0';
   signal ride_en : std_logic := '0';

 	--Outputs
   signal hmph : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: avg_speed_calc PORT MAP (
          wheel_click => wheel_click,
          clear => clear,
          CLK => CLK,
          ride_en => ride_en,
          hmph => hmph
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
