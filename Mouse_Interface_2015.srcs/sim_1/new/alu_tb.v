`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 02:59:35 PM
// Design Name: 
// Module Name: alu_tb
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


module alu_tb();

parameter runs = 1000;


// set ALU pins
reg CLK = 'b0;
reg RESET = 'b1;
reg [7:0] AluIn_A;
reg [7:0] AluIn_B;
reg [3:0] AluOpCode = 0;
wire [7:0] AluOut;
// out from ALU task
reg [7:0] Out;

task ALU_CHECK;
    input [7:0] IN_A;
    input [7:0] IN_B;
    input [3:0] opcode;
    output [7:0] Out;
    begin
        case (opcode)
            //Maths Operations
            //Add A + B
            4'h0: Out = IN_A + IN_B;
            //Subtract A - B
            4'h1: Out = IN_A - IN_B;
            //Multiply A * B
            4'h2: Out = IN_A * IN_B;
            //////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Implementation of shifts have changed slightly from the original, instead of shifting one it shifts B.
            // the additional implementation of immediate math operations retains the "shift by one" functionality,
            // albeit using an extra immediate byte. This slight tradeoff is worth it when considering the VGA section
            // where shift by 7 is common
            //Shift Left A << B
            4'h3: Out = IN_A << IN_B; 
            //Shift Right A >> B
            4'h4: Out = IN_A >> IN_B;
            //Increment A+1
            4'h5: Out = IN_A + 1'b1;
            //Increment B+1
            4'h6: Out = IN_B + 1'b1;
            //Decrement A-1
            4'h7: Out = IN_A - 1'b1;
            //Decrement B-1
            4'h8: Out = IN_B - 1'b1;
            // In/Equality Operations
            //A == B
            4'h9: Out = (IN_A == IN_B) ? 8'h01 : 8'h00;
            //A > B
            4'hA: Out = (IN_A > IN_B) ? 8'h01 : 8'h00;
            //A < B
            4'hB: Out = (IN_A < IN_B) ? 8'h01 : 8'h00;
            // Additional Logic Functions
            // NOT ~A
            4'hC: Out = ~IN_A;
            // AND A & B
            4'hD: Out = IN_A & IN_B;
            // OR A | B
            4'hE: Out = IN_A | IN_B;
            // XOR A ^ B
            4'hF: Out = IN_A ^ IN_B;
            //Default A
            default: Out = IN_A;
        endcase
    end
endtask

ALU ALU0(
    //standard signals
    .CLK(CLK),
    .RESET(RESET),
    //I/O
    .IN_A(AluIn_A),
    .IN_B(AluIn_B),
    .ALU_Op_Code(AluOpCode),
    .OUT_RESULT(AluOut)
);

initial 
    forever #5 CLK = ~CLK;

integer tests_passed = 0;

initial
begin
    $display("Starting ALU functionality test");
    #20 RESET = 'b0;
    
    for (integer i = 0; i < runs; i = i + 1)
    begin
        AluIn_A = $random;
        AluIn_B = $random;
        #20;
        ALU_CHECK(AluIn_A,AluIn_B,AluOpCode,Out);
        
        if (AluOut == Out)
            tests_passed = tests_passed + 1;
        AluOpCode = AluOpCode + 1;
        
    end
    #20;
    $display("Pass Rate = %2d / %2d", tests_passed, runs);
    $finish;
end

endmodule
