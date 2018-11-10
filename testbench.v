module testbench;
    reg clk = 0;
    reg rstn = 0;
    always clk = #5 !clk;

    wire mem_valid;
    wire mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_rdata;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    
    ucore ucore (
        .clk(clk), .rstn(rstn),
        .mem_valid(mem_valid), .mem_ready(mem_ready),
        .mem_addr(mem_addr), .mem_rdata(mem_rdata),
        .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb)
    );

    rom rom (
        .clk(clk),
        .mem_valid(mem_valid), .mem_ready(mem_ready),
        .mem_addr(mem_addr), .mem_rdata(mem_rdata),
        .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb)
    );

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars;
        #20
        rstn = 1;
        #100000
        $finish;
    end
endmodule
