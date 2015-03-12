----------------------------------------------------------------------------------
-- Company: ES 31, 14X Final Project
-- Engineer: Matt McFarland and Josh Lang
-- 
-- Create Date:    10:27:52 08/14/2014 
-- Design Name: 
-- Module Name:    TopLevel - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TopLevel is
    Port ( clk : in  STD_LOGIC;
           WheelSensor : in  STD_LOGIC;
           Unlock : in  STD_LOGIC;
           ChangeMode : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
			  RideEnabledOUT : out STD_LOGIC;
			  Locked : out STD_LOGIC;
			  CurrentSpeedMode : out STD_LOGIC;
			  DistanceMode : out STD_LOGIC;
			  TimerMode : out STD_LOGIC;
			  AverageSpeedMode : out STD_LOGIC;
			  segmentsMode :out  STD_LOGIC_VECTOR (6 downto 0);
			  anodesMode : inout STD_LOGIC_VECTOR (3 downto 0);	-- inout so we can read when specific digits are selected for decimal point
			  DecimalPointOut : out STD_LOGIC) ;
end TopLevel;

architecture Behavioral of TopLevel is

constant CLOCK_DIVIDER_VALUE: integer := 50;
signal clkdiv: integer := 0;			-- the clock divider counter
signal clk_en: std_logic := '0';		-- terminal count
signal clk1: std_logic;				-- the slower clock

-- Monopulse and debouncing signals for inputs
signal WheelSensor_DB, Unlock_DB, ChangeMode_DB, RESET_DB : STD_LOGIC;
signal WSold, WScurr, ULold, ULcurr, CMold, CMcurr, RTold, RTcurr : STD_LOGIC;
signal WheelSensor_MPw, CHGMode_MPw, RESET_MPw, Unlock_MPw : STD_LOGIC;

-- Wheel Sensor is active low
signal InverseWheelSensor : STD_LOGIC;

-- 16 bit vectors from double dabbles to 4 digit, 7 segment displays
signal cs_w, MD_dist, MD_timer, MD_avgspeed, Mode_w, Mode: STD_LOGIC_VECTOR (15 downto 0);

signal RideEn_I : STD_LOGIC; -- signal from CurrentSpeedCalc to controller
signal RideEn_O : STD_LOGIC; -- signal from Controller to components
signal clear_w :STD_LOGIC; -- signal from controller to components to clear
signal MuxSelect : STD_LOGIC_VECTOR ( 1 downto 0); -- select bits on multiplexer generated in controller
signal time_w : unsigned (15 downto 0);

-- signals to double dabble A and B
signal DDAin, DDBin : STD_LOGIC_VECTOR (15 downto 0);
signal DDAout, DDBout : STD_LOGIC_VECTOR ( 15 downto 0);

-- signal passed into 7-seg multiplexer
signal Mux7SegIn : STD_LOGIC_VECTOR (15 downto 0);

-- 00.00 to 99.99 mph Current Speed calculator
COMPONENT CurrentSpeed is
    Port ( clk : in  STD_LOGIC;	-- 1 MHz clock
           WheelTick : in  STD_LOGIC;
           RideEn : out  STD_LOGIC;
           CurrentSpeedOut : out  STD_LOGIC_VECTOR (15 downto 0)); -- unsigned, hundredths of mph
end COMPONENT;

-- controller
COMPONENT Controller is
    Port ( clk : in  STD_LOGIC;		-- 1 MHz clock
           Unlock_MP : in  STD_LOGIC;
           CHGMode_MP : in  STD_LOGIC;
           RESET_MP : in  STD_LOGIC;
			  locked_p : out STD_LOGIC;
           clear : out  STD_LOGIC;
           RideEn_IN : in  STD_LOGIC;
           RideEn_OUT : out  STD_LOGIC;
           Mux : out  STD_LOGIC_VECTOR (1 downto 0));
end COMPONENT;

-- HH:MM total ride time 
COMPONENT timer is
    Port ( CLK : in  STD_LOGIC;	-- 1 MHz clock
           ride_en : in  STD_LOGIC;
           clear : in  STD_LOGIC;
           time_out : out  STD_LOGIC_VECTOR(15 downto 0) ); -- 15 downto 8 are unsigned hours, 7 downto 0 are unsigned minutes
end COMPONENT;


-- 00.00 to 99.99 mph avg speed calcuator
COMPONENT avg_speed_calc is
    Port ( wheel_click : in  STD_LOGIC;
           clear : in  STD_LOGIC;
           CLK : in  STD_LOGIC;		-- 1 MHz clock
           ride_en : in  STD_LOGIC;
           hmph : out  STD_LOGIC_VECTOR (15 downto 0)); --hundreths of miles per hour
end COMPONENT;

