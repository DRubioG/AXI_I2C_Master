import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
import random

class I2C_test:
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(dut.clk_i, 10, units="ns").start())
        cocotb.start_soon(self.reset(dut))
        self.init()

    async def reset(self, dut):
        dut.rst_n_i.value = 0
        await Timer(50, "ns")
        dut.rst_n_i.value = 1

    def init(self):
        self.dut.en_i.value = 1
        self.dut.address_i.value = BinaryValue("0110101")
        self.dut.read_en_i.value = 1
        self.dut.sda_i.value = 0
        self.dut.read_size_i.value = 4
        self.dut.write_data_i.value = 0xA5
        self.dut.stop_i.value = 0
        self.dut.start_i.value = 0
        self.dut.read_i.value = 0
        self.dut.write_i.value = 0




    
    async def delay(self, time=1):
        for _ in range(time):
            await RisingEdge(self.dut.clk_i)


    async def write_i2c(self, data, address):
        self.dut.address_i.value = address
        

        await RisingEdge(self.dut.clk_i)
        self.dut.start_i.value = 1
        await RisingEdge(self.dut.clk_i)
        self.dut.start_i.value = 0
        await self.delay(150)

        for i in data:
            # cocotb.start_soon(self.i2c_data(0xA5))

            self.dut.write_data_i.value = i


            await self.delay(150)
            while self.dut.ready_o.value != 1:
                await RisingEdge(self.dut.clk_i)
                
            await self.delay(150)

            self.dut.write_i.value = 1
            await RisingEdge(self.dut.clk_i)
            self.dut.write_i.value = 0



            await self.delay(150)
            while self.dut.ready_o.value != 1:
                await RisingEdge(self.dut.clk_i)
                
            await self.delay(150)


            await Timer(5, "us")



        await RisingEdge(self.dut.clk_i)
        self.dut.stop_i.value = 1
        await RisingEdge(self.dut.clk_i)
        self.dut.stop_i.value = 0
        await self.delay(150)



    async def send_i2c_data(self, data=0):
        # await RisingEdge(self.dut.clk_i)
        # wait master address
        for _ in range(9):
            
            await FallingEdge(self.dut.scl)

        await FallingEdge(self.dut.scl)
        # await RisingEdge(self.dut.scl)
        for _ in range(self.dut.read_size_i.value):
            for i in range(9):
                self.dut.sda_i.value = (((data<<i)&0x80)>>7)&0x1
                await FallingEdge(self.dut.scl)
            self.dut.sda_i.value = 0



    async def read_i2c(self, address, size=1, data_read=0x00):
        self.dut.address_i.value = address
        # self.dut.read_size_i.value = size
        # cocotb.start_soon(self.send_i2c_data(0x01))

        


        self.dut.read_i.value = 0
        await RisingEdge(self.dut.clk_i)
        self.dut.read_i.value = 1

        await RisingEdge(self.dut.clk_i)
        self.dut.start_i.value = 1
        await RisingEdge(self.dut.clk_i)
        self.dut.start_i.value = 0



        # self.dut.read_i.value = 0
        # await RisingEdge(self.dut.clk_i)

        
        for _ in range(9):
            await RisingEdge(self.dut.scl)

        for _ in range(9*self.dut.read_size_i.value):
            await RisingEdge(self.dut.scl)
            

        await Timer(5, "us")
        await RisingEdge(self.dut.clk_i)
        self.dut.stop_i.value = 1
        await RisingEdge(self.dut.clk_i)
        self.dut.stop_i.value = 0
        await self.delay(150)





# @cocotb.test()
async def i2c_write(dut):
    i2c = I2C_test(dut)

    await i2c.delay(15)

    array = []
    for j in range(256):
        array.append(j)

    for _ in range(10):
        numero = random.randint(0, 128)
        numero2 = random.randint(0, 256)
        await i2c.write_i2c([numero2], numero)
        await i2c.delay(1500)

    await i2c.delay(150)



@cocotb.test()
async def i2c_read(dut):
    i2c = I2C_test(dut)

    await i2c.delay(15)


    await i2c.read_i2c(address=0x60, size=5, data_read=0x01)


