`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2025 04:42:21 PM
// Design Name: 
// Module Name: trans_tb
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
// Test Bench for the transmitter module
//////////////////////////////////////////////////////////////////////////////////


module trans_tb();
    
// Define Inputs
reg CLK = 0;
reg RESET = 1;
reg CLK_MOUSE_reg = 'h1;
reg DATA_MOUSE_reg = 1'h1;
reg [7:0] BYTE_TO_SEND = 'h0;
reg SEND_BYTE = 'b0;

// Define outputs
wire DATA_MOUSE_TRANS;
wire DATA_MOUSE_OUT_EN;
wire CLK_MOUSE_OUT_EN;
wire BYTE_SENT;
wire DATA_MOUSE_OUT;
wire CLK_MOUSE;
wire CLK_MOUSE_TRANS;
wire DATA_MOUSE;

// Continuous Assignments
assign CLK_MOUSE = CLK_MOUSE_OUT_EN ? 'h0 : CLK_MOUSE_reg;
assign DATA_MOUSE = DATA_MOUSE_OUT_EN ? DATA_MOUSE_OUT_TRANS : DATA_MOUSE_reg;

// Mouse CLK gen
initial begin
//    #150000
    forever #30000 CLK_MOUSE_reg = ~CLK_MOUSE_reg;
end

// CLK gen
initial
    forever #5 CLK = ~CLK;
    
// Main loop
initial 
begin
    $display("Starting Mouse Transmitter Test...");
    #100 RESET = 0;
    for (integer i = 0; i < 20; i = i + 1)
    begin
        #1000 SEND_BYTE = 'h1;
        BYTE_TO_SEND = $random;
        #1000000    DATA_MOUSE_reg = 1'h0;
        #100000     DATA_MOUSE_reg = 1'h1;
        #100        SEND_BYTE = 'h0;
    end
    #100000     $finish;
end



// instantiation
MouseTransmitter u_trans (
    .RESET(RESET),
    .CLK(CLK),
    .CLK_MOUSE_IN(CLK_MOUSE),
    .CLK_MOUSE_OUT_EN(CLK_MOUSE_OUT_EN),
    .DATA_MOUSE_IN(DATA_MOUSE),
    .DATA_MOUSE_OUT(DATA_MOUSE_OUT_TRANS),
    .DATA_MOUSE_OUT_EN(DATA_MOUSE_OUT_EN),
    .SEND_BYTE(SEND_BYTE),
    .BYTE_TO_SEND(BYTE_TO_SEND),
    .BYTE_SENT(BYTE_SENT)
);

endmodule
