`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 02:25:41 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb();

reg RESET = 'h1;
reg CLK = 'h0;
reg SENS_CTRL = 'h0;

wire CLK_MOUSE;
wire DATA_MOUSE;

wire [3:0] SEG_SELECT_OUT;
wire [7:0] SEG_OUT;
wire [5:0] LEDS;
wire [2:0] MBTNS;

initial
    forever #5 CLK = ~CLK;
 

top u_top(
    // Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    .SENS_CTRL(SENS_CTRL),
    // IO - Mouse Side
    .CLK_MOUSE(CLK_MOUSE),
    .DATA_MOUSE(DATA_MOUSE),
    // IO - 7-Seg
    .SEG_SELECT_OUT(SEG_SELECT_OUT),
    .SEG_OUT(SEG_OUT),
    .LEDS(LEDS),
    .MBTNS(MBTNS)
);
endmodule
