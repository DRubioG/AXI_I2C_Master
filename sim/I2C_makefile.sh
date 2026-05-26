# files
nvc -a ../code/src/I2C_phy.vhd

# testbenchs
nvc -a ../code/src/I2C_phy_tb.vhd

# elaborate
nvc -e I2C_phy_tb

# Simulate
nvc -r I2C_phy_tb --stop-time=350us --wave=i2c.vcd