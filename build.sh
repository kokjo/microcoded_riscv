#!/bin/sh
python uasm.py ucode.asm ucode > ucode.v
iverilog -o testbench ucode.v ucore.v testbench.v rom.v ram.v
./testbench
#yosys -p 'synth_ice40 -top microcore -blif hardware.blif' ucore.v ucode.v 
#yosys -p 'read_blif -wideports hardware.blif; write_verilog hardware_syn.v'
