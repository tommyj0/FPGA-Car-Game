`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2025 04:19:21 PM
// Design Name: 
// Module Name: Mouse_Driver
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


module Mouse_Driver(
    // Standard Inputs
    input           RESET,
    input           CLK,
    input  [1:0]    SENS_CTRL,
    // Bus I/O
    input  [7:0]    BUS_ADDR,
    inout  [7:0]    BUS_DATA,
    input           BUS_WE,
    output          reg BUS_INTERRUPT_RAISE,
    input           BUS_INTERRUPT_ACK,
    // IO - Mouse Side
    inout           CLK_MOUSE,
    inout           DATA_MOUSE
    
);

// RAM address parameters
parameter RAMBaseAddr = 8'hA0;
parameter RAMSize = 8'h3;
parameter MOUSE_STATUS = 8'hA0;
parameter MOUSE_X= 8'hA1;
parameter MOUSE_Y= 8'hA2;

reg [7:0]   Out;
reg         RAMBusWE;

wire INTERRUPT_RAISE;
wire [7:0]  MouseStatus;
wire [7:0]  MouseX;
wire [7:0]  MouseY;



assign BUS_DATA = RAMBusWE ? Out : 8'hZZ;

always@(posedge CLK)
begin
    // Address decode
    if ((BUS_ADDR >= RAMBaseAddr) & (BUS_ADDR < RAMBaseAddr + RAMSize))
    begin
        if (BUS_WE) // check that write enable is low before driving data bus
            RAMBusWE <= 1'h0;
        else
            RAMBusWE <= 1'h1;
    end
    else
        RAMBusWE <= 1'h0; // if address is incorrect, leave data bus undriven 
        
    case(BUS_ADDR) // set appropriate output
        MOUSE_STATUS: Out <= MouseStatus;
        MOUSE_X: Out <= MouseX;
        MOUSE_Y: Out <= MouseY;
        default: Out <= 'h0;
    endcase
end

always@(posedge CLK)
begin
    if (RESET)
        BUS_INTERRUPT_RAISE <= 'h0;
    else if (INTERRUPT_RAISE)
        BUS_INTERRUPT_RAISE <= 'h1;
    else if (BUS_INTERRUPT_ACK)
        BUS_INTERRUPT_RAISE <= 'h0;
end

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
    .BTNS(BTNS),
    .INTERRUPT_RAISE(INTERRUPT_RAISE)
);

endmodule
