`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2025 09:15:14 AM
// Design Name: 
// Module Name: MouseTransmitter
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


module MouseTransceiver(
    // Standard Inputs
    input           RESET,
    input           CLK,
    input  [1:0]    SENS_CTRL,
    // IO - Mouse Side
    inout           CLK_MOUSE,
    inout           DATA_MOUSE,
//     Mouse data information
    output [3:0]    MouseStatus,
    output [7:0]    MouseXout,
    output [7:0]    MouseYout,
    output          XS,
    output          YS,
    output [2:0]    BTNS,
    output reg      INTERRUPT_RAISE
);

reg [10:0] MouseX;
reg [10:0] MouseY;

// define Limits
parameter [7:0] MouseLimitX = 160;
parameter [7:0] MouseLimitY = 120;

// define module interconnect
wire            DATA_MOUSE_IN;
wire            CLK_MOUSE_IN;
wire            CLK_MOUSE_OUT_EN;
wire            DATA_MOUSE_OUT;
wire            DATA_MOUSE_OUT_EN;

wire            Transmitter_SEND_BYTE;
wire [7:0]      Transmitter_BYTE_TO_SEND;
wire            Transmitter_BYTE_SENT;
wire [3:0]      Transmitter_STATE;
wire [10:0]     MouseLimitX_scaled;
wire [10:0]     MouseLimitY_scaled;

wire            Receiver_READ_ENABLE;
wire [7:0]      Receiver_BYTE_READ;
wire [1:0]      Receiver_BYTE_ERROR_CODE;
wire            Receiver_BYTE_READY;
wire [3:0]      Receiver_STATE;
 
wire [3:0]      MASTER_STATE_CODE;
wire [7:0]      MOUSE_DX;
wire [7:0]      MOUSE_DY;
wire [7:0]      MOUSE_STATUS;
wire            SEND_INTERRUPT;

wire                XSIGN;
wire                YSIGN;
wire                XOF;
wire                YOF;
wire signed [11:0]   OVERFLOWX;
wire signed [11:0]   OVERFLOWY;
wire signed [11:0]   MouseDX;
wire signed [11:0]   MouseDY;

// Assign outputs
assign MouseXout = MouseX >> SENS_CTRL;
assign MouseYout = MouseY >> SENS_CTRL;
assign XS = XSIGN;
assign YS = YSIGN;
assign MouseStatus = MASTER_STATE_CODE;
assign BTNS = {MOUSE_STATUS[0],MOUSE_STATUS[2],MOUSE_STATUS[1]};

assign XSIGN = MOUSE_STATUS[4];
assign YSIGN = MOUSE_STATUS[5];

// continuous assignments for coord calculations
assign XOF = MOUSE_STATUS[6];
assign YOF = MOUSE_STATUS[7];

// PS2 inout assignments
assign CLK_MOUSE_IN = CLK_MOUSE;
assign CLK_MOUSE = CLK_MOUSE_OUT_EN ? 1'b0 : 1'bZ;

assign DATA_MOUSE_IN = DATA_MOUSE;
assign DATA_MOUSE = DATA_MOUSE_OUT_EN ? DATA_MOUSE_OUT : 1'bZ;

// Overflow Handling
assign MouseDX = XOF ? {12'h000} : {{4{XSIGN}},MOUSE_DX};
assign MouseDY = YOF ? {12'h000} : {{4{YSIGN}},MOUSE_DY};

// Assign wider OVERFLOW 
assign OVERFLOWX = {4'b0,MouseX} + (MouseDX);
assign OVERFLOWY = {4'b0,MouseY} + (MouseDY);

// Assign scaled limit
assign MouseLimitX_scaled = MouseLimitX << SENS_CTRL;
assign MouseLimitY_scaled = MouseLimitY << SENS_CTRL;

// Sqequential Block for assigning vals
always@(posedge CLK)
begin
    if (RESET)
    begin
        MouseX <= (MouseLimitX_scaled)/2;
        MouseY <= (MouseLimitY_scaled)/2;
        INTERRUPT_RAISE <= 'h0;
    end
    else if (SEND_INTERRUPT)
    begin
        INTERRUPT_RAISE <= 'h1;
        // Set MouseX
        if (OVERFLOWX <= 0)
            MouseX <= 0;
        else if (OVERFLOWX >= MouseLimitX_scaled)
            MouseX <= MouseLimitX_scaled;
        else
            MouseX <= OVERFLOWX[10:0];
        // Set MouseY    
        if (OVERFLOWY <= 0)
            MouseY <= 0;
        else if (OVERFLOWY >= MouseLimitY_scaled)
            MouseY <= MouseLimitY_scaled;
        else
            MouseY <= OVERFLOWY[10:0];
    end
end

// Master SM instantiation
MouseMasterSM u_MouseMasterSM (
    .CLK(CLK),            
    .RESET(RESET),      
    // Transmitter    
    .SEND_BYTE(Transmitter_SEND_BYTE),          // output
    .BYTE_TO_SEND(Transmitter_BYTE_TO_SEND),    // output
    .BYTE_SENT(Transmitter_BYTE_SENT),          // input
    // Receiver  
    .READ_ENABLE(Receiver_READ_ENABLE),         // output
    .BYTE_READ(Receiver_BYTE_READ),             // input
    .BYTE_ERROR_CODE(Receiver_BYTE_ERROR_CODE), // input
    .BYTE_READY(Receiver_BYTE_READY),           // input
    // Data Registers
    .MOUSE_DX(MOUSE_DX),                        // output
    .MOUSE_DY(MOUSE_DY),                        // output   
    .MOUSE_STATUS(MOUSE_STATUS),                // output
    .MASTER_STATE_CODE(MASTER_STATE_CODE),      // output
    .SEND_INTERRUPT(SEND_INTERRUPT)             // output
);

// Transmitter instantiation
MouseTransmitter u_MouseTransmitter(
    .RESET(RESET),                              // input
    .CLK(CLK),                                  // input
    .CLK_MOUSE_IN(CLK_MOUSE_IN),                // input    
    .CLK_MOUSE_OUT_EN(CLK_MOUSE_OUT_EN),        // output
    .DATA_MOUSE_IN(DATA_MOUSE_IN),              // input
    .DATA_MOUSE_OUT(DATA_MOUSE_OUT),            // output
    .DATA_MOUSE_OUT_EN(DATA_MOUSE_OUT_EN),      // output
    .SEND_BYTE(Transmitter_SEND_BYTE),          // input
    .BYTE_TO_SEND(Transmitter_BYTE_TO_SEND),    // input
    .BYTE_SENT(Transmitter_BYTE_SENT),          // output
    .STATE(Transmitter_STATE)
);

// Receiver instantiation
MouseReceiver u_MouseReceiver(
    .RESET(RESET),                              // input
    .CLK(CLK),                                  // input
    .CLK_MOUSE_IN(CLK_MOUSE_IN),                // input
    .DATA_MOUSE_IN(DATA_MOUSE_IN),              // input
    .READ_ENABLE(Receiver_READ_ENABLE),         // input
    .BYTE_READ(Receiver_BYTE_READ),             // output
    .BYTE_ERROR_CODE(Receiver_BYTE_ERROR_CODE), // output
    .BYTE_READY(Receiver_BYTE_READY),           // output
    .STATE(Receiver_STATE)
);


// 1MHz clock for ILA capture
MouseCounter # (
.WIDTH(8),
.MAX(100)
) chopper (
.CLK(CLK),
.RESET(1'h0),
.EN(1'h1),
.TRIG_OUT(CLK_1M),
.COUNT()
);

// ILA debugger instantiation
ila_0 u_ila_0 (
	.clk(CLK),                                 // input wire clk
	.probe0(RESET),                            // input wire [0:0]  probe0  
	.probe1(CLK_MOUSE),                        // input wire [0:0]  probe1 
	.probe2(DATA_MOUSE),                       // input wire [0:0]  probe2 
	.probe3(Receiver_BYTE_ERROR_CODE),         // input wire [1:0]  probe3 
	.probe4(MASTER_STATE_CODE),                // input wire [3:0]  probe4 
	.probe5(Transmitter_BYTE_TO_SEND),         // input wire [7:0]  probe5 
	.probe6(Receiver_BYTE_READ),               // input wire [7:0]  probe6
	.probe7(CLK_1M),                           // input wire [0:0] probe7
	.probe8(Receiver_STATE),
	.probe9(Transmitter_STATE),
	.probe10(MOUSE_DX),
	.probe11(MOUSE_DY)
);
    
    
endmodule