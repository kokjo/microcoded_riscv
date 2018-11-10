#!/bin/sh
set -e
python uasm.py ucode.asm > ucode.mem
iverilog -o testbench ucore.v testbench.v rom.v ram.v
./testbench
yosys -p 'synth_ice40 -top ucore -blif ucore.blif' ucore.v
#yosys -p 'read_blif -wideports ucore.blif; write_verilog ucore_syn.v'
arachne-pnr -d 8k ucore.blif -o ucore.asc
icetime -d hx8k -mitr ucore.rpt ucore.asc
