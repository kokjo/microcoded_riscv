module ##ROMNAME## (
    clk, pc, inst
);
    input clk;
    input [9:0] pc;
    output reg [15:0] inst;

    integer i;
    reg [15:0] rom [0:1023];
    
    initial begin
        for(i = 0; i < 1024; i = i + 1) rom[i] <= 16'hffff;
##CONTENTS##
    end

    always @ (posedge clk) inst <= rom[pc];
endmodule
