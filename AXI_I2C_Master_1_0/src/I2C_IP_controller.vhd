library ieee;
use ieee.std_logic_1164.all;

entity I2C_IP_controller is
    port(
        CLK_I : in std_logic;
        RST_N_I : in std_logic;
        EN_I : in std_logic;
        
    );
end entity;