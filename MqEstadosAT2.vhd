library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MqEstadosAT2 is
    port (
        clk    : in std_logic;                  -- Clock input
        reset  : in std_logic;                  -- Reset input
        run    : in std_logic;                  -- Run signal to start execution
        DIN    : in std_logic_vector(15 downto 0);  -- Instruction/Data input
        Buss   : out std_logic_vector(15 downto 0);  -- Output bus (to LEDs)
        PC     : out std_logic_vector(7 downto 0);  -- Program Counter (to LEDs)
        Done   : out std_logic                    -- Done signal to indicate completion
    );
end MqEstadosAT2;

architecture Behavioral of MqEstadosAT2 is

    -- Define processor states
    type state_type is (IDLE, FETCH, DECODE, ADD, SUB, MOV1, MOV2);
    signal current_state, next_state : state_type := IDLE;

    -- Internal signals and registers
    signal pc_reg : integer := 0;                -- Program counter
    signal IR : std_logic_vector(8 downto 0) := (others => '0');  -- Instruction register
    signal opcode, regcod1, regcod2 : std_logic_vector(2 downto 0) := (others => '0');

    -- Register file (R0 to R7 as array)
    type reg_file is array (0 to 7) of std_logic_vector(15 downto 0);
    signal registers : reg_file := (others => (others => '0'));

    -- Auxiliary signals
    signal Buss_internal : std_logic_vector(15 downto 0) := (others => '0');
    signal valor : std_logic_vector(15 downto 0) := (others => '0');

begin
    -- State transition and operations
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all states and signals
            current_state <= IDLE;
            pc_reg <= 0;
            registers <= (others => (others => '0'));
            Buss_internal <= (others => '0');
            Buss <= (others => '0');
            PC <= (others => '0');
            Done <= '0';
        elsif rising_edge(clk) then
            -- State transitions
            current_state <= next_state;

            case current_state is
                when IDLE =>
                    if run = '1' then
                        next_state <= FETCH;
                    else
                        next_state <= IDLE;
                    end if;

                when FETCH =>
                    -- Fetch instruction and increment PC
                    IR <= DIN(15 downto 7);  -- Load instruction
                    valor <= std_logic_vector(resize(unsigned(DIN(6 downto 0)), 16));  -- Immediate value
                    pc <= "00000001";
                    opcode <= IR(8 downto 6);
                    regcod1 <= IR(5 downto 3);
                    regcod2 <= IR(2 downto 0);
						  Done<='0';
                    next_state <= DECODE;

                when DECODE =>
                    -- Decode opcode and transition to corresponding state
                    case opcode is
                        when "000" => next_state <= MOV1;  -- MOV
									PC<="00000010";
                        when "001" => next_state <= MOV2;  -- MOV Immediate
									PC<="00000100";
                        when "010" => next_state <= ADD;   -- ADD
									PC<="00001000";
                        when "011" => next_state <= SUB;   -- SUB
									PC<="00010000";
                        when others => next_state <= IDLE; -- Invalid opcode
                    end case;

                when MOV1 =>
                    -- Register-to-register MOV
                    registers(to_integer(unsigned(regcod1))) <= 
                        registers(to_integer(unsigned(regcod2)));
                    Buss <= registers(to_integer(unsigned(regcod1)));
                    Done <= '1';
                    next_state <= FETCH;

                when MOV2 =>
                    -- Load immediate value into register
                    registers(to_integer(unsigned(regcod1))) <= valor;
                    Buss_internal <= valor;
                    Buss <= Buss_internal;
                    Done <= '1';
                    next_state <= FETCH;

                when ADD =>
                    -- Add registers and store result
                    registers(to_integer(unsigned(regcod1))) <= 
                        std_logic_vector(signed(registers(to_integer(unsigned(regcod1)))) +
                                         signed(registers(to_integer(unsigned(regcod2)))));
                    Buss <= registers(to_integer(unsigned(regcod1)));
                    Done <= '1';
                    next_state <= FETCH;

                when SUB =>
                    -- Subtract registers and store result
                    registers(to_integer(unsigned(regcod1))) <= 
                        std_logic_vector(signed(registers(to_integer(unsigned(regcod1)))) -
                                         signed(registers(to_integer(unsigned(regcod2)))));
                    Buss <= registers(to_integer(unsigned(regcod1)));
                    Done <= '1';
                    next_state <= FETCH;

                when others =>
                    next_state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;
