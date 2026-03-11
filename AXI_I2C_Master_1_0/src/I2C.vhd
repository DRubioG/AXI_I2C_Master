library ieee;
use ieee.std_logic_1164.all;
entity I2C is
  generic (
--! Reloj de la FPGA.
    G_FPGA_CLK : integer := 100_000_000;
--! Frecuencia del I2C.
    G_I2C_CLK  : integer := 400_000
  );
  port (
--! Reloj de este módulo.
    CLK_I   : in std_logic;
--! Reset de este módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
--! Habilitación de este módule. Activo a nivel alto.
    EN_I    : in std_logic;
    -- Control
--! Dirección del esclavo sobre el que se quiere escribir/leer.
    ADDRESS_I    : in std_logic_vector(6 downto 0);
--! Dato a escribir por I2C.
    WRITE_DATA_I : in std_logic_vector(7 downto 0);
--! Dato leído por I2C.
    READ_DATA_O  : out std_logic_vector(7 downto 0);
--! Indicador de escritura por I2C. Activo a nivel alto.
    WRITE_I      : in std_logic;
--! Indicador de lectura por I2C. Activa a nivel alto.
    READ_EN_I    : in std_logic;
--! Indicador de arranque del I2C. Activo a nivel alto.
    START_I      : in std_logic;
--! Número de datos a leer.
    SIZE_I : in std_logic_vector(4 downto 0);
--! Indicador de finalización de lectura I2C.
    STOP_I : in std_logic;
    -- I2C
--! Puerto de datos de I2C.
    SDA : inout std_logic;
--! Puerto de reloj de I2C.
    SCL : out std_logic
  );
end entity;

architecture rtl of I2C is

--! Señal de conexión de SDA de entrada con el buffer tri-estado.
  signal s_sda_i : std_logic;
--! Señal de conexión de SDA de salida con el buffer tri-estado.
  signal s_sda_o : std_logic;
--! Señal de conexión de SDA directiva con el buffer tri-estado.
  signal s_sda_t : std_logic;
--! Señal que conecta el dato leído por I2C con el controlador.
  signal s_read_data    : std_logic_vector(7 downto 0);
--! Señal que conecta que hay un dato nuevo con el controlador. Activa a nivel alto.
  signal s_read_data_ok : std_logic;
--! Dato que pasa del controlador al FIFO.
  signal s_data_fifo_in : std_logic_vector(7 downto 0);
  -- signal s_data_fifo_in_ok : std_logic;
--! Señal que indica que el FIFO está vacío. Activo a nivel alto.
  signal s_empty : std_logic;
--! Señal que indica que el FIFO está lleno. Activo a nivel alto.
  signal s_full : std_logic;
  

begin

  --! Este módulo instancia el bloque triestado para la señal SDA.
  --! Con este módulo se consigue pasar de tres señales a una.
  I2C_tristate_inst : entity work.I2C_tristate
    port map
    (
      SDA_I  => s_sda_o,
      SDA_O  => s_sda_i,
      SDA_T  => s_sda_t,
      SDA_IO => SDA
    );
  --! Este módulo instancia la interfaz I2C para comunicaciones como master.
  I2C_phy_inst : entity work.I2C_phy
    generic map(
      G_FPGA_CLK => G_FPGA_CLK,
      G_I2C_CLK  => G_I2C_CLK
    )
    port map
    (
      CLK_I          => CLK_I,
      RST_N_I        => RST_N_I,
      EN_I           => EN_I,
      ADDRESS_I      => ADDRESS_I,
      WRITE_DATA_I   => WRITE_DATA_I,
      READ_DATA_O    => s_read_data,
      READ_DATA_OK_O => s_read_data_ok,
      SIZE_I         => SIZE_I,
      READ_I         => READ_EN_I,
      WRITE_I        => WRITE_I,
      START_I        => START_I,
      STOP_I         => STOP_I,
      SDA_I          => s_sda_i,
      SDA_O          => s_sda_o,
      SDA_T          => s_sda_t,
      SCL_O          => SCL
    );

--! Este módulo instancia el controlador del bloque I2C.
  I2C_controller_inst : entity work.I2C_controller
    generic map(
      G_FPGA_CLK => G_FPGA_CLK,
      G_I2C_CLK  => G_I2C_CLK
    )
    port map
    (
      CLK_I          => CLK_I,
      RST_N_I        => RST_N_I,
      EN_I           => EN_I,
      READ_DATA_I    => s_read_data,
      READ_DATA_OK_I => s_read_data_ok,
      READ_DATA_O    => s_data_fifo_in,
      READ_DATA_OK_O => s_data_fifo_in_ok,
      EMPTY_I        => s_empty,
      FULL_I         => s_full
    );

--! Este es el FIFO que coge los datos que entran por el I2C hasta que son leídos.
  I2C_FIFO_inst : entity work.I2C_FIFO
    generic map(
      G_FIFO_WIDTH => 32
    )
    port map
    (
      CLK_I      => CLK_I,
      RST_N_I    => RST_N_I,
      EN_I       => EN_I,
      READ_EN_I  => READ_EN_I,
      WRITE_EN_I => s_data_fifo_in_ok,
      FULL_O     => s_full,
      EMPTY_O    => s_empty,
      DATA_I     => s_data_fifo_in,
      DATA_O     => READ_DATA_O
    );
    
end architecture;