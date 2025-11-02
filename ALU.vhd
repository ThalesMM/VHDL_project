
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_signed.all;

entity ALU is
  port (RA, BusWires : in     STD_LOGIC_VECTOR(15 downto 0);
        Soma_sub     : in     STD_LOGIC;
        ALUbus       : buffer STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture Behavior of ALU is

begin

  ALUbus <= Ra + BusWires when Soma_sub = '1' else Ra - BusWires when Soma_sub = '0';

end Behavior;
