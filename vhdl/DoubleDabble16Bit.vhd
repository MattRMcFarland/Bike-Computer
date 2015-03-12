-- ES 31, 14X Final Project
-- Matt McFarland and Josh Lang
-- Original 12 bit double dabble from
-- https://en.wikipedia.org/wiki/Double_dabble
-- modified to output 16 bits by Matt McFarland and Joshua Lang

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
 
entity DoubleDabble16Bit is
    Port ( binaryNum : in  STD_LOGIC_VECTOR (15 downto 0); --16 bit binary number 
           ones : out  STD_LOGIC_VECTOR (3 downto 0);  --will be 3:0 of BCD variable
           tens : out  STD_LOGIC_VECTOR (3 downto 0);  -- will be 7:4 of BCD variable
           hundreds : out  STD_LOGIC_VECTOR (3 downto 0);  --will be 11:8 of BCD variable
			  thousands : out  STD_LOGIC_VECTOR (3 downto 0)); --will be 15:12 of BCD variable

end DoubleDabble16Bit;
 
architecture Behavioral of DoubleDabble16Bit is
 
begin
 
DoubleDabble: process(binaryNum)

  variable converter: STD_LOGIC_VECTOR (15 downto 0);			--need while converting to BCD
  variable BCD: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');  --every four bits is BCD digit
 
  begin
  --zero out the bcd 
  for n in 0 to 15 loop
		BCD(n) := '0';
	end loop;
 
	-- set converter equal to the input binary number
	converter(15 downto 0) := binaryNum;
 
	--cycle 16 times as we have 16 input bits
	for i in 0 to 15 loop
		if BCD(3 downto 0) > 4 then
			BCD(3 downto 0) := BCD(3 downto 0) + 3;
		end if;
 
		if BCD(7 downto 4) > 4 then
			BCD(7 downto 4) := BCD(7 downto 4) + 3;
		end if;
 
		if BCD(11 downto 8) > 4 then
			BCD(11 downto 8) := BCD(11 downto 8) + 3;
		end if;
 
		if BCD(15 downto 12) > 4 then
			BCD(15 downto 12) := BCD(15 downto 12) + 3;
		end if;
 
		--shift BCD left by 1 bit
		BCD(15 downto 1) := BCD(14 downto 0);
		
		-- copy MSB of converter into LSB of BCD
		BCD(0 downto 0):= converter(15 downto 15);
		
		--shift converter left by 1 bit
		converter(15 downto 1) := converter(14 downto 0);
 
end loop;
 
	-- once done looping, send the binary coded decimal digits to proper outputs
	ones <= BCD(3 downto 0);
	tens <= BCD(7 downto 4);
	hundreds <= BCD(11 downto 8);
	thousands <= BCD(15 downto 12);
 
  end process DoubleDabble;            
 
end Behavioral;