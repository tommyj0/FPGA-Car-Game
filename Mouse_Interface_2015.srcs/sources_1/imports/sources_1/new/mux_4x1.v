`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2025 04:33:00 PM
// Design Name: 
// Module Name: mux_4x1
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

module mux_4x1 ( 
        input [3:0] IN1,                    // 4-bit input
        input [3:0] IN2,                    // 4-bit input
        input [3:0] IN3,                    // 4-bit input
        input [3:0] IN4,                    // 4-bit input
        input [1:0] CTRL,                   // Control 
        output reg [3:0] OUT
        
);         

always @ (*) 
begin
  case (CTRL)
     2'b00 : OUT = IN1;
     2'b01 : OUT = IN2;
     2'b10 : OUT = IN3;
     2'b11 : OUT = IN4;
  endcase
end
   
endmodule
