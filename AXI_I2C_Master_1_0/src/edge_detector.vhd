library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port (
        CLK_I : in std_logic;
        INPUT_SIGNAL_I : in std_logic;
        RISING_EDGE_O : out std_logic;
        FALLING_EDGE_O : out std_logic;
        EDGES_O : out std_logic
    );
end entity edge_detector;

architecture rtl of edge_detector is

signal s_input_delay : std_logic;

begin

process (CLK_I)
begin
    if rising_edge(CLK_I) then
        s_input_delay <= INPUT_SIGNAL_I;
    end if;
end process;

RISING_EDGE_O <= not s_input_delay and INPUT_SIGNAL_I;

FALLING_EDGE_O <= s_input_delay and not INPUT_SIGNAL_I;

EDGES_O <= s_input_delay xor INPUT_SIGNAL_I;

end architecture;