from cocotb_test.simulator import run

run(
    toplevel="I2C",
    module="test_i2c",
    vhdl_sources=["../../code/src/edge_detector.vhd",
                  "../../code/src/I2C_phy.vhd",
                  "../../code/src/I2C_controller.vhd",
                  "../../code/src/I2C_FIFO.vhd",
                  "../../code/src/I2C.vhd"
                  ],
    sim_args=["--dump-arrays"],
    toplevel_lang="vhdl",
    simulator="nvc",
    waves=True           
)
