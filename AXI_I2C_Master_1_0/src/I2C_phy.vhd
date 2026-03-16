--! { signal: [
--!   { name: "SCL",        wave: "h0p.................1." },
--!   { name: "SDA",        wave: "1033333334566666666501", data: ["AD1", "AD2", "AD3", "AD4", "AD5", "AD6", "AD7", "R/W", "ACK", "D7", "D6", "D5", "D4", "D3", "D2", "D1", "D0", "ACK"], phase: 0.5},
--!   { name: "SDA",        wave: "7.3......456.......57.", data: ["Start", "Address", "R/W", "ACK", "Data", "ACK", "Stop"], phase: 0.5}
--! ]}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_phy is
    generic (
--! Frecuencia de reloj de la FPGA.
        G_FPGA_CLK : integer := 100_000_000;
--! Frecuencia de trabajo de I2C.
        G_I2C_CLK : integer := 400_000
    );
    port(
--! Reloj principal del modulo.
        CLK_I : in std_logic;
--! Reset del módulo. Activo a nivel bajo.
        RST_N_I : in std_logic;
--! Habilitación del modulo. Activo a nivel alto.
        EN_I : in std_logic;

-- Control
--! Direccion de escritura del modulo.
        ADDRESS_I : in std_logic_vector(6 downto 0);
--! Valor para escribir por I2C.
        WRITE_DATA_I : in std_logic_vector(7 downto 0);
--! Valor leído por I2C.
        READ_DATA_O : out std_logic_vector(7 downto 0);
--! Indicador de nuevo valor en el puerto *READ_DATA_O*.
        READ_DATA_OK_O : out std_logic;
--! Tamaño de datos a leer por I2C.
        SIZE_I : in std_logic_vector(7 downto 0);
--! Orden de lectura del módulo, si se recibe esta señal, el módulo controrá tantas veces como ponga
--! en el puerto *SIZE_I*. Activo a nivel alto.
        READ_I : in std_logic;
--! Orden de escritura del módulo, la activación de esta señal solo transmite un dato.
--! Activo a nivel alto.
        WRITE_I : in std_logic;
--! Señal que indica el comienzo del módulo, cuando se activa se envía el address
--! del módulo. Activa a nivel alto.
        START_I : in std_logic;
--! Señal que indica la finalización de la comunicación. Activa a nivel alto.
        STOP_I : in std_logic;
--! Este puerto indica que el I2C ha encontrado un error. Activo a nivel alto.
        ERROR_O : out std_logic;
--! Este puerto indica si el I2C está disponible para transmitir. Activo a nivel alto.
        READY_O : out std_logic;

-- I2C
--! Puerto de entrada de datos por I2C.
        SDA_I : in std_logic;
--! Puerto de salida de datos por I2C.
        SDA_O : out std_logic;
--! Puerto triestado de datos por I2C.
        SDA_T : out std_logic;
--! Puerto de reloj por I2C.
        SCL_O : out std_logic
    );
end entity;

architecture rtl of I2C_phy is

--! Estados de la máquina de estados.
type fsm is (
--! Estado de espera para comezar a transmitir datos de I2C.
    SM_IDLE,
--! Estado de comienzo de escritura de datos.
    SM_START,
--! Estado de espera para hacer la caída de flanco del SCL.
    SM_FALLING_SCL,
--! Estado de escritura de la dirección del esclavo.
    SM_ADDRESS,
--! Estado del bit de escritura/lectura.
    SM_RW,
--! Estado de lectura por I2C.
    SM_READ_DATA,
--! Estado de escritura por I2C.
    SM_WRITE_DATA,
--! Estado de lectura del ACK del I2C.
    SM_ACK_SLAVE,
--! Estado de escritura del ACK del maestro por I2C.
    SM_ACK_MASTER,
--! Estado de espera para nueva orden por I2C.
    SM_WAIT_ORDER,
--! Estado de espera entre que sube la línea SCL y la línea SDA.
    SM_WAIT_STOP,
--! Estado de transmisión de STOP del I2C.
    SM_STOP,
--! Estado de error.
    SM_ERROR
);
--! Registro de control de la máquina de estados.
signal re_state : fsm;

--! Valor del número de bits de la dirección de I2C.
constant C_ADDRESS : integer := 7;
--! Contador del número de bits de la dirección de I2C.
signal r_cont_address : integer range 0 to C_ADDRESS;
--! Señal indicadora de flancos de subida del reloj SCL.
signal s_falling_edge : std_logic;
--! Señal indicadora de flancos de bajada del reloj SCL.
signal s_rising_edge : std_logic;
--! Señal auxiliar para el puerto SCL.
signal s_scl : std_logic;
--! Número de bits que se transmiten y reciben por I2C.
constant C_DATA_WIDTH : integer := 8;
--! Contador del número de bits de escritura por I2C.
signal r_cont_write_data    : integer range 0 to C_DATA_WIDTH;
--! Contador del númbre de bits de lectura por I2C.
signal r_cont_read_data     : integer range 0 to C_DATA_WIDTH;
--! Contador de número de datos leídos por I2C.
signal r_cont_num_read : integer range 0 to 31;
--! Constante con el valor del bit de escritura/lectura para lectura por I2C.
constant C_READ : std_logic := '1';
--! Constante con el valor del bit de escritura/lectura para escritura por I2C.
constant C_WRITE : std_logic := not C_READ;
--! Registro auxiliar para el desplazammiento a izquierdas de la dirección del esclavo.
signal r_address : std_logic_vector(C_ADDRESS-1 downto 0);
--! Registro auxiliar para el desplazammiento a izquierdas del valor a escribir al esclavo.
signal r_write_data : std_logic_vector(C_DATA_WIDTH-1 downto 0);
--! Registro auxiliar para el desplazammiento a izquierdas del valor a leer del esclavo.
signal r_read_data : std_logic_vector(C_DATA_WIDTH-1 downto 0);

--! Constante con el valor de triestado para escribir.
constant C_SDA_WRITE : std_logic := '0';
--! Constante con el valor de triestado para leer.
constant C_SDA_READ : std_logic := not C_SDA_WRITE;

--! Constante con el número de ciclos para generar un periodo del I2C.
constant C_PULSES_I2C : integer := G_FPGA_CLK/G_I2C_CLK;
--! Constante con el número de ciclos para un semiperiodo.
constant C_I2C_SEM_PERIOD : integer := C_PULSES_I2C/2;
--! Contador de semiperiodo para generar el I2C.
signal r_cont_i2c : integer range 0 to C_PULSES_I2C;
--! Número de ciclos de reloj desde que se baja la señal SDA y hasta que se baja la señal
--! SCL. Esto indica el comienzo de la comunicación por I2C.
constant C_START : integer := C_I2C_SEM_PERIOD;
--! Contador del número de ciclos de reloj para bajar la señal SCL.
signal r_cont_start : integer range 0 to C_START;
--! Contador del número de ciclos de reloj para bajar la señal SCL.
signal r_cont_wait_stop : integer range 0 to C_START;
--! Contador del número de ciclos de reloj para bajar la señal SCL.
signal r_cont_stop : integer range 0 to C_START;
--! Señal de entrada de inicio en un ciclo de reloj a nivel alto.
signal s_start : std_logic;
--! Señal de entrada de finalización de duración un ciclo de reloj a nivel alto.
signal s_stop : std_logic;


begin


--! @brief Detector de flancos de la señal de arranque.
--!
--! Este detector de flancos evita que la señal esté activa más de un ciclo de reloj.
start_edge_detector_inst : entity work.edge_detector
  port map (
    CLK_I => CLK_I,
    INPUT_SIGNAL_I => START_I,
    RISING_EDGE_O => s_start,
    FALLING_EDGE_O => open,
    EDGES_O => open
  );




--! @brief Detector de flancos de la señal de finalización.
--!
--! Este detector de flancos evita que la señal esté activa más de un ciclo de reloj.
stop_edge_detector_inst : entity work.edge_detector
  port map (
    CLK_I => CLK_I,
    INPUT_SIGNAL_I => STOP_I,
    RISING_EDGE_O => s_stop,
    FALLING_EDGE_O => open,
    EDGES_O => open
  );


--! @brief Este process contiene el comportamiento de este módulo.
FSM_PROCESS : process(CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            re_state <= SM_IDLE;

        elsif EN_I = '1' then
            case re_state is
                when SM_IDLE =>
                    re_state <= SM_IDLE;
                    if s_start = '1' then
                        re_state <= SM_START;
                    end if;

                when SM_START =>
                    re_state <= SM_START;
                    if r_cont_start >= C_START-1 then
                        re_state <= SM_FALLING_SCL;
                    end if;

                when SM_FALLING_SCL =>
                    re_state <= SM_FALLING_SCL;
                    if s_falling_edge = '1' then
                        re_state <= SM_ADDRESS;
                    end if;

                when SM_ADDRESS =>
                    re_state <= SM_ADDRESS;
                    if r_cont_address >= 7 then
                        re_state <= SM_RW;
                    end if;

                when SM_RW =>
                    re_state <= SM_RW;
                    if s_falling_edge = '1' then
                        re_state <= SM_ACK_SLAVE;
                    end if;

                when SM_ACK_SLAVE =>
                    re_state <= SM_ACK_SLAVE;
                    if s_falling_edge = '1' then
                        re_state <= SM_STOP;
                        if SDA_I = '0' then
                            re_state <= SM_WAIT_ORDER;
                        end if;
                    end if;



                when SM_WRITE_DATA =>
                    re_state <= SM_WRITE_DATA;
                    if r_cont_write_data >= C_DATA_WIDTH then
                        re_state <= SM_ACK_SLAVE;
                    end if;

                when SM_READ_DATA =>
                    re_state <= SM_READ_DATA;
                    if r_cont_read_data >= C_DATA_WIDTH then
                        re_state <= SM_ACK_MASTER;
                    end if;

                when SM_ACK_MASTER =>
                    re_state <= SM_ACK_MASTER;
                    if s_falling_edge = '1' then
                        re_state <= SM_READ_DATA;
                        if r_cont_num_read >= to_integer(unsigned(SIZE_I)) then
                            re_state <= SM_STOP;
                        end if;
                    end if;

                when SM_WAIT_ORDER =>
                    re_state <= SM_WAIT_ORDER;
                    if STOP_I = '1' then
                        re_state <= SM_WAIT_STOP;
                    elsif READ_I = '1' then
                        re_state <= SM_READ_DATA;
                    elsif WRITE_I = '1' then
                        re_state <= SM_WRITE_DATA;
                    end if;

                when SM_WAIT_STOP =>
                    re_state <= SM_WAIT_STOP;
                    if r_cont_wait_stop >= C_START-1 then
                        re_state <= SM_STOP;
                    end if;


                when SM_STOP =>
                    re_state <= SM_STOP;
                    if r_cont_stop >= C_START-1 then
                        re_state <= SM_IDLE;
                    end if;

                when SM_ERROR =>
                    
                    
                when others =>
                    re_state <= SM_IDLE;
            end case;
        end if;
    end if;
end process;

--! @brief Este es el detector de flancos del reloj generado.
scl_edge_detector_inst : entity work.edge_detector
  port map (
    CLK_I => CLK_I,
    INPUT_SIGNAL_I => s_scl,
    RISING_EDGE_O => s_rising_edge,
    FALLING_EDGE_O => s_falling_edge,
    EDGES_O => open
  );

--! @brief Asignación del reloj SCL
SCL_ASSIGN : SCL_O <= s_scl;


--! @brief Este process genera el reloj del
SCL_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            s_scl <= '1';
        elsif EN_I = '1' then
            if re_state = SM_FALLING_SCL then
                s_scl <= '0';
            elsif re_state = SM_ADDRESS or re_state = SM_RW or re_state = SM_ACK_SLAVE or re_state = SM_WRITE_DATA or re_state = SM_READ_DATA or re_state = SM_ACK_MASTER then
                if r_cont_i2c >= C_I2C_SEM_PERIOD-1 then
                    s_scl <= not s_scl;
                end if;
            elsif re_state = SM_WAIT_ORDER then
                s_scl <= '0';
            else
                s_scl <= '1';
            end if;
        end if;
    end if;
end process;

--! @brief Este process genera el contador del semiperiodo del reloj SCL.
CONT_SCL_COUNTER : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_i2c <= 0;
        elsif EN_I = '1' then
            r_cont_i2c <= 0;
            if re_state = SM_ADDRESS or re_state = SM_RW or re_state = SM_ACK_MASTER or re_state = SM_ACK_SLAVE or re_state = SM_WRITE_DATA or re_state = SM_READ_DATA  then
                r_cont_i2c <= r_cont_i2c+1;
                if r_cont_i2c >= C_I2C_SEM_PERIOD-1 then
                    r_cont_i2c <= 0;
                end if;
            end if;
        end if;
    end if;
end process;






--! @brief Este process genera la señal de salida por el puerto de salida SDA_O.
SDA_O_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            SDA_O <= '1';
        elsif EN_I = '1' then
            SDA_O <= '0';
            if re_state = SM_IDLE then
                SDA_O <= '1';
            elsif re_state = SM_START then
                SDA_O <= '0';
            elsif re_state = SM_ADDRESS then
                SDA_O <= r_address(C_ADDRESS-1);
            elsif re_state = SM_RW then
                if READ_I = '1' then
                    SDA_O <= C_READ;
                elsif WRITE_I = '1' then
                    SDA_O <= C_WRITE;
                end if;
            elsif re_state = SM_WAIT_ORDER then
                SDA_O <= '0';
            elsif re_state = SM_WRITE_DATA then
                SDA_O <= r_write_data(C_DATA_WIDTH-1);
            elsif re_state = SM_READ_DATA then
                SDA_O <= '0';
            elsif re_state = SM_STOP then
                SDA_O <= '1';
            end if;
        end if;
    end if;
end process;


--! @brief Este process hace el desplazamiento a izquierdas del valor de la dirección
--! del esclavo.
ADDRESS_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_address <= (others => '0') ;
        elsif EN_I = '1' then
            if re_state = SM_START then
                r_address <= ADDRESS_I;
            elsif re_state = SM_ADDRESS then
                if s_falling_edge = '1' then
                    r_address <= r_address(C_ADDRESS-2 downto 0) & r_address(0);
                end if;
            end if;
        end if;
    end if;
end process;


--! @brief Este process hace el desplazamiento a izquierdas del valor de escritura
--! al esclavo.
WRITE_DATA : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_write_data <= (others => '0');
        elsif EN_I = '1' then
            if re_state = SM_WAIT_ORDER then
                r_write_data <= WRITE_DATA_I;
            elsif re_state = SM_WRITE_DATA then
                if s_falling_edge = '1' then
                    r_write_data <= r_write_data(C_DATA_WIDTH-2 downto 0) & r_write_data(0);
                end if;
            end if;
        end if;
    end if;
end process;


--! @brief Valor de asignación del dato leído al puerto de lectura.
READ_DATA_O_ASSIGN : READ_DATA_O <= r_read_data;


--! @brief Este process lee el dato que transmite el esclavo.
--!
--! Para esta tarea se realiza un desplazamiento a izquierdas del valor.
READ_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_read_data <= (others => '0') ;
        elsif EN_I = '1' then
            if re_state = SM_READ_DATA then
                if s_rising_edge = '1' then
                    r_read_data <= r_read_data(C_DATA_WIDTH-2 downto 0) & SDA_I;
                end if;
            else
                r_read_data <= (others => '0');
            end if;
        end if;
    end if;
end process;


--! @brief Este process pone la señal triestado al valor que le corresponde para 
--! lectura o escritura.
SDA_T_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            SDA_T <= C_SDA_WRITE;
        elsif EN_I = '1' then
            SDA_T <= C_SDA_WRITE;
            if re_state = SM_ACK_SLAVE or re_state = SM_READ_DATA then
                SDA_T <= C_SDA_READ;
            end if;
        end if;
    end if;
end process;



-- TEMPORIZACIONES

--! @brief Este es el contador de ciclos de reloj previos para bajar la señal SCL.
START_COUNTER : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_start <= 0;
        elsif EN_I = '1' then
            r_cont_start <= 0;
            if re_state = SM_START then
                r_cont_start <= r_cont_start+1;
            end if;
        end if;
    end if;
end process;


--! @brief Este es el contador de número de bits de dirección del esclavo.
process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_address <= 0;
        elsif EN_I = '1' then
            if re_state = SM_ADDRESS then
                if s_falling_edge = '1' then
                    r_cont_address <= r_cont_address+1;
                end if;
            else
                r_cont_address <= 0;
            end if;
        end if;
    end if;
end process;


--! @brief Este es un contador de flancos de bajada durante la 
--! escritura de datos.
CONTADOR_FLANCOS_ESCRITURA : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_write_data <= 0;
        elsif EN_I = '1' then
            if re_state = SM_WRITE_DATA then
                if s_falling_edge = '1' then
                    r_cont_write_data <= r_cont_write_data+1;
                end if;
            else
                r_cont_write_data <= 0;
            end if;
        end if;
    end if;
end process;


--! @brief Este es un contador de flancos de bajada durante la
--! lectura de datos.
CONTADOR_FLANCOS_LECTURA : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_read_data <= 0;
        elsif EN_I = '1' then
            if re_state = SM_READ_DATA then
                if s_falling_edge = '1' then
                    r_cont_read_data <= r_cont_read_data+1;
                end if;
            else
                r_cont_read_data <= 0;
            end if;
        end if;
    end if;
end process;

--! @brief Este es un indicador de lectura de datos.
INDICADOR_DATO_LEIDO : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            READ_DATA_OK_O <= '0';
        elsif EN_I = '1' then
            READ_DATA_OK_O <= '0';
            if re_state = SM_ACK_MASTER then
                if s_falling_edge = '1' then
                    READ_DATA_OK_O <= '1';
                end if;
            end if;
        end if;
    end if;
end process;


--! @brief Este es el contador de tiempos entre que la línea de SCL sube y la 
--! línea SDA.
TIEMPO_ESPERA : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_wait_stop <= 0;
        elsif EN_I = '1' then
            r_cont_wait_stop <= 0;
            if re_state = SM_WAIT_STOP then
                r_cont_wait_stop <= r_cont_wait_stop +1;
            end if;
        end if;
    end if;
end process;


--! @brief Este es el contador previo a reiniciar el funcionamiento.
TIEMPO_ANTES_REINICIO : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_stop <= 0;
        elsif EN_I = '1' then
            r_cont_stop <= 0;
            if re_state = SM_STOP then
                r_cont_stop <= r_cont_stop +1;
            end if;
        end if;
    end if;
end process;


--! @brief Este es el contador de número de bytes leídos por I2C.
READ_COUNTER : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            r_cont_num_read <= 0;
        elsif EN_I = '1' then
            if re_state = SM_STOP then
                r_cont_num_read <= 0;
            elsif re_state = SM_ACK_MASTER then
                if s_falling_edge = '1' then
                    r_cont_num_read <= r_cont_num_read +1;
                end if;
            end if;
        end if;
    end if;
end process;



--! @brief Este process actualiza el valor del puerto SM_IDLE.
--!
--! Este puerto indica si el I2C está disponible para escribir. Para  leer 
--! este puerto está siempre a '0', debido a que la lectura es continua.
READY_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            READY_O <= '0';
        elsif EN_I = '1' then
            READY_O <= '0';
            if re_state = SM_WAIT_ORDER or re_state = SM_IDLE then
                READY_O <= '1';
            end if;
        end if;
    end if;
end process;



--! @brief Este puerto indica si ha habido un error en la comunicación del I2C.
ERROR_PROCESS : process (CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            ERROR_O <= '0';
        elsif EN_I = '1' then
            ERROR_O <= '0';
            if re_state = SM_ERROR then
                ERROR_O <= '1';
            end if;
        end if;
    end if;
end process;

end architecture;