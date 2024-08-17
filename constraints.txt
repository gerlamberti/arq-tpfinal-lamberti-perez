# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports Entrada_RX]
set_property IOSTANDARD LVCMOS33 [get_ports Entrada_RX]

set_property PACKAGE_PIN A18 [get_ports Salida_TX]						
set_property IOSTANDARD LVCMOS33 [get_ports Salida_TX]

# Buttons    
set_property PACKAGE_PIN U18 [get_ports reset]						
set_property IOSTANDARD LVCMOS33 [get_ports reset]    

# LEDs
set_property PACKAGE_PIN U16 [get_ports {o_leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[0]}]
set_property PACKAGE_PIN E19 [get_ports {o_leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[1]}]
set_property PACKAGE_PIN U19 [get_ports {o_leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[2]}]
set_property PACKAGE_PIN V19 [get_ports {o_leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[3]}]
set_property PACKAGE_PIN W18 [get_ports {o_leds[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[4]}]
set_property PACKAGE_PIN U15 [get_ports {o_leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[5]}]
set_property PACKAGE_PIN U14 [get_ports {o_leds[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[6]}]
set_property PACKAGE_PIN V14 [get_ports {o_leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[7]}]