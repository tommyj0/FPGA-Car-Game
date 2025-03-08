`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 02:29:24 PM
// Design Name: 
// Module Name: processor_tb
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


module processor_tb();

reg CLK = 'h0;
reg RESET = 'h1;

wire [7:0] BUS_DATA;
wire [7:0] BUS_ADDR;
wire       BUS_WE;
wire [7:0] ROM_ADDRESS;
wire [7:0] ROM_DATA;
wire [1:0] BUS_INTERRUPTS_RAISE;
wire [1:0] BUS_INTERRUPTS_ACK;
wire [7:0] SEG_OUT;
wire [3:0] SEG_SELECT_OUT;


initial 
    forever #5 CLK = ~CLK;


initial
begin
    #100;
    RESET = 1'h0;
    #10000;
//    $finish;
end


Processor u_Processor(
    //Standard Signals
    .CLK(CLK),
    .RESET(RESET),
    //BUS Signals
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    // ROM signals
    .ROM_ADDRESS(ROM_ADDRESS),
    .ROM_DATA(ROM_DATA),
    // INTERRUPT signals
    .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
    .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
);

seg7_Driver u_seg7_Driver (
        // Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    // Bus I/O
    .BUS_ADDR(BUS_ADDR),
    .BUS_DATA(BUS_DATA),
    .BUS_WE(BUS_WE),
    // 7seg outputs
    .SEG_SELECT_OUT(SEG_SELECT_OUT),
    .HEX_OUT(SEG_OUT)
);

RAM u_RAM (
    //standard signals
    .CLK(CLK),
    //BUS signals
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE)
);


ROM u_ROM (
    //standard signals
    .CLK(CLK),
    //BUS signals
    .DATA(ROM_DATA),
    .ADDR(ROM_ADDRESS)
);


Mouse_Driver u_Mouse_Driver(
    // Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    .SENS_CTRL(0),
    // Bus I/O
    .BUS_ADDR(BUS_ADDR),
    .BUS_DATA(BUS_DATA),
    .BUS_WE(BUS_WE),
    .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[0]),
    .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[0])
//    // IO - Mouse Side
//    .CLK_MOUSE(CLK_MOUSE),
//    .DATA_MOUSE(DATA_MOUSE),
);

endmodule
