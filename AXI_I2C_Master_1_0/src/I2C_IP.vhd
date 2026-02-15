library ieee;
use ieee.std_logic_1164.all;

entity I2C_IP is
    port(
        CLK_I : in std_logic;
        RST_N_I : in std_logic;
        EN_I : in std_logic;
        
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
    ADDR_I => ADDR_I,
    WR_DATA_I => WR_DATA_I,
    RD_DATA_O => RD_DATA_O,
    READ_I => READ_I,
    START_I => START_I,
    SDA => SDA,
    SCL => SCL
  );





end architecture;