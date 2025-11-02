
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_signed.all;

entity proc is
  port (DIN                    : in     STD_LOGIC_VECTOR(15 downto 0);
        Resetn, Clock, Run     : in     STD_LOGIC;
        Done                   : buffer STD_LOGIC;
        BusWires               : buffer STD_LOGIC_VECTOR(15 downto 0);
        T                      : out    std_LOGIC_VECTOR(1 downto 0);
        reg0, reg1, regA, regG : out    STD_LOGIC_VECTOR(15 downto 0);
        regIR                  : out    STD_LOGIC_VECTOR(8 downto 0)
       );
end entity;

architecture Behavior of proc is

  --. . . declare components
  component regn
    generic (n : INTEGER := 16);
    port (R          : in     STD_LOGIC_VECTOR(n - 1 downto 0);
          Rin, Clock : in     STD_LOGIC;
          Q          : buffer STD_LOGIC_VECTOR(n - 1 downto 0));
  end component;

  component ALU
    port (RA, BusWires : in     STD_LOGIC_VECTOR(15 downto 0);
          Soma_sub     : in     STD_LOGIC;
          ALUbus       : buffer STD_LOGIC_VECTOR(15 downto 0));
  end component;

  component mux_e

    port (

      Din                                : in     std_logic_vector(15 downto 0);
      RG, R0, R1, R2, R3, R4, R5, R6, R7 : in     std_logic_vector(15 downto 0);
      Rout                               : in     std_logic_vector(7 downto 0);
      Dinout                             : in     std_logic;
      Gout                               : in     std_logic;
      busWire                            : buffer std_LOGIC_VECTOR(15 downto 0)

    );
  end component;

  component dec3to8
    port (W  : in  STD_LOGIC_VECTOR(2 downto 0);
          En : in  STD_LOGIC;
          Y  : out STD_LOGIC_VECTOR(7 downto 0));
  end component;

  component upcount is
    port (Clear, Clock : in  STD_LOGIC;
          Q            : out STD_LOGIC_VECTOR(1 downto 0));
  end component;

  --. . . declare signals
  signal Ain, Gin, IRin                         : std_logic;
  signal Dinout, Gout                           : std_logic;
  signal soma_sub, Clear                        : std_logic;
  signal High                                   : std_logic := '1';
  signal IR                                     : std_logic_vector(8 downto 0);
  signal Rin, Rout                              : std_LOGIC_VECTOR(7 downto 0);
  signal xreg, yreg                             : std_LOGIC_VECTOR(7 downto 0);
  signal Tstep_Q                                : std_LOGIC_VECTOR(1 downto 0);
  signal RA, RG, R0, R1, R2, R3, R4, R5, R6, R7 : std_logic_vector(15 downto 0);
  signal ALUbus                                 : std_logic_vector(15 downto 0);
  signal I                                      : std_logic_vector(2 downto 0);

begin
  High  <= '1';
  T     <= Tstep_Q;
  Clear <= not resetn;
  Tstep: upcount port map (Clear, Clock, Tstep_Q);
  I <= IR(8 downto 6);

  --. . . instantiate other registers and the adder/subtracter unit
  reg_0: regn port map (BusWires, Rin(0), Clock, R0);
  reg_1: regn port map (BusWires, Rin(1), Clock, R1);
  reg_2: regn port map (BusWires, Rin(2), Clock, R2);
  reg_3: regn port map (BusWires, Rin(3), Clock, R3);
  reg_4: regn port map (BusWires, Rin(4), Clock, R4);
  reg_5: regn port map (BusWires, Rin(5), Clock, R5);
  reg_6: regn port map (BusWires, Rin(6), Clock, R6);
  reg_7: regn port map (BusWires, Rin(7), Clock, R7);

  reg_a: regn port map (BusWires, Ain, Clock, Ra);
  reg_g: regn port map (ALUbus, Gin, Clock, Rg);
  regn_ir: regn
    generic map (n => 9)
    port map (R => Din(15 downto 7), Rin => IRin, Clock => Clock, Q => IR);

  decX: dec3to8 port map (IR(5 downto 3), High, Xreg);
  decY: dec3to8 port map (IR(2 downto 0), High, Yreg);

  mux: mux_e port map (Din, RG, R0, R1, R2, R3, R4, R5, R6, R7, Rout, Dinout, Gout, busWires);

  ALU_d: Alu port map (RA, BusWires, Soma_sub, ALUbus);

  reg0  <= r0;
  reg1  <= r1;
  regA  <= Ra;
  regG  <= rg;
  regIR <= Ir;

  controlsignals: process (Tstep_Q, I, Xreg, Yreg)
  begin
    Done <= '0';

    case Tstep_Q is
      when "00" => --store DIN in IR as long as Tstep_Q = 0
        if run = '1' then
          IRin <= '1';
        end if;

      when "01" => -- define signals in time step T1
        if run = '1' then

          case I is

            when "000" => Rin <= xreg;
                          Rout <= yreg;
                          done <= '1';

            when "001" => Dinout <= '1';
                          Rin <= xreg;
                          done <= '1';

            when "010" => Rout <= xreg;
                          Ain <= '1';

            when "011" => Rout <= xreg;
                          Ain <= '1';

            when others => null;
          end case;
        end if;

      when "10" => -- define signals in time step T2

        if run = '1' then

          case I is

            when "000" => Done <= '1';

            when "001" => Done <= '1';

            when "010" => Rout <= yreg;
                          Gin <= '1';
                          soma_sub <= '1';

            when "011" => Rout <= yreg;
                          Gin <= '1';
                          soma_sub <= '0';

            when others => null;

          end case;

        end if;

      when "11" => -- define signals in time step T3

        if run = '1' then

          case I is

            when "000" => Done <= '1';

            when "001" => Done <= '1';

            when "010" => Rin <= xreg;
                          Gout <= '1';
                          Done <= '1';

            when "011" => Rin <= xreg;
                          Gout <= '1';
                          Done <= '1';
            when others => null;
            --. . .
          end case;

        end if;
      when others => null;
    end case;
  end process;

end architecture;
