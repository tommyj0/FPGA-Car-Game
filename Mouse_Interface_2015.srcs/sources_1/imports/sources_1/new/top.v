`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2025 04:33:00 PM
// Design Name: 
// Module Name: top
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


module top(
    // Standard Inputs
    input           RESET,
    input           CLK,
    input  [1:0]    SENS_CTRL,
    // IO - Mouse Side
    inout           CLK_MOUSE,
    inout           DATA_MOUSE,
    // IO - 7-Seg
    output [3:0]    SEG_SELECT_OUT,
    output [7:0]    SEG_OUT,
    output [5:0]    LEDS,
    output [2:0]    MBTNS

);





wire [7:0] BUS_DATA;
wire [7:0] BUS_ADDR;
wire        BUS_WE;

wire [7:0] ROM_ADDRESS;
wire [7:0] ROM_DATA;

wire [1:0] BUS_INTERRUPTS_RAISE;
wire [1:0] BUS_INTERRUPTS_ACK;


//assign LEDX = MouseRegX;
//assign LEDY = MouseRegY;
assign LEDS = {XS,YS,MouseStatus};

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

Timer u_Timer (
    //standard signals
    .CLK(CLK),
    .RESET(RESET),
    //BUS signals
    .BUS_DATA(BUS_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE),
    .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[1]),
    .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[1])
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
    .BUS_DATA(BUST_DATA),
    .BUS_ADDR(BUS_ADDR),
    .BUS_WE(BUS_WE)
);


ROM u_ROM(
    //standard signals
    .CLK(CLK),
    //BUS signals
    .DATA(ROM_DATA),
    .ADDR(ROM_ADDRESS)
);

endmodule