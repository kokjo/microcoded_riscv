LABEL start
    GET_RESET_PC u0
    STORE_REG u0, 0xff

LABEL fetch_instruction
    LOAD_REG u0, 0xff
    LOADMEM u3, u0
    STORE_REG u3, 0xfe
    SHIFT_AND_MASK 0, 2
    ADDI u0, -3
    BNZ unknown_opcode

    SHIFT_AND_MASK 15, 5
    LOAD_REG_REG u1, u0
    SHIFT_AND_MASK 20, 5
    LOAD_REG_REG u2, u0

    SHIFT_AND_MASK 2, 5
    ADDPC u0
    JUMP opcode_00
    JUMP opcode_01
    JUMP opcode_02
    JUMP opcode_03
    JUMP opcode_04
    JUMP opcode_05
    JUMP opcode_06
    JUMP opcode_07
    JUMP opcode_08
    JUMP opcode_09
    JUMP opcode_0a
    JUMP opcode_0b
    JUMP opcode_0c
    JUMP opcode_0d
    JUMP opcode_0e
    JUMP opcode_0f
    JUMP opcode_10
    JUMP opcode_11
    JUMP opcode_12
    JUMP opcode_13
    JUMP opcode_14
    JUMP opcode_15
    JUMP opcode_16
    JUMP opcode_17
    JUMP opcode_18
    JUMP opcode_19
    JUMP opcode_1a
    JUMP opcode_1b
    JUMP opcode_1c
    JUMP opcode_1d
    JUMP opcode_1e
    JUMP opcode_1f

LABEL opcode_00
LABEL opcode_load
    JUMP continue

LABEL opcode_03
LABEL opcode_fence
    JUMP continue

LABEL opcode_04
LABEL opcode_alui
    SIMM_I u1
    SHIFT_AND_MASK 12, 3
    ADDPC u0
    JUMP opcode_alui_0
    JUMP opcode_alui_1
    JUMP opcode_alui_2
    JUMP opcode_alui_3
    JUMP opcode_alui_4
    JUMP opcode_alui_5
    JUMP opcode_alui_6
    JUMP opcode_alui_7

LABEL opcode_alui_0
    ADD u1, u0
    JUMP opcode_alui_wb

LABEL opcode_alui_1
    SHIFTL u1, u0
    JUMP opcode_alui_wb

LABEL opcode_alui_2
LABEL opcode_alui_3
LABEL opcode_alui_4
LABEL opcode_alui_5
LABEL opcode_alui_6
LABEL opcode_alui_7
    JUMP continue

LABEL opcode_alui_wb
    CALL write_u1_rd
    JUMP continue

LABEL opcode_08
LABEL opcode_store
    JUMP continue

LABEL opcode_0d
LABEL opcode_lui
    JUMP continue

LABEL opcode_18
LABEL opcode_branch
    JUMP continue

LABEL opcode_19
LABEL opcode_jalr
    SIMM_I u0
    ADD u0, u1
    LOAD_REG u1, 0xff
    STORE_REG u0, 0xff
    ADDI u1, +4
    CALL write_u1_rd
    JUMP fetch_instruction

LABEL opcode_1b
LABEL opcode_jal
    SIMM_J u0
    LOAD_REG u1, 0xff
    ADD u0, u1
    STORE_REG u0, 0xff
    ADDI u1, +4
    CALL write_u1_rd
    JUMP fetch_instruction

LABEL opcode_1c
LABEL opcode_system
    JUMP continue

LABEL opcode_01
LABEL opcode_02
LABEL opcode_05
LABEL opcode_06
LABEL opcode_07
LABEL opcode_09
LABEL opcode_0a
LABEL opcode_0b
LABEL opcode_0c
LABEL opcode_0e
LABEL opcode_0f
LABEL opcode_00
LABEL opcode_11
LABEL opcode_12
LABEL opcode_13
LABEL opcode_14
LABEL opcode_15
LABEL opcode_16
LABEL opcode_17
LABEL opcode_1a
LABEL opcode_1d
LABEL opcode_1e
LABEL opcode_1f
LABEL unknown_opcode
    JUMP unknown_opcode

LABEL continue
    LOAD_REG u3, 0xff
    ADDI u3, 4
    STORE_REG u3, 0xff
    JUMP fetch_instruction

LABEL write_u1_rd
    SHIFT_AND_MASK 7, 5
    STORE_REG_REG u1, u0
    RET
