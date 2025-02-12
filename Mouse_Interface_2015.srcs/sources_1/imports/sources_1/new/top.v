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
    input           SENS_CTRL,
    // IO - Mouse Side
    inout           CLK_MOUSE,
    inout           DATA_MOUSE,
    // IO - 7-Seg
    output [3:0]    SEG_SELECT_OUT,
    output [7:0]    SEG_OUT,
    output [5:0]    LEDS,
    output [2:0]    MBTNS
//    output [7:0]    LEDX,
//    output [7:0]    LEDY
);


//wire SENS_CTRL;
//assign SENS_CTRL = SENS_CTRL_SW;
// Mouse data information
wire [3:0] MouseStatus;
wire  [7:0] MouseX;
wire  [7:0] MouseY;

// 7-Seg wires
wire [1:0] StrobeCount;
wire [3:0] SEG_BIN;


//assign LEDX = MouseRegX;
//assign LEDY = MouseRegY;
assign LEDS = {XS,YS,MouseStatus};


MouseCounter # (
    .MAX(10000),
    .WIDTH(20)
) CLK_10k (
    .CLK(CLK),
    .RESET(RESET),
    .EN(1'b1),
    .COUNT(),
    .TRIG_OUT(CLK_10k_TRIG)
);

MouseCounter # (
    .MAX(3),
    .WIDTH(2)
) StrobeCounter (
    .CLK(CLK),
    .RESET(RESET),
    .EN(CLK_10k_TRIG),
    .COUNT(StrobeCount),
    .TRIG_OUT()
);

MouseTransceiver u_MouseTransceiver (
    .RESET(RESET),
    .CLK(CLK),
    .CLK_MOUSE(CLK_MOUSE),
    .DATA_MOUSE(DATA_MOUSE),
    .MouseStatus(MouseStatus),
    .MouseXout(MouseX),
    .MouseYout(MouseY),
    .XS(XS),
    .YS(YS),
    .SENS_CTRL(SENS_CTRL),
    .BTNS(MBTNS)
);

seg7decoder u_seg7decoder(
    .SEG_SELECT_IN(StrobeCount),
    .BIN_IN(SEG_BIN),
    .DOT_IN('h0),
    .SEG_SELECT_OUT(SEG_SELECT_OUT),
    .HEX_OUT(SEG_OUT)
);

mux_4x1 u_mux_4x1( 
        .IN1(MouseX[3:0]),                 // 4-bit input
        .IN2(MouseX[7:4]),                 // 4-bit input
        .IN3(MouseY[3:0]),                 // 4-bit input
        .IN4(MouseY[7:4]),                 // 4-bit input
        .CTRL(StrobeCount),               // Control 
        .OUT(SEG_BIN)                       
);      


endmodule