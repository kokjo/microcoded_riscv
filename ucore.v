module microcore (
    clk, rst,
    mem_valid, mem_ready,
    mem_addr, mem_rdata,
    mem_wdata, mem_wstrb
);
    input clk, rst;
    output reg mem_valid;
    input mem_ready;
    output reg [31:0] mem_addr;
    input [31:0] mem_rdata;
    output reg [31:0] mem_wdata;
    output reg [3:0] mem_wstrb;
    reg prefetch_done;

    localparam LOAD_MEM      = 6'b000000;
    localparam LOAD_IMM      = 6'b000001;
    localparam MOVE          = 6'b000010;
    localparam STORE_REG     = 6'b000011;
    localparam LOAD_REG      = 6'b000100;
    localparam SHIFT_MASK    = 6'b000101;
    localparam SHIFTL        = 6'b000110;
    localparam OR            = 6'b000111;
    localparam ADD           = 6'b001000;
    localparam SUB           = 6'b001001;
    localparam BRANCH_Z      = 6'b001010;
    localparam BRANCH_NZ     = 6'b001011;
    localparam CALL          = 6'b001100;
    localparam RET           = 6'b001101;
    localparam ADDI          = 6'b001110;
    localparam ADDPC         = 6'b001111;
    localparam STORE_REG_REG = 6'b010000;
    localparam LOAD_REG_REG  = 6'b010001;
    localparam JUMP          = 6'b010010;
    localparam SIMM_J        = 6'b010011;
    localparam SIMM_I        = 6'b010100;
    
    reg [9:0] uPC = 0;
    reg [0:1] uSP;
    reg [9:0] uSTK [0:3];
    reg [31:0] uREG [0:3];
    wire [9:0] next_uPC = rst ? 0
                        : (uop == LOAD_MEM && !mem_ready && prefetch_done) ? uPC
                        : (uop == BRANCH_Z && uREG[ureg] == 0) ? uarg10
                        : (uop == BRANCH_NZ && uREG[ureg] != 0) ? uarg10
                        : (uop == CALL) ? uarg10
                        : (uop == RET) ? uSTK[0]
                        : (uop == ADDPC) ? uPC + 1 + uREG[ureg]
                        : (uop == JUMP) ? uarg10
                        : uPC + 1;

    wire [15:0] uINST;

    ucode ucode (
        .clk(clk),
        .pc(next_uPC),
        .inst(uINST)
    );

    integer i;
    reg [31:0] regs [0:255];

    wire [5:0] uop = uINST[15:10];
    wire [9:0] uarg10 = uINST[9:0];
    wire [1:0] ureg = uINST[9:8];
    wire [7:0] uarg = uINST[7:0];

    wire [31:0] ureg0 = uREG[0];
    wire [31:0] ureg1 = uREG[1];
    wire [31:0] ureg2 = uREG[2];
    wire [31:0] ureg3 = uREG[3];

    always @ (posedge clk) if(rst) begin
        mem_valid <= 0;
        mem_addr <= 0;
        mem_wdata <= 0;
        mem_wstrb <= 0;
        prefetch_done <= 1;
        uPC <= 0;
        uSTK[0] <= 0; uSTK[1] <= 0; uSTK[2] <= 0; uSTK[3] <= 0;
        uREG[0] <= 0; uREG[1] <= 0; uREG[2] <= 0; uREG[3] <= 0;
        for(i = 0; i < 256; i = i + 1) regs[i] <= 0;
        regs[255] <= 32'h00050000;
    end else begin  
        uPC <= next_uPC;
        case(uop)
            LOAD_MEM: if(prefetch_done) begin // LOAD MEM
                mem_valid <= 1;
                mem_addr <= uREG[uarg[1:0]];
                mem_wstrb <= 6'b0000;
                if(mem_ready) begin
                    uREG[ureg] <= mem_rdata;
                end
            end
            LOAD_IMM:
                uREG[ureg] <= uarg; 
            MOVE:
                uREG[ureg] <= uREG[uarg[1:0]];
            STORE_REG:
                regs[uarg] <= uREG[ureg];
            LOAD_REG:
                uREG[ureg] <= regs[uarg];
            SHIFT_MASK:
                uREG[0] <= (uREG[3] >> uarg10[9:5]) & ((1 << uarg10[4:0]) - 1);
            SHIFTL:
                uREG[ureg] <= uREG[3] << uarg[4:0];
            OR:
                uREG[ureg] <= uREG[ureg] | uREG[uarg[1:0]];
            ADD: uREG[ureg] <= uREG[ureg] + uREG[uarg[1:0]];
            SUB: uREG[ureg] <= uREG[ureg] - uREG[uarg[1:0]];
            // BRANCH_Z: if(uREG[0] == 0) uPC <= uarg10;
            // BRANCH_NZ: if(uREG[0] != 0) uPC <= uarg10;
            CALL: begin
                uSTK[3] <= uSTK[2];
                uSTK[2] <= uSTK[1];
                uSTK[1] <= uSTK[0];
                uSTK[0] <= uPC + 1;
                //uPC <= uarg10;
            end
            RET: begin
                //uPC <= uSTK[0];
                uSTK[0] <= uSTK[1];
                uSTK[1] <= uSTK[2];
                uSTK[2] <= uSTK[3];
            end
            ADDI:
                uREG[ureg] <= uREG[ureg] + {{24{uarg[7]}}, uarg};
            // ADDPC: uPC <= uPC + uREG[ureg] + 1;
            STORE_REG_REG:
                regs[uREG[ureg][7:0]] <= uREG[uarg[1:0]];
            LOAD_REG_REG:
                uREG[uarg[1:0]] <= (uREG[ureg][7:0] != 0)
                                 ? regs[uREG[ureg][7:0]]
                                 : 32'h00000000;
            // JUMP: uPC <= uarg10
            SIMM_J:
                uREG[ureg] <= {{12{uREG[3][31]}},uREG[3][19:12],uREG[3][20],uREG[3][30:21], 1'b0};
            SIMM_I:
                uREG[ureg] <= {{21{uREG[3][31]}},uREG[3][30:20]};
            
        endcase
        if(mem_ready) begin
            mem_valid <= 0;
            prefetch_done <= 1;
        end
    end
endmodule

module ucode (
    clk, pc, inst
);
    input clk;
    input [9:0] pc;
    output reg [15:0] inst;
    reg [15:0] rom [0:1023];
    initial $readmemh("ucode.mem", rom);

    always @ (posedge clk) inst <= rom[pc];
endmodule