-- 000.0 to 999.9 mile total distance counter
COMPONENT distance_calc is
    Port ( clk : in  STD_LOGIC;
			  dist_clear : in STD_LOGIC;
           wheel_click_in : in  STD_LOGIC;
           miles_dist : out  STD_LOGIC_VECTOR (15 downto 0)); -- unsigned, tenths of miles
end component;

-- 16 binary to 4 x 4 BCD Double Dabble
COMPONENT DoubleDabble16Bit is		-- ACTUALLY A 16 BIT DOUBLE DABBLE
    Port ( binaryNum : in  STD_LOGIC_VECTOR (15 downto 0);
           ones : out  STD_LOGIC_VECTOR (3 downto 0);
           tens : out  STD_LOGIC_VECTOR (3 downto 0);
           hundreds : out  STD_LOGIC_VECTOR (3 downto 0);
			  thousands : out  STD_LOGIC_VECTOR (3 downto 0)
			  );
end COMPONENT;

-- Multiplexed seven segment display
-- recycled from Lab 4
signal tie_low: std_logic;
component mux7seg is
    Port ( 	clk : in  STD_LOGIC;
           	y0, y1, y2, y3 : in  STD_LOGIC_VECTOR (3 downto 0);
	   	 	bi : in  STD_LOGIC;							
           	seg : out  STD_LOGIC_VECTOR (6 downto 0);	
           	an : out  STD_LOGIC_VECTOR (3 downto 0) );			
end component;

-- Debouncer
-- recycled from Lab 4
component debounce is
    Port ( clk 	: in  STD_LOGIC;
           switch 	: in  STD_LOGIC;		-- switch input
           dbswitch : out STD_LOGIC );		-- debounced output
end component;

begin

-- Clock buffer for 10 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
Slow_clock_buffer: BUFG
      port map (I => clk_en,
                O => clk1 );

-- Divide the 100 MHz clock down to 20 MHz, then toggling the 
-- clk_en signal at 20 MHz gives a 10 MHz clock with 50% duty cycle
Clock_divider: process(clk)
begin
	if rising_edge(clk) then
	   	if clkdiv = CLOCK_DIVIDER_VALUE-1 then 
	   		clk_en <= NOT(clk_en);		
			clkdiv <= 0;
		else
			clkdiv <= clkdiv + 1;
		end if;
	end if;
end process Clock_divider;	

-- Ride Enable LED
RideEnabledOut <= RideEn_I;

-- LED Mode indicate which mode is displayed
ModeSignals : process (MuxSelect)
begin
   CurrentSpeedMode <= '0';
   DistanceMode <= '0';
   TimerMode <= '0';
   AverageSpeedMode <= '0';
	if ( MuxSelect = "00" ) then CurrentSpeedMode <= '1';
	elsif ( MuxSelect = "01" ) then DistanceMode <= '1';
	elsif ( MuxSelect = "10" ) then TimerMode <= '1';
	else AverageSpeedMode <= '1';
	end if;
end process;

CScalc : CurrentSpeed
	PORT MAP ( clk => clk1,
				--WheelTick => WheelSensor_MPw,
				WheelTick => WheelSensor,
				RideEn => RideEn_I,
				CurrentSpeedOut => CS_w);
				
Cntrllr : Controller
	PORT MAP( clk => clk1,
				locked_p => Locked,
				Unlock_MP => Unlock,
				CHGMode_MP => ChangeMode,
				RESET_MP => RESET,
--				Unlock_MP => Unlock_MPw,
--				CHGMode_MP => CHGMode_MPw,
--				RESET_MP => RESET_MPw,
				clear => clear_w,
				RideEn_IN => RideEn_I,
				RideEn_OUT => RideEn_O,
				Mux => MuxSelect);

RideTime : timer
	PORT MAP( clk => clk1,
				ride_en => RideEn_O,
				clear => clear_w,
				time_out => MD_timer);
				
AVGSpeed : avg_speed_calc 
    PORT MAP (clk => clk1,
			  --wheel_click => WheelSensor_MPw,
			  wheel_click => WheelSensor,
           clear => clear_w,
           ride_en => RideEn_O,
           hmph => MD_avgspeed );

DistCalc : distance_calc 
    PORT MAP( clk => clk1,
			  dist_clear => clear_w,
			  Wheel_click_in => WheelSensor,
           --wheel_click_in => WheelSensor_MPw,
           miles_dist => MD_dist);

-- 16 bit binary to BCD	
-- DDA is default double dabble		  
DDA : DoubleDabble16Bit
	PORT MAP (
				binaryNum => DDAin,
				ones => DDAout (3 downto 0),
				tens => DDAout ( 7 downto 4), 
				hundreds => DDAout ( 11 downto 8), 
				thousands => DDAout( 15 downto 12) );
				
