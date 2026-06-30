library ieee;
use ieee.std_logic_1164.all;

entity I2C is
  generic (
    --! Reloj de la FPGA.
    G_FPGA_CLK : integer := 100_000_000;
    --! Frecuencia del I2C.
    G_I2C_CLK : integer := 400_000
  );
  port (
    --! Reloj de este módulo.
    CLK_I : in std_logic;
    --! Reset de este módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación de este módule. Activo a nivel alto.
    EN_I : in std_logic;

    -- Control
    --! Dirección del esclavo sobre el que se quiere escribir/leer.
    ADDRESS_I : in std_logic_vector(6 downto 0);
    --! Dato a escribir por I2C.
    WRITE_DATA_I : in std_logic_vector(7 downto 0);
    --! Dato leído por I2C.
    DATA_O : out std_logic_vector(7 downto 0);
    --! Indicador de escritura por I2C. Activo a nivel alto.
    WRITE_I : in std_logic;
    --! Indicador de lectura por I2C. Activa a nivel alto.
    READ_I : in std_logic;
    --! Indicador para la lectura por I2C de datos del FIFO. Activo a nivel alto.
    READ_EN_I : in std_logic;
    --! Indicador de arranque del I2C. Activo a nivel alto.
    START_I : in std_logic;
    --! Número de datos a leer.
    READ_SIZE_I : in std_logic_vector(4 downto 0);
    --! Este puerto indica que el I2C ha encontrado un error. Activo a nivel alto.
    ERROR_O : out std_logic;
    --! Este puerto indica si el I2C está disponible para transmitir. Activo a nivel alto.
    READY_O : out std_logic;
    --! Indicador de finalización de lectura I2C.
    WRITE_STOP_I : in std_logic;

    -- I2C
    --! Puerto de datos de I2C.
    SDA_T : out std_logic;
    SDA_I : in std_logic;
    SDA_O : out std_logic;
    --! Puerto de reloj de I2C.
    SCL : out std_logic
  );
end entity;

architecture rtl of I2C is

  --! Señal que conecta el dato leído por I2C con el controlador.
  signal s_read_data : std_logic_vector(7 downto 0);
  --! Señal que conecta que hay un dato nuevo con el controlador. Activa a nivel alto.
  signal s_read_data_ok : std_logic;
  --! Dato que pasa del controlador al FIFO.
  signal s_data_fifo_in : std_logic_vector(7 downto 0);

  --! Señal que indica que el FIFO está lleno. Activo a nivel alto.
  signal s_full : std_logic;
  --! Esta señal manda la orden de escritura al FIFO.
  signal s_write_fifo_en : std_logic;
  --! Señal de reseteo del FIFO.
  signal s_reset_fifo : std_logic;

begin

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
      READ_SIZE_I    => READ_SIZE_I,
      READ_I         => READ_I,
      WRITE_I        => WRITE_I,
      START_I        => START_I,
      WRITE_STOP_I   => WRITE_STOP_I,
      ERROR_O        => ERROR_O,
      READY_O        => READY_O,
      SDA_I          => SDA_I,
      SDA_O          => SDA_O,
      SDA_T          => SDA_T,
      SCL_O          => SCL
    );

  --! Este módulo instancia el controlador del bloque I2C.
  I2C_controller_inst : entity work.I2C_controller
    port map
    (
      CLK_I                => CLK_I,
      RST_N_I              => RST_N_I,
      EN_I                 => EN_I,
      READ_DATA_I          => s_read_data,
      READ_DATA_OK_I       => s_read_data_ok,
      WRITE_DATA_FIFO_O    => s_data_fifo_in,
      WRITE_DATA_FIFO_OK_O => s_write_fifo_en,
      FULL_I               => s_full
    );

  --! @brief En esta parte se genera el reset del FIFO para evitar que guarde datos
  --! para nuevas iteraciones del I2C.
  --!
  --! Para este reset se aprovecha de que la señal de arranque 
  FIFO_RESET_GENERATOR : s_reset_fifo <= not START_I and RST_N_I;

  --! Este es el FIFO que coge los datos que entran por el I2C hasta que son leídos.
  --! Si se recibe la orden de iniciar y el FIFO no ha sido leído, se borra.
  I2C_FIFO_inst : entity work.I2C_FIFO
    generic map(
      G_FIFO_WIDTH => 32
    )
    port map
    (
      CLK_I      => CLK_I,
      RST_N_I    => s_reset_fifo,
      EN_I       => EN_I,
      READ_EN_I  => READ_EN_I,
      WRITE_EN_I => s_write_fifo_en,
      FULL_O     => s_full,
      EMPTY_O    => open,
      DATA_I     => s_data_fifo_in,
      DATA_O     => DATA_O
    );

end architecture;