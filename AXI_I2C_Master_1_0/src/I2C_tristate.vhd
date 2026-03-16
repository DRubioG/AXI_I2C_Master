library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity I2C_tristate is
    port (
--! Señal de entrada de datos del I2C.
        SDA_I : in std_logic;
--! Señal de salida de datos del I2C.
        SDA_O : out std_logic;
--! Señal de triestado de datos del I2C.
        SDA_T : in std_logic;
--! Señal bidireccional de datos del I2C.
        SDA_IO : inout std_logic
        
    );
end entity;

architecture rtl of I2C_tristate is

begin

--! IOBUF: Input/Output Buffer
IOBUF_inst : IOBUF
  port map
  (
    O  => SDA_I, -- 1-bit output: Buffer output
    I  => SDA_O, -- 1-bit input: Buffer input
    IO => SDA_IO, -- 1-bit inout: Buffer inout (connect directly to top-level port)
    T  => SDA_T -- 1-bit input: 3-state enable input
  );


end architecture;