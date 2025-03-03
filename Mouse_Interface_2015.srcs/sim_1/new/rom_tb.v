`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 12:39:28 PM
// Design Name: 
// Module Name: rom_tb
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


module rom_tb();
reg CLK = 'h0;
reg [8:0] ROM_ADDRESS = 'h0;

integer passed_tests = 0;

wire [7:0] ROM_DATA;
reg [7:0] ROM_DUMP [255:0];

initial
    $readmemh("../../../rom.mem",ROM_DUMP);
    
initial
    forever #5 CLK = ~CLK;
initial 
begin
    $display("Starting RAM functionality test\n");
    for (ROM_ADDRESS = 0; ROM_ADDRESS < 256; ROM_ADDRESS = ROM_ADDRESS + 1)
    begin
        #30;
        if (ROM_DATA == ROM_DUMP[ROM_ADDRESS])
            passed_tests = passed_tests + 1;
        else
            $display("fail at test %d\n", ROM_ADDRESS);
    end
    $display("\n\n######################\n ROM READ COVERAGE = %d % \n######################\n\n",100*passed_tests/256);
    $finish;
end




ROM u_ROM(
    //standard signals
    .CLK(CLK),
    //BUS signals
    .DATA(ROM_DATA),
    .ADDR(ROM_ADDRESS)
);

endmodule