-- DDB is used for hours conversion to BCD in time mode			
DDB : DoubleDabble16Bit
	PORT MAP ( 
				binaryNum => DDBin,
				ones => DDBout (3 downto 0),
				tens => DDBout ( 7 downto 4), 
				hundreds => DDBout ( 11 downto 8), 
				thousands => DDBout( 15 downto 12) );				

-- change input into double dabble
DDAin <=	   CS_w when MuxSelect = "00" else		-- current speed 
				MD_dist when MuxSelect = "01" else		-- distance
				x"00" & MD_timer(7 downto 0) when MuxSelect = "10" else		-- See below. MD_timer needs to split minutes and hours bits
				MD_avgspeed when MuxSelect = "11" else	-- avg speed
				(others => '0');

-- When MuxSelect = "10"				
-- send hours bits to separate double dabble				
DDBin <= x"00" & MD_timer(15 downto 8);		
-- send output of minutes double dabble to two least significant digits. Send output of hours double dabble to two most significant digits
Mux7SegIn <= DDBout(7 downto 0) & DDAout(7 downto 0) when MuxSelect = "10"  else DDAout;	 -- when 			


-- assign decimal points according to mode
DecimalPointUpdate : process (MuxSelect, AnodesMode)
begin
	if (MuxSelect = "00" and AnodesMode(2) = '0') then 	-- in current speed, after 2nd most signifcant digit
		DecimalPointOut <= '0';
	elsif( MuxSelect = "01" and AnodesMode(1) = '0') then		-- in distance, after 3rd most significant digit
		DecimalPointOut <= '0';
	elsif( MuxSelect = "10" and AnodesMode(2) = '0') then		-- in time mode, after 2nd most significant digit
		DecimalPointOut <= '0';
	elsif( MuxSelect = "11" and AnodesMode (2) = '0') then  -- in avg speed mode, after 2nd most significant digit
		DecimalPointOut <= '0';
	else
		DecimalPointOut <= '1';
	end if;
end process;

tie_low <= '0';
ModeDisplay: mux7seg
    Port Map ( clk => clk ,	-- runs off the fast master clock
           	y3 => Mux7segIn(15 downto 12), 		-- most significant digit
           	y2 => Mux7SegIn(11 downto 8),  	--		map to actual signals
           	y1 => Mux7SegIn(7 downto 4), 		--		when you add counter instances
           	y0 => Mux7SegIn(3 downto 0),		-- least significant digit
	   		bi => tie_low,						
           	seg => segmentsMode,
           	an => anodesMode );	
				
-- Hall Switch is low true
InverseWheelSensor <= NOT(WheelSensor);				
WheelSensorDB : debounce 
    PORT MAP( clk => clk1,
           switch => InverseWheelSensor,		-- switch input
           dbswitch => WheelSensor_DB );		-- debounced output

-- Input monopulsers and debouncers below
WheelSensorMonopulse : process( clk1, WheelSensor_DB)
begin
	if rising_edge(clk1) then
		if ( WSold = '0' and WScurr = '1') then
			WheelSensor_MPw <= '1';
		else
			WheelSensor_MPw <= '0';
		end if;
		
		WSold <= WScurr;
		WScurr <= WheelSensor_DB;
	end if;
end process;

UnlockDB : debounce 
    PORT MAP( clk => clk1,
           switch => Unlock,		-- switch input
           dbswitch => Unlock_DB );		-- debounced output	

UnlockMonopulse : process( clk1, WheelSensor_DB)
begin
	if rising_edge(clk1) then
		if ( ULold = '0' and ULcurr = '1') then
			Unlock_MPw <= '1';
		else
			Unlock_MPw <= '0';
		end if;
		
		ULold <= ULcurr;
		ULcurr <= Unlock_DB;
	end if;
end process;
	  
RESETDB : debounce 
    PORT MAP( clk => clk1,
           switch => RESET,		-- switch input
           dbswitch => RESET_DB );		-- debounced output

RESETMonopulse : process( clk1, RESET_DB)
begin
	if rising_edge(clk1) then
		if ( RTold = '0' and RTcurr = '1') then
			RESET_MPw <= '1';
		else
			RESET_MPw <= '0';
		end if;
		
		RTold <= RTcurr;
		RTcurr <= RESET_DB;
	end if;
end process;
			  
ChangeModeDB : debounce 
    PORT MAP( clk => clk1,
           switch => ChangeMode,		-- switch input
           dbswitch => ChangeMode_DB );		-- debounced output	

ChangeModeMonopulse : process( clk1, ChangeMode_DB)
begin
	if rising_edge(clk1) then
		if ( CMold = '0' and CMcurr = '1') then
			CHGMode_MPw <= '1';
		else
			CHGMode_MPw <= '0';
		end if;
		
		CMold <= CMcurr;
		CMcurr <= ChangeMode_DB;
	end if;
end process;
			  
end Behavioral;