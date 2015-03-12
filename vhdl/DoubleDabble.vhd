-- ES 31, 14X Final Project
-- Matt McFarland and Josh Lang
-- Original 12 bit double dabble from
-- https://en.wikipedia.org/wiki/Double_dabble
-- modified to output 16 bits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
 
entity bin2bcd_12bit is
    Port ( binIN : in  STD_LOGIC_VECTOR (15 downto 0);
           ones : out  STD_LOGIC_VECTOR (3 downto 0);
           tenths : out  STD_LOGIC_VECTOR (3 downto 0);
           hunderths : out  STD_LOGIC_VECTOR (3 downto 0);
 thousands : out  STD_LOGIC_VECTOR (3 downto 0);
           clk : in  STD_LOGIC);
end bin2bcd_12bit;
 
architecture Behavioral of bin2bcd_12bit is
 
begin
 
bcd1: process(binIN)
 
  -- temporary variable
  variable temp: STD_LOGIC_VECTOR (15 downto 0);
  -- variable to store the output BCD number
  -- organized as follows
  -- thousands = bcd(15 downto 12)
  -- hunderths = bcd(11 downto 8)
  -- tenths = bcd(7 downto 4)
  -- units = bcd(3 downto 3)
  variable BCD: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
 
-- by
-- https://en.wikipedia.org/wiki/Double_dabble
  begin
--zero the bcd variable
  for i in 0 to 15 loop
bcd(i) := '0';
    end loop;
 
-- read input into temp variable
temp(15 downto 0) := binIN;
 
--cycle 16 times as we have 16 input bits
--this could be optimized, we dont need to check and add 3 for the 
--first 3 iterations as the number can never be >4
for i in 0 to 15 loop
 
if bcd(3 downto 0) > 4 then
  bcd(3 downto 0) := bcd(3 downto 0) + 3;
end if;
 
if bcd(7 downto 4) > 4 then
  bcd(7 downto 4) := bcd(7 downto 4) + 3;
end if;
 
if bcd(11 downto 8) > 4 then
  bcd(11 downto 8) := bcd(11 downto 8) + 3;
end if;
 
--thousands can´t newer be >4 for a 16 bit input number
if bcd(15 downto 12) > 4 then
  bcd(15 downto 12) := bcd(15 downto 12) + 3;
end if;
 
--shift bcd left by 1 bit
bcd(15 downto 1) := bcd(14 downto 0);
-- copy MSB of temp into LSB of bcd
bcd(0 downto 0):= temp(15 downto 15);
--shift temp left by 1 bit
temp(15 downto 1) := temp(14 downto 0);
 
end loop;
 
-- set outputs
ones <= bcd(3 downto 0);
tenths <= bcd(7 downto 4);
hunderths <= bcd(11 downto 8);
thousands <= bcd(15 downto 12);
 
  end process bcd1;            
 
end Behavioral;