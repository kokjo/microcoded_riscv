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

    reg [9:0] uPC = 0;
    reg [0:1] uSP;
    reg [9:0] uSTK [0:3];
    reg [31:0] uREG [0:3];
    wire [9:0] next_uPC = rst ? 0
                        : (uop == 6'b000000 && !mem_ready) ? uPC
                        : (uop == 6'b001010 && uREG[ureg] == 0) ? uarg10
                        : (uop == 6'b001011 && uREG[ureg] != 0) ? uarg10
                        : (uop == 6'b001100) ? uarg10
                        : (uop == 6'b001101) ? uSTK[0]
                        : (uop == 6'b001111) ? uPC + 1 + uREG[ureg]
                        : (uop == 6'b010010) ? uarg10
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
        uPC <= 0;
        uSTK[0] <= 0; uSTK[1] <= 0; uSTK[2] <= 0; uSTK[3] <= 0;
        uREG[0] <= 0; uREG[1] <= 0; uREG[2] <= 0; uREG[3] <= 0;
        for(i = 0; i < 256; i = i + 1) regs[i] <= 0;
        regs[255] <= 32'h00050000;
    end else begin  
        uPC <= next_uPC;
        case(uop)
            6'b000000: begin // LOAD MEM
                mem_valid <= 1;
                mem_addr <= uREG[uarg[1:0]];
                mem_wstrb <= 6'b0000;
                if(mem_ready) begin
                    uREG[ureg] <= mem_rdata;
                end
            end
            // LOAD IMM
            6'b000001: uREG[ureg] <= uarg; 
            // MOVE
            6'b000010: uREG[ureg] <= uREG[uarg[1:0]];
            // STORE REG
            6'b000011: regs[uarg] <= uREG[ureg];
            // LOAD REG
            6'b000100: uREG[ureg] <= regs[uarg];
            // SHIFT RIGHT AND MASK
            6'b000101: uREG[0] <= (uREG[3] >> uarg10[9:5]) & ((1 << uarg10[4:0]) - 1);
            // SHIFT LEFT
            6'b000110: uREG[ureg] <= uREG[3] << uarg[4:0];
            // OR
            6'b000111: uREG[ureg] <= uREG[ureg] | uREG[uarg[1:0]];
            // ADD
            6'b001000: uREG[ureg] <= uREG[ureg] + uREG[uarg[1:0]];
            // SUB
            6'b001001: uREG[ureg] <= uREG[ureg] - uREG[uarg[1:0]];
            6'b001010: begin // BZ; DEC
                //if(uREG[0] == 0) uPC <= uarg10;
                uREG[0] <= uREG[0] - 1;
            end
            // BNZ
            //6'b001011: if(uREG[0] != 0) uPC <= uarg10;
            // CALL
            6'b001100: begin
                uSTK[3] <= uSTK[2];
                uSTK[2] <= uSTK[1];
                uSTK[1] <= uSTK[0];
                uSTK[0] <= uPC + 1;
                //uPC <= uarg10;
            end
            // RET
            6'b001101: begin
                //uPC <= uSTK[0];
                uSTK[0] <= uSTK[1];
                uSTK[1] <= uSTK[2];
                uSTK[2] <= uSTK[3];
            end
            // ADDI
            6'b001110: uREG[ureg] <= uREG[ureg] + {{24{uarg[7]}}, uarg};
            // ADDPC
            //6'b001111: uPC <= uPC + uREG[ureg] + 1;
            // STORE_REG_REG
            6'b010000: regs[uREG[ureg][7:0]] <= uREG[uarg[1:0]];
            // LOAD_REG_REG
            6'b010001: uREG[uarg[1:0]] <= (uREG[ureg][7:0] != 0) ? regs[uREG[ureg][7:0]] : 32'h00000000;
            // JUMP 
            //6'b010010: uPC <= uarg10
            // SIMM_J
            6'b010011: uREG[ureg] <= {{12{uREG[3][31]}},uREG[3][19:12],uREG[3][20],uREG[3][30:21], 1'b0};
            // SIMM_I
            6'b010100: uREG[ureg] <= {{21{uREG[3][31]}},uREG[3][30:20]};
            
        endcase
        if(mem_ready) begin
            mem_valid <= 0;
        end
    end
endmodule

