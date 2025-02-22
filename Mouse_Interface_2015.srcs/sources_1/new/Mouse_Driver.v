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
    output          BUS_INTERRUPT_RAISE,
    // IO - Mouse Side
    inout           CLK_MOUSE,
    inout           DATA_MOUSE,
    //     Mouse data information
    output          XS,
    output          YS,
    output [2:0]    BTNS
    
);


parameter RAMBaseAddr = 8'hA0;
parameter MOUSE_STATUS = 8'hA0;
parameter MOUSE_X= 8'hA1;
parameter MOUSE_Y= 8'hA2;

reg [7:0]   Out;
reg         RAMBusWE;


wire [3:0]  MouseStatus;
wire [7:0]  MouseX;
wire [7:0]  MouseY;



assign      BUS_DATA = RAMBusWE ? Out : 8'hZZ;

always@(posedge CLK)
begin
    if ((BUS_ADDR >= 8'hA0) & (BUS_ADDR <= 8'hA2))
    begin
        if (BUS_WE)
            RAMBusWE <= 1'h0;
        else
            RAMBusWE <= 1'h1;
    end
    else
        RAMBusWE <= 1'h0;
        
    case(BUS_ADDR)
        MOUSE_STATUS: Out <= MouseStatus;
        MOUSE_X: Out <= MouseX;
        MOUSE_Y: Out <= MouseY;
        default: Out <= 'h0;
    endcase
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
    .INTERRUPT_RAISE(BUS_INTERRUPT_RAISE)
);

endmodule
