# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "G_FPGA_CLK"
  ipgui::add_param $IPINST -name "G_I2C_CLK"
  ipgui::add_param $IPINST -name "G_TRISTATE" -widget comboBox

}

proc update_PARAM_VALUE.G_FPGA_CLK { PARAM_VALUE.G_FPGA_CLK } {
	# Procedure called to update G_FPGA_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.G_FPGA_CLK { PARAM_VALUE.G_FPGA_CLK } {
	# Procedure called to validate G_FPGA_CLK
	return true
}

proc update_PARAM_VALUE.G_I2C_CLK { PARAM_VALUE.G_I2C_CLK } {
	# Procedure called to update G_I2C_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.G_I2C_CLK { PARAM_VALUE.G_I2C_CLK } {
	# Procedure called to validate G_I2C_CLK
	return true
}

proc update_PARAM_VALUE.G_TRISTATE { PARAM_VALUE.G_TRISTATE } {
	# Procedure called to update G_TRISTATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.G_TRISTATE { PARAM_VALUE.G_TRISTATE } {
	# Procedure called to validate G_TRISTATE
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.G_FPGA_CLK { MODELPARAM_VALUE.G_FPGA_CLK PARAM_VALUE.G_FPGA_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.G_FPGA_CLK}] ${MODELPARAM_VALUE.G_FPGA_CLK}
}

proc update_MODELPARAM_VALUE.G_I2C_CLK { MODELPARAM_VALUE.G_I2C_CLK PARAM_VALUE.G_I2C_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.G_I2C_CLK}] ${MODELPARAM_VALUE.G_I2C_CLK}
}

proc update_MODELPARAM_VALUE.G_TRISTATE { MODELPARAM_VALUE.G_TRISTATE PARAM_VALUE.G_TRISTATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.G_TRISTATE}] ${MODELPARAM_VALUE.G_TRISTATE}
}

