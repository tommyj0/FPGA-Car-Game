`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2025 12:46:44
// Design Name: 
// Module Name: Processor
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


module ALU(
    //standard signals
    input CLK,
    input RESET,
    //I/O
    input [7:0] IN_A, 
    input [7:0] IN_B, 
    input [3:0] ALU_Op_Code, 
    output [7:0] OUT_RESULT
);
// ALU output
reg [7:0] Out;

//Arithmetic Computation
always@(posedge CLK)
begin
    if(RESET)
        Out <= 0;
    else begin
        case (ALU_Op_Code)
            //Maths Operations
            //Add A + B
            4'h0: Out <= IN_A + IN_B;
            //Subtract A - B
            4'h1: Out <= IN_A - IN_B;
            //Multiply A * B
            4'h2: Out <= IN_A * IN_B;
            ////////////////////////////////////////////////////////////////////////////
            // Implementation changed from original to shift by regB, rather than by 1
            // This is useful in cases where multiple shifts must occur, which can now be 
            // done in much fewer lines.
            // The original functionality is preserved through the immediate maths mode,
            // albeit using one more byte than before.
            //Shift Left A << B
            4'h3: Out <= IN_A << IN_B;
            //Shift Right A >> B
            4'h4: Out <= IN_A >> IN_B;
            //Increment A+1
            4'h5: Out <= IN_A + 1'b1;
            //Increment B+1
            4'h6: Out <= IN_B + 1'b1;
            //Decrement A-1
            4'h7: Out <= IN_A - 1'b1;
            //Decrement B-1
            4'h8: Out <= IN_B - 1'b1;
            // In/Equality Operations
            //A == B
            4'h9: Out <= (IN_A == IN_B) ? 8'h01 : 8'h00;
            //A > B
            4'hA: Out <= (IN_A > IN_B) ? 8'h01 : 8'h00;
            //A < B
            4'hB: Out <= (IN_A < IN_B) ? 8'h01 : 8'h00;
            // Additional Logic Functions
            // NOT ~A
            4'hC: Out <= ~IN_A;
            // AND A & B
            4'hD: Out <= IN_A & IN_B;
            // OR A | B
            4'hE: Out <= IN_A | IN_B;
            // XOR A ^ B
            4'hF: Out <= IN_A ^ IN_B;
            //Default A
            default: Out <= IN_A;
        endcase
    end
end
assign OUT_RESULT = Out;
endmodule
