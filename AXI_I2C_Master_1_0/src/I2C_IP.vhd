library ieee;
use ieee.std_logic_1164.all;

entity I2C_IP is
    port(
        CLK_I : in std_logic;
        RST_N_I : in std_logic;
        EN_I : in std_logic;
        ADDRESS_I : in std_logic_vector(7 downto 0);
        WRITE_DATA_I : in std_logic_vector(7 downto 0);
        READ_DATA_O : out std_logic_vector(7 downto 0);
        READ_I : in std_logic;
        START_I : in std_logic;
        FIFO_UPDATE_I : in std_logic;
        STOP_I : in std_logic;
        SIZE_I : in std_logic_vector(7 downto 0);
		    IRQ : out std_logic;
        SDA : inout std_logic;
        SCL : out std_logic
    );
end entity;

architecture rtl of I2C_IP is 

begin


I2C_IP_controller_inst : entity work.I2C_IP_controller
  port map (
    CLK_I => CLK_I,
    RST_N_I => RST_N_I,
    EN_I => EN_I
  );





I2C_inst : entity work.I2C
  port map (
    CLK_I => CLK_I,
    RST_N_I => RST_N_I,
    EN_I => EN_I,
    ADDR_I => ADDRESS_I,
    WR_DATA_I => WRITE_DATA_I,
    RD_DATA_O => READ_DATA_O,
    READ_I => READ_I,
    START_I => START_I,
    SDA => SDA,
    SCL => SCL
  );





end architecture;