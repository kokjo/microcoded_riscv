#!/bin/sh
python uasm.py ucode.asm > ucode.mem
iverilog -o testbench ucore.v testbench.v rom.v ram.v
./testbench
yosys -p 'synth_ice40 -top ucore -blif hardware.blif' ucore.v
