import sys
import struct
from functools import wraps

def p16(val): return struct.pack("<H", val)
def u16(val): return struct.unpack("<H", val)[0]

instructions = {}
def instruction(*parsers):
    def deco(func):
        global instructions
        @wraps(func)
        def wrapper(*args, **kwargs):
            args = map(lambda (p, v): p(v, **kwargs), zip(parsers, args))
            return func(*args, **kwargs)
        instructions[func.func_name] = wrapper
        return wrapper
    return deco

def reg(arg, **kwargs):
    assert arg[0] == "u"
    reg = int(arg[1])
    assert 0 <= reg <= 3
    return reg

def imm8(arg, **kwargs):
    try:
        val = int(arg)
    except ValueError:
        val = int(arg, 16)
    assert 0 <= val < 256
    return val

def simm8(arg, **kwargs):
    val = int(arg)
    assert -128 <= val <= 127
    return val & 0xff

def label(lbl, **kwargs):
    try:
        return kwargs["labels"][lbl]
    except KeyError:
        return 0x3ff

def imm5(arg, **kwargs):
    val = int(arg)
    assert 0 <= val < 32
    return val

def name(arg, **kwargs):
    return arg

@instruction(name)
def LABEL(lbl, **kwargs):
    if lbl not in kwargs["labels"]:
        kwargs["labels"][lbl] = len(kwargs["code"])

@instruction(reg, reg)
def LOADMEM(dst, src, **kwargs):
    kwargs["code"].append((0b000000 << 10) | (dst << 8) | src)

@instruction(reg, imm8)
def LOADIMM(reg, imm8, **kwargs):
    kwargs["code"].append((0b000001 << 10) | (reg << 8) | imm8)

@instruction(reg, reg)
def MOVE(dst, src, **kwargs):
    kwargs["code"].append((0b000010 << 10) | (dst << 8) | src)

@instruction(reg, imm8)
def STORE_REG(reg, imm8, **kwargs):
    kwargs["code"].append((0b000011 << 10) | (reg << 8) | imm8)

@instruction(reg, imm8)
def LOAD_REG(reg, imm8, **kwargs):
    kwargs["code"].append((0b000100 << 10) | (reg << 8) | imm8)
    
@instruction(imm5, imm5)
def SHIFT_AND_MASK(shift, mask, **kwargs):
    kwargs["code"].append((0b000101 << 10) | (shift << 5) | mask)

@instruction(reg, imm5)
def SHIFTL(reg, shift, **kwargs):
    kwargs["code"].append((0b000110 << 10) | (reg << 8) | shift)

@instruction(reg, reg)
def OR(dst, src, **kwargs):
    kwargs["code"].append((0b000111 << 10) | (dst << 8) | src)

@instruction(reg, reg)
def ADD(dst, src, **kwargs):
    kwargs["code"].append((0b001000 << 10) | (dst << 8) | src)

@instruction(reg, reg)
def SUB(dst, src, **kwargs):
    kwargs["code"].append((0b001001 << 10) | (dst << 8) | src)

@instruction(label)
def BZ_DEC(addr, **kwargs):
    kwargs["code"].append((0b001010 << 10) | addr)

@instruction(label)
def BNZ(addr, **kwargs):
    kwargs["code"].append((0b001011 << 10) | addr)

@instruction(label)
def CALL(addr, **kwargs):
    kwargs["code"].append((0b001100 << 10) | addr)

@instruction()
def RET(**kwargs):
    kwargs["code"].append((0b001101 << 10))

@instruction(reg, simm8)
def ADDI(dst, simm8, **kwargs):
    kwargs["code"].append((0b001110 << 10) | (dst << 8) | simm8)

@instruction(reg)
def ADDPC(reg, **kwargs):
    kwargs["code"].append((0b001111 << 10) | (reg << 8))

@instruction(reg, reg)
def STORE_REG_REG(dst, src, **kwargs):
    kwargs["code"].append((0b010000 << 10) | (dst << 8) | src)

@instruction(reg, reg)
def LOAD_REG_REG(dst, src, **kwargs):
    kwargs["code"].append((0b010001 << 10) | (src << 8) | dst)

@instruction(label)
def JUMP(addr, **kwargs):
    kwargs["code"].append((0b010010 << 10) | addr)

@instruction(reg)
def SIMM_J(dst, **kwargs):
    kwargs["code"].append((0b010011 << 10) | (dst << 8))

@instruction(reg)
def SIMM_I(dst, **kwargs):
    kwargs["code"].append((0b010100 << 10) | (dst << 8))

def single_pass(source, labels = None):
    if not labels: labels = {}
    code = []
    for line in source.split("\n"):
        line = line.strip()
        if line == "": continue
        try:
            inst, args = line.split(" ", 1)
        except ValueError:
            inst, args = line, ""
        args = map(str.strip, args.split(","))
        instructions[inst](*args, labels = labels, code = code)
    return code, labels

def assemble(source):
    _, lbls = single_pass(source)
    code, _ = single_pass(source, labels = lbls)
    return code 

def generate_rom(code, romname):
    rom = open("rom_template.v", "r").read()
    content = []
    for i, word in enumerate(code):
        content.append("rom[%i] <= 16'h%04x;" % (i, word))
    content = "\n".join(content)
    
    rom = rom.replace("##ROMNAME##", romname)
    rom = rom.replace("##CONTENTS##", content)
    return rom.strip()

def main():
    if len(sys.argv) < 2:
        print "Usage: %s <assembly file> <ROMNAME>" % sys.argv[0]
        return 1

    source = open(sys.argv[1], "r").read()
    code = assemble(source)
    print generate_rom(code, "ucode")
    return 0
    
if __name__ == "__main__": exit(main())
