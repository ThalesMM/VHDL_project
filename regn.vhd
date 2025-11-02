library ieee;
  use ieee.std_logic_1164.all;

entity regn is
  generic (n : INTEGER := 16);
  port (R          : in     STD_LOGIC_VECTOR(n - 1 downto 0);
        Rin, Clock : in     STD_LOGIC;
        Q          : buffer STD_LOGIC_VECTOR(n - 1 downto 0));
end entity;

architecture Behavior of regn is
begin
  process (Clock)
  begin
    if Clock'EVENT and Clock = '1' then
      if Rin = '1' then
        Q <= R;
      end if;
    end if;
  end process;
end architecture;
