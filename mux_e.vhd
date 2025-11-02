
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_signed.all;

entity mux_e is

  port (

    Din                                : in  std_logic_vector(15 downto 0);
    RG, R0, R1, R2, R3, R4, R5, R6, R7 : in  std_logic_vector(15 downto 0);
    Rout                               : in  std_logic_vector(7 downto 0);
    Dinout                             : in  std_logic;
    Gout                               : in  std_logic;
    busWire                            : buffer std_LOGIC_VECTOR(15 downto 0)

  );

end entity;

architecture behavior of mux_e is

begin

  buswire <= Din when Dinout = '1' else
             RG  when Gout = '1' else
             R0  when Rout(0) = '1' else
             R1  when Rout(1) = '1' else
             R2  when Rout(2) = '1' else
             R3  when Rout(3) = '1' else
             R4  when Rout(4) = '1' else
             R5  when Rout(5) = '1' else
             R6  when Rout(6) = '1' else
             R7  when Rout(7) = '1' else
				 x"0000" ;
end architecture;
