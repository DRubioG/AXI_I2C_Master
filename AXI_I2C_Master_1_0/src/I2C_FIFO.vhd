library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_FIFO is
  generic (
--! Tamaño del FIFO.
    G_FIFO_WIDTH : integer := 32
  );
  port (
--! Reloj del módulo.
    CLK_I      : in std_logic;
--! Reset del módulo. Activo a nivel bajo.
    RST_N_I    : in std_logic;
--! Habilitación del módulo. Activo a nivel alto.
    EN_I       : in std_logic;
--! Indicador de lectura del FIFO. Activo a nivel alto.
    READ_EN_I  : in std_logic;
--! Indicador de escritura del FIFO. Activo a nivel alto.
    WRITE_EN_I : in std_logic;
--! Indicador de que el FIFO está lleno. Activo a nivel alto.
    FULL_O     : out std_logic;
--! Indicador de que el FIFO está vacío. Activo a nivel alto.
    EMPTY_O    : out std_logic;
--! Dato a grabar en el FIFO.
    DATA_I     : in std_logic_vector(7 downto 0);
--! Dato a leer del FIFO.
    DATA_O     : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of I2C_FIFO is
--! Tamaño del dato del FIFO.
  constant C_WIDTH : integer := 7;
--! Estructura de la memoria del FIFO.
  type t_fifo is array(0 to G_FIFO_WIDTH - 1) of std_logic_vector(C_WIDTH - 1 downto 0);
--! Memoria del FIFO.
  signal r_fifo_rom : t_fifo;
--! Contador de lectura del FIFO. Este registro cuenta cuántos datos se han
--! leído del FIFO.
  signal r_cont_read : integer range 0 to G_FIFO_WIDTH - 1;
--! Contador de escritura del FIFO. Este registro cuenta cuántos datos se
--! han esrito en el FIFO.
  signal r_cont_write : integer range 0 to G_FIFO_WIDTH - 1;
--! Este contado cuenta cuantos datos tiene el FIFO, después de leer y escribir
--! sobre el FIFO.
  signal r_diff : integer range 0 to G_FIFO_WIDTH;
begin


--! Este process controla el FIFO. Por eso tiene dos partes, una de lectura y
--! otra de escritura.
FIFO_PROCESS : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_cont_write <= 0;
        r_cont_read  <= 0;
        r_diff       <= 0;
        DATA_O       <= (others => '0');
        for i in 0 to G_FIFO_WIDTH - 1 loop
          r_fifo_rom <= (others => '0');
        end loop;

      elsif EN_I = '1' then

-- Escritura
        if WRITE_EN_I = '1' and r_diff < G_FIFO_WIDTH then
          r_fifo_rom(r_cont_write) <= DATA_I;

          if r_cont_write = G_FIFO_WIDTH - 1 then
            r_cont_write <= 0;
          else
            r_cont_write <= r_cont_write + 1;
          end if;

          r_diff <= r_diff + 1;
        end if;


-- Lectura
        if READ_EN_I = '1' and r_diff > 0 then
          DATA_O <= r_fifo_rom(r_cont_read);

          if r_cont_read = G_FIFO_WIDTH - 1 then
            r_cont_read <= 0;
          else
            r_cont_read <= r_cont_read + 1;
          end if;

          r_diff <= r_diff - 1;
        end if;
      end if;
    end if;
  end process;

--! Esta es la condición para generar la señal de FULL. Esta señal solo se genera
--! cuando el FIFO está completo.
FULL_CONDITION : FULL_O <= '1' when r_diff = G_FIFO_WIDTH else '0';

--! Esta es a condición para generar la señal de EMPTY. Esta señal solo se genera
--! cuando el FIFO está vacío.
EMPTY_CONDITION : EMPTY_O <= '1' when r_diff = 0 else '0';


end architecture;