library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity I2C is
  port (
    CLK_I   : in std_logic;
    RST_N_I : in std_logic;
    EN_I    : in std_logic;
    -- Control

    ADDR_I    : in std_logic_vector(6 downto 0);
    WR_DATA_I : in std_logic_vector(7 downto 0);
    RD_DATA_O : out std_logic_vector(7 downto 0);
    READ_I    : in std_logic;
    START_I   : in std_logic;
    -- I2C
    SDA : in std_logic;
    SCL : out std_logic
  );
end entity;

architecture rtl of I2C is

  signal s_sda_i : std_logic;
  signal s_sda_o : std_logic;
  signal s_sda_t : std_logic;
begin

--! IOBUF: Input/Output Buffer
IOBUF_inst : IOBUF
  port map
  (
    O  => s_sda_i, -- 1-bit output: Buffer output
    I  => s_sda_o, -- 1-bit input: Buffer input
    IO => SDA, -- 1-bit inout: Buffer inout (connect directly to top-level port)
    T  => s_sda_t -- 1-bit input: 3-state enable input
  );

  


  I2C_inst : entity work.I2C_controller
    port map
    (
      CLK_I     => CLK_I,
      RST_N_I   => RST_N_I,
      EN_I      => EN_I,
      ADDR_I    => ADDR_I,
      WR_DATA_I => WR_DATA_I,
      RD_DATA_O =>,
      READ_I  => READ_I,
      START_I => START_I,
      SDA_I   => s_sda_i,
      SDA_O   => s_sda_o,
      SDA_T   => s_sda_t,
      SCL_O   => SCL
    );

  I2C_FIFO_inst : entity work.I2C_FIFO
    generic map(
      G_FIFO_WIDTH => 32
    )
    port map
    (
      CLK_I     => CLK_I,
      RST_N_I   => RST_N_I,
      EN_I      => EN_I,
      READ_I    => READ_I,
      FULL_O    => FULL_O,
      EMPTY_O   => EMPTY_O,
      DATA_I    => RD_DATA_O,
      DATA_OK_I => DATA_OK_I,
      DATA_O    => DATA_O,
      DATA_OK_O => DATA_OK_O
    );

end architecture;