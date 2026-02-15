library ieee;
use ieee.std_logic_1164.all;

entity I2C_controller is
    port(
        CLK_I : in std_logic;
        RST_N_I : in std_logic;
        EN_I : in std_logic;
-- Control

        ADDR_I : in std_logic_vector(6 downto 0);
        WR_DATA_I : in std_logic_vector(7 downto 0);
        RD_DATA_O : out std_logic_vector(7 downto 0);
        READ_I : in std_logic;
        START_I : in std_logic;
        

-- I2C
        SDA_I : in std_logic;
        SDA_O : out std_logic;
        SDA_T : out std_logic;
        SCL_O : out std_logic
    );
end entity;

architecture rtl of I2C_controller is

type fsm is (
    SM_IDLE,
    SM_START,
    SM_ADDRESS,
    SM_WRITE,
    SM_READ,
    SM_READ_DATA,
    SM_WRITE_DATA,
    SM_ACK_SLAVE,
    SM_ACK_MASTER,
    SM_STOP
);

signal re_state : fsm;

begin


FSM : process(CLK_I)
begin
    if rising_edge(CLK_I) then
        if RST_N_I = '0' then
            re_state <= SM_IDLE;
        elsif EN_I = '1' then
            case re_state is
                when SM_IDLE =>
                    re_state <= SM_IDLE;

                when SM_START =>
                    re_state <= SM_START;


                when others =>
                    re_state <= SM_IDLE;
            end case;
        end if;
    end if;
end process;

end architecture;