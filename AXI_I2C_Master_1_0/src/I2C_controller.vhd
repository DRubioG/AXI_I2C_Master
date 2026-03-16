--! { signal: [
--!   { name: "SCL",        wave: "h0p.................1." },
--!   { name: "SDA",        wave: "1033333334566666666501", data: ["AD1", "AD2", "AD3", "AD4", "AD5", "AD6", "AD7", "R/W", "ACK", "D7", "D6", "D5", "D4", "D3", "D2", "D1", "D0", "ACK"], phase: 0.5},
--!   { name: "SDA",        wave: "7.3......456.......57.", data: ["Start", "Address", "R/W", "ACK", "Data", "ACK", "Stop"], phase: 0.5}
--! ]}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_controller is
  port (
    --! Reloj principal del modulo.
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del modulo. Activo a nivel alto.
    EN_I : in std_logic;

-- I2C PHY
--! Este es el valor leído por I2C.
    READ_DATA_I    : in std_logic_vector(7 downto 0);
--! Este es el indicador de nuevo dato leído. Activo a nivel alto.
    READ_DATA_OK_I : in std_logic;


-- I2C FIFO
--! Este es el dato a escribir en el FIFO.
    WRITE_DATA_FIFO_O    : out std_logic_vector(7 downto 0);
--! Este es el indicador de escritura en el FIFO. Activo a nivel alto.
    WRITE_DATA_FIFO_OK_O : out std_logic;
--! Este es el indicador del FIFO de que está lleno. Activo a nivel alto.
    FULL_I  : in std_logic

  );
end entity;

architecture artl of I2C_controller is

--! Esta es la máquina de estados del módulo.
type fsm is (
--! Este es el estado de espera a que el I2C lea un nuevo dato.
  SM_IDLE,
--! Este estado comprueba que el FIFO no esté lleno.
  SM_WAIT_FULL,
--! Este estado manda la orden de escritura al FIFO.
  SM_WRITE_DATA
);
--! Este registro es el estado actual de la máquina de estados.
signal re_state : fsm;  
--! Este registro guarda el valor de la entrada hasta que se escribe en el FIFO.
signal r_write_data : std_logic_vector(WRITE_DATA_FIFO_O'length);


begin


--! Asignación del valor del registro al puerto de salida.
DATA_ASSIGN : WRITE_DATA_FIFO_O <= r_write_data;


--! Controlador de la máquina de estados.
FSM_PROCESS : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        re_state <= SM_IDLE;

      elsif EN_I = '1' then
        case re_state is
          when SM_IDLE =>
            re_state <= SM_IDLE;
            if READ_DATA_OK_I = '1' then
              re_state <= SM_WAIT_FULL;
            end if ;

          when SM_WAIT_FULL =>
            re_state <= SM_WAIT_FULL;
            if FULL_I = '0' then
              re_state <= SM_WRITE_DATA;
            end if;

          when SM_WRITE_DATA =>
            re_state <= SM_IDLE;
        
          when others =>
            re_state <= SM_IDLE;
        end case;
      end if;
    end if;
  end process;

--! Este process manda la señal de escritura al FIFO.
WRITE_OK : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        WRITE_DATA_FIFO_OK_O <= '0';
      elsif EN_I = '1' then
        WRITE_DATA_FIFO_OK_O <= '0';
        if re_state = SM_WRITE_DATA then
          WRITE_DATA_FIFO_OK_O <= '1';
        end if;
      end if;
    end if;
  end process;


--! Este process salva el valor a escribir para evitar conflictos. Para ello asigna el valor
--! del registro mientras espera a recibir el dato correcto.
SAVE_INPUT : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_write_data <= (others => '0');
      elsif EN_I = '1' then
        if re_state = SM_IDLE then
          r_write_data <= READ_DATA_I;
        end if;
      end if;
    end if;
  end process;

end architecture;