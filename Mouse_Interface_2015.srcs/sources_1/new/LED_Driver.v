`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 09:55:37 AM
// Design Name: 
// Module Name: LED_Driver
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


module LED_Driver(
        // Standard Inputs
    input           RESET,
    input           CLK,
    // Bus I/O
    input  [7:0]    BUS_ADDR,
    inout  [7:0]    BUS_DATA,
    input           BUS_WE,
    // LED outputs
    output    [15:0]    LEDS
);

parameter RAMBaseAddr = 8'hC0;
parameter RAMSize = 'h2;


//Tristate
wire [7:0] BufferedBusData;
reg [7:0] Out;
reg [15:0] Mem;

assign BufferedBusData = BUS_DATA;

//single port ram 
always@(posedge CLK)
begin
    // Brute-force RAM address decoding. Think of a simpler way...
    if ((BUS_ADDR >= RAMBaseAddr) & (BUS_ADDR < RAMBaseAddr + RAMSize)) 
    begin
        if(BUS_WE) 
        begin
            case(BUS_ADDR)
                8'hC0: Mem[7:0] <= BufferedBusData;
                8'hC1: Mem[15:8] <= BufferedBusData;
            endcase
        end 
    end 
end

assign LEDS = Mem;
endmodule
