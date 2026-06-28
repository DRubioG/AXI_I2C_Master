# files
nvc -a ../../code/src/edge_detector.vhd
nvc -a ../../code/src/I2C_phy.vhd
nvc -a ../../code/src/I2C_controller.vhd
nvc -a ../../code/src/I2C_FIFO.vhd 
nvc -a ../../code/src/I2C.vhd


# testbenchs
nvc -a ../../code/testbench/I2C_tb.vhd

# elaborate
nvc -e I2C_tb

# Simulate
nvc -r I2C_tb --stop-time=550us --wave=I2C_tb.vcd --dump-arrays #--stats 