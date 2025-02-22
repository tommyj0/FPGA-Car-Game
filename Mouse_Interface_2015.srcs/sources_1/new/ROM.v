`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2025 11:31:57 AM
// Design Name: 
// Module Name: ROM
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


module ROM(
    //standard signals
    input CLK,
    //BUS signals
    output reg [7:0] DATA,
    input [7:0] ADDR
);
parameter RAMAddrWidth = 8;
parameter INIT_FILE = "../../../rom.mem";
//Memory
reg [7:0] ROM [2**RAMAddrWidth-1:0];

// Load program
initial 
    $readmemh(INIT_FILE, ROM);

//single port ram
always@(posedge CLK)
    DATA <= ROM[ADDR];
endmodule