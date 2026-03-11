library ieee;
use ieee.std_logic_1164.all;

entity I2C_IP is
    generic (
        G_FPGA_CLK : integer := 100_000_000;
        G_I2C_CLK : integer := 400_000
    );
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
    EN_I => EN_I,
    FIFO_UPDATE_I => FIFO_UPDATE_I,
    IRQ_O => IRQ
  );




I2C_inst : entity work.I2C
  generic map (
    G_FPGA_CLK => G_FPGA_CLK,
    G_I2C_CLK => G_I2C_CLK
  )
  port map (
    CLK_I => CLK_I,
    RST_N_I => RST_N_I,
    EN_I => EN_I,
    ADDRESS_I => ADDRESS_I,
    WRITE_DATA_I => WRITE_DATA_I,
    READ_DATA_O => READ_DATA_O,
    WRITE_I => ,
    READ_EN_I => READ_I,
    START_I => START_I,
    SIZE_I => SIZE_I,
    STOP_I => STOP_I,
    SDA => SDA,
    SCL => SCL
  );





end architecture;