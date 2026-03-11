--! { signal: [
--!   { name: "SCL",        wave: "h0p.................1." },
--!   { name: "SDA",        wave: "1033333334566666666501", data: ["AD1", "AD2", "AD3", "AD4", "AD5", "AD6", "AD7", "R/W", "ACK", "D7", "D6", "D5", "D4", "D3", "D2", "D1", "D0", "ACK"], phase: 0.5},
--!   { name: "SDA",        wave: "7.3......456.......57.", data: ["Start", "Address", "R/W", "ACK", "Data", "ACK", "Stop"], phase: 0.5}
--! ]}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_controller is
  generic (
    G_FPGA_CLK : integer := 100_000_000;
    G_I2C_CLK  : integer := 400_000
  );
  port (
    --! Reloj principal del modulo.
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del modulo. Activo a nivel alto.
    EN_I : in std_logic;

    -- I2C PHY

    READ_DATA_I    : in std_logic_vector(7 downto 0);
    READ_DATA_OK_I : in std_logic;
    READ_DATA_O    : out std_logic_vector(7 downto 0);
    READ_DATA_OK_O : out std_logic;

    -- I2C FIFO
    EMPTY_I : in std_logic;
    FULL_I  : in std_logic

  );
end entity;

architecture artl of I2C_controller is

begin

  READ_DATA_O <= READ_DATA_I;
end architecture;