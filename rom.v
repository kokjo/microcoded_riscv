/* AUTOGENERATED see generate_rom.py */
module rom (
    input clk,
                          
    input mem_valid,
    output reg mem_ready,
    input [31:0] mem_addr,                   
    output reg [31:0] mem_rdata,                   
    input [31:0] mem_wdata,
    input [3:0] mem_wstrb 
);
    localparam DEPTH = 8;
    localparam WORDS = 1 << DEPTH;

    reg [31:0] rom [0:WORDS-1];

    integer i;
    initial begin
        for(i = 0; i < WORDS; i = i + 1) rom[i] <= 32'h00000000;
        rom[0] <= 32'h0080006f;
        rom[1] <= 32'h01c0006f;
        rom[2] <= 32'h00000093;
        rom[3] <= 32'h40000113;
        rom[4] <= 32'h340110f3;
        rom[5] <= 32'h00000073;
        rom[6] <= 32'h0a4000ef;
        rom[7] <= 32'h0000006f;
        rom[8] <= 32'h340090f3;
        rom[9] <= 32'h341090f3;
        rom[10] <= 32'h00408093;
        rom[11] <= 32'h341090f3;
        rom[12] <= 32'h340090f3;
        rom[13] <= 32'h30200073;
        rom[14] <= 32'hfe010113;
        rom[15] <= 32'h00812e23;
        rom[16] <= 32'h02010413;
        rom[17] <= 32'h00050793;
        rom[18] <= 32'hfef407a3;
        rom[19] <= 32'h020007b7;
        rom[20] <= 32'h00878793;
        rom[21] <= 32'hfef44703;
        rom[22] <= 32'h00e7a023;
        rom[23] <= 32'h00000013;
        rom[24] <= 32'h01c12403;
        rom[25] <= 32'h02010113;
        rom[26] <= 32'h00008067;
        rom[27] <= 32'hfe010113;
        rom[28] <= 32'h00112e23;
        rom[29] <= 32'h00812c23;
        rom[30] <= 32'h02010413;
        rom[31] <= 32'hfea42623;
        rom[32] <= 32'h01c0006f;
        rom[33] <= 32'hfec42783;
        rom[34] <= 32'h00178713;
        rom[35] <= 32'hfee42623;
        rom[36] <= 32'h0007c783;
        rom[37] <= 32'h00078513;
        rom[38] <= 32'hfa1ff0ef;
        rom[39] <= 32'hfec42783;
        rom[40] <= 32'h0007c783;
        rom[41] <= 32'hfe0790e3;
        rom[42] <= 32'h00000013;
        rom[43] <= 32'h01c12083;
        rom[44] <= 32'h01812403;
        rom[45] <= 32'h02010113;
        rom[46] <= 32'h00008067;
        rom[47] <= 32'hfe010113;
        rom[48] <= 32'h00112e23;
        rom[49] <= 32'h00812c23;
        rom[50] <= 32'h02010413;
        rom[51] <= 32'h00000793;
        rom[52] <= 32'hfef42623;
        rom[53] <= 32'h0140006f;
        rom[54] <= 32'hfec42783;
        rom[55] <= 32'h00478713;
        rom[56] <= 32'hfee42623;
        rom[57] <= 32'h0007a023;
        rom[58] <= 32'hfec42703;
        rom[59] <= 32'h00000793;
        rom[60] <= 32'hfef764e3;
        rom[61] <= 32'hfe042423;
        rom[62] <= 32'h020007b7;
        rom[63] <= 32'h00478793;
        rom[64] <= 32'h01400713;
        rom[65] <= 32'h00e7a023;
        rom[66] <= 32'h030007b7;
        rom[67] <= 32'h00478793;
        rom[68] <= 32'h00100713;
        rom[69] <= 32'h00e7a023;
        rom[70] <= 32'h000507b7;
        rom[71] <= 32'h14c78513;
        rom[72] <= 32'hf4dff0ef;
        rom[73] <= 32'h0ff0000f;
        rom[74] <= 32'hfe842783;
        rom[75] <= 32'h0107d713;
        rom[76] <= 32'h030007b7;
        rom[77] <= 32'h00177713;
        rom[78] <= 32'h00e7a023;
        rom[79] <= 32'hfe842783;
        rom[80] <= 32'h00178793;
        rom[81] <= 32'hfef42423;
        rom[82] <= 32'hfe1ff06f;
        rom[83] <= 32'h6c6c6548;
        rom[84] <= 32'h57202c6f;
        rom[85] <= 32'h646c726f;
        rom[86] <= 32'h00000a21;
    end

    wire [DEPTH-1:0] addr = mem_addr[DEPTH-1+2:2];

    always @(posedge clk) begin
        mem_ready <= 0;
        if(mem_valid && !mem_ready) begin
            mem_ready <= 1;
            mem_rdata <= rom[addr];
        end
    end
endmodule