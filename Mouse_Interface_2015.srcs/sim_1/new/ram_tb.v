`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 01:53:34 PM
// Design Name: 
// Module Name: ram_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ram_tb();
reg CLK = 'h0;
reg [7:0] RAM_ADDRESS = 'h0;
reg BUS_WE = 1'h0;

integer passed_tests = 0;

wire [7:0] BUS_DATA;
reg [7:0] BUS_DATA_DRIVEN;

assign BUS_DATA = BUS_WE ? BUS_DATA_DRIVEN : 8'hZZ;

reg [7:0] RAM_DUMP [127:0];

initial
    $readmemh("../../../ram.mem",RAM_DUMP);
    
initial
    forever #5 CLK = ~CLK;
initial 
begin
    $display("Starting RAM functionality test\n");
    for (RAM_ADDRESS = 0; RAM_ADDRESS < 128; RAM_ADDRESS = RAM_ADDRESS + 1)
    begin
        #30;
        if (BUS_DATA == RAM_DUMP[RAM_ADDRESS])
            passed_tests = passed_tests + 1;
        else
            $display("fail at test %d\n", RAM_ADDRESS);
    end
    $display("\n\n######################\n INITIAL RAM READ COVERAGE = %d % \n######################\n\n",100*passed_tests/128);
    
    passed_tests = 0;
    #100;
    RAM_ADDRESS = 'h0;
    for (integer i = 0; i < 100; i = i + 1)
    begin
        BUS_WE = 'h1;
        BUS_DATA_DRIVEN = $random;
        RAM_ADDRESS[6:0] = $random;
        #20;
        BUS_WE = 'h0;
        if (BUS_DATA == BUS_DATA_DRIVEN)
            passed_tests = passed_tests + 1;
        #20;
    end
    $display("\n\n######################\n RAM READ/WRITE COVERAGE = %d % \n######################\n\n",100*passed_tests/100);

    $finish;
end



RAM u_RAM (
    //standard signals
    .CLK(CLK),
    //BUS signals
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(RAM_ADDRESS),
    .BUS_WE(BUS_WE)
);











endmodule
