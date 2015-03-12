--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:15:38 08/14/2014
-- Design Name:   
-- Module Name:   O:/ES31/BikeComputer/Controller_TB.vhd
-- Project Name:  BikeComputer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Controller
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
 
ENTITY Controller_TB IS
END Controller_TB;
 
ARCHITECTURE behavior OF Controller_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Controller
    PORT(
         clk : IN  std_logic;
         Unlock_MP : IN  std_logic;
         CHGMode_MP : IN  std_logic;
         RESET_MP : IN  std_logic;
         clear : OUT  std_logic;
         RideEn_IN : IN  std_logic;
         RideEn_OUT : OUT  std_logic;
         Mux : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal Unlock_MP : std_logic := '0';
   signal CHGMode_MP : std_logic := '0';
   signal RESET_MP : std_logic := '0';
   signal RideEn_IN : std_logic := '0';

 	--Outputs
   signal clear : std_logic;
   signal RideEn_OUT : std_logic;
   signal Mux : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Controller PORT MAP (
          clk => clk,
          Unlock_MP => Unlock_MP,
          CHGMode_MP => CHGMode_MP,
          RESET_MP => RESET_MP,
          clear => clear,
          RideEn_IN => RideEn_IN,
          RideEn_OUT => RideEn_OUT,
          Mux => Mux
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

      wait for clk_period*1000;

      RESET_MP <= '1';
		wait for clk_period*1;
		RESET_MP <= '0';
		wait for clk_period*10;

      unlock_MP <= '1';
		wait for clk_period*1;
		unlock_MP <= '0';
		wait for clk_period*10;

      RESET_MP <= '1';
		wait for clk_period*1;
		RESET_MP <= '0';
		wait for clk_period*10;
		
		CHGMode_MP <= '1';
		wait for clk_period*1;
		CHGMode_MP <= '0';
		wait for clk_period*10;
		CHGMode_MP <= '1';
		wait for clk_period*1;
		CHGMode_MP <= '0';
		wait for clk_period*10;
		CHGMode_MP <= '1';
		wait for clk_period*1;
		CHGMode_MP <= '0';
		wait for clk_period*10;
		CHGMode_MP <= '1';
		wait for clk_period*1;
		CHGMode_MP <= '0';
		wait for clk_period*10;
		CHGMode_MP <= '1';
		wait for clk_period*1;
		CHGMode_MP <= '0';
		wait for clk_period*10;
		
      wait;
   end process;

END;
