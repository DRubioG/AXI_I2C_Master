library ieee;
use ieee.std_logic_1164.all;

entity I2C_FIFO is
    generic(
        G_FIFO_WIDTH : integer := 32
    );
    port(
        CLK_I : in std_logic;
        RST_N_I : in std_logic;
        EN_I : in std_logic;
        READ_I : in std_logic;
        FULL_O : out std_logic;
        EMPTY_O : out std_logic;
        DATA_I : in std_logic_vector(7 downto 0);
        DATA_OK_I : in std_logic;
        DATA_O : out std_logic_vector(7 downto 0);
        DATA_OK_O : out std_logic
    );
end entity;

architecture rtl of I2C_FIFO is

constant C_WIDTH : integer := 7;

type t_fifo is array(0 to G_FIFO_WIDTH-1) of std_logic_vector(C_WIDTH-1 downto 0);

signal r_fifo_rom : t_fifo;

begin

end architecture;