
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_phy_tb is
end;

architecture bench of I2C_phy_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_FPGA_CLK : integer := 100_000_000;
  constant G_I2C_CLK : integer := 400_000;
  -- Ports
  signal CLK_I : std_logic := '0';
  signal RST_N_I : std_logic;
  signal EN_I : std_logic;
  signal ADDRESS_I : std_logic_vector(6 downto 0);
  signal WRITE_DATA_I : std_logic_vector(7 downto 0);
  signal READ_DATA_O : std_logic_vector(7 downto 0);
  signal READ_DATA_OK_O : std_logic;
  signal SIZE_I : std_logic_vector(7 downto 0);
  signal READ_I : std_logic;
  signal WRITE_I : std_logic;
  signal START_I : std_logic;
  signal STOP_I : std_logic;
  signal SDA_I : std_logic;
  signal SDA_O : std_logic;
  signal SDA_T : std_logic;
  signal SCL_O : std_logic;
begin

  I2C_phy_inst : entity work.I2C_phy
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
    READ_DATA_OK_O => READ_DATA_OK_O,
    SIZE_I => SIZE_I,
    READ_I => READ_I,
    WRITE_I => WRITE_I,
    START_I => START_I,
    STOP_I => STOP_I,
    SDA_I => SDA_I,
    SDA_O => SDA_O,
    SDA_T => SDA_T,
    SCL_O => SCL_O
  );

  CLK_I <= not CLK_I after clk_period/2;
RST_N_I <= '0', '1' after 50ns;
EN_I <= '1';


ADDRESS_I <= "0000001";

READ_I <= '0';
STOP_I <= '0';
SDA_I <= '0';
SIZE_I <= (0=>'1', others => '0');

WRITE_DATA_I <= x"A5";


process begin
  START_I <= '0';
  wait for 100ns;
  wait until rising_edge(CLK_I);
  START_I <= '1';
  wait until rising_edge(CLK_I);
  START_I <= '0';
  wait;
end process;


process begin
  WRITE_I <= '0';
  wait for 15us;
  wait until rising_edge(CLK_I);
  WRITE_I <= '1';
  wait until rising_edge(CLK_I);
  WRITE_I <= '0';
  wait;
end process;

end;