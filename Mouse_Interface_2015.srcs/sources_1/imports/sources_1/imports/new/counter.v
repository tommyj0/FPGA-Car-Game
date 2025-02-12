`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2024 10:19:32 PM
// Design Name: 
// Module Name: counter
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


module MouseCounter(
        CLK,
        RESET,
        EN,
        TRIG_OUT,
        COUNT
    );
    
    // Define Parameters
    parameter WIDTH = 4;
    parameter MAX = 9;
    
    // Define Inputs
    input CLK;
    input RESET;
    input EN;
    // Define Outputs
    output TRIG_OUT;
    output [WIDTH-1:0] COUNT;
    
    // Define Sequential Regs
    reg [WIDTH-1:0] count_value;
    reg Trigger_out;
    
    // Calculate Count Value
    always@(posedge CLK) begin
        if(RESET)
            count_value <= 0;
        else begin
            if (EN) begin
                if (count_value == MAX)
                    count_value <= 0;
                else
                    count_value <= count_value + 1;
            end
        end
    end
    
    // Calculate Trig Out
    always@(posedge CLK) begin
        if(RESET) 
            Trigger_out <= 0;
        else begin
            if (EN &&(count_value == MAX))
                Trigger_out <= 1;
            else
                Trigger_out <= 0;
        end
    end
    
    // Continuous Assignments
    assign COUNT = count_value;
    assign TRIG_OUT = Trigger_out;

endmodule
