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



module MouseReceiver(
    input               RESET,
    input               CLK,
    input               CLK_MOUSE_IN,
    input               DATA_MOUSE_IN,
    input               READ_ENABLE,
    output [7:0]        BYTE_READ,
    output [1:0]        BYTE_ERROR_CODE,
    output              BYTE_READY,
    output [3:0]        STATE
);

// define state parameters
localparam STATE_IDLE        = 4'd0;
localparam STATE_READ        = 4'd2;

// define error codes
localparam NO_ERROR          = 2'd0;
localparam ERROR_START_BIT   = 2'd1;
localparam ERROR_PARITY      = 2'd2;
localparam ERROR_STOP_BIT    = 2'd3;

// Sequential Regs
reg             Curr_BYTE_READY;
reg  [7:0]      Curr_BYTE_READ;
reg  [1:0]      Curr_BYTE_ERROR_CODE;
reg  [3:0]      Curr_State;
reg  [3:0]      Curr_bit_counter; 
reg             Curr_TIMER_RESET;
reg             CLK_MOUSE_DLY;
reg             CLK_MOUSE_DLY_DLY;

// Combinational Regs
reg             Next_BYTE_READY;
reg  [7:0]      Next_BYTE_READ;
reg  [1:0]      Next_BYTE_ERROR_CODE;
reg  [3:0]      Next_State;
reg  [3:0]      Next_bit_counter; 
reg             Next_TIMER_RESET;

// wires
wire            parity_bit;
wire            falling_edge;

// Reset Counter for stuck states
MouseCounter # (
    .WIDTH(27),
    .MAX(100000)
) ResetTimer (
    .CLK(CLK),
    .RESET(Curr_TIMER_RESET),
    .EN(1'h0),
    .TRIG_OUT(TIMER_TRIG),
    .COUNT()
);
always@(posedge CLK)
begin
    CLK_MOUSE_DLY <= CLK_MOUSE_IN;
    CLK_MOUSE_DLY_DLY <= CLK_MOUSE_DLY;
end
    
// continuous assignment of wires
assign parity_bit = ~(^BYTE_READ);
assign falling_edge = ~CLK_MOUSE_DLY & CLK_MOUSE_DLY_DLY;

// Combinational Logic
always@(*) 
begin
    // initial values
    Next_BYTE_READ = Curr_BYTE_READ;
    Next_BYTE_ERROR_CODE = 'h0;
    Next_BYTE_READY = Curr_BYTE_READY;
    Next_bit_counter = Curr_bit_counter;
    Next_State = Curr_State;
    Next_TIMER_RESET = 'b1;

    case(Curr_State) 
        STATE_IDLE: // Wait for READ_ENABLE
        begin
            Next_BYTE_READ = 'h0;
            Next_BYTE_ERROR_CODE = 'h0;
            Next_BYTE_READY = 'h0;
            Next_bit_counter = 'h0;
            Next_TIMER_RESET = 'h1;
            if (CLK_MOUSE_IN && READ_ENABLE)
                Next_State = STATE_READ;
        end
        
        STATE_READ:   // Check counter at CLK lo
        begin
            Next_TIMER_RESET = 'h0;
            if (TIMER_TRIG)
                Next_State = STATE_IDLE;
            else if (falling_edge)
            begin
                Next_bit_counter = Curr_bit_counter + 1;
                Next_TIMER_RESET = 'h1;
                if (Curr_bit_counter == 'b0)
                begin
                    if (DATA_MOUSE_IN)
                    begin
                        Next_BYTE_ERROR_CODE = ERROR_START_BIT;
                        Next_BYTE_READY = 1'h1;
                        Next_State = STATE_IDLE;
                    end
                end
                else if (Curr_bit_counter < 'h9)
                    Next_BYTE_READ = {DATA_MOUSE_IN,Curr_BYTE_READ[7:1]}; // Update Shift Reg
                else if (Curr_bit_counter == 'h9)
                begin
                    if (DATA_MOUSE_IN != parity_bit)
                    begin                      
                        Next_BYTE_READY = 1'h1;
                        Next_BYTE_ERROR_CODE = ERROR_PARITY;
                        Next_State = STATE_IDLE;
                    end
                end
                else
                begin
                    Next_BYTE_READY = 1'h1;
                    if (DATA_MOUSE_IN)
                        Next_State = STATE_IDLE;
                    else 
                        Next_BYTE_ERROR_CODE = ERROR_STOP_BIT;
                end        
            end 
        end

        default:        // return to idle in default case
            Next_State = STATE_IDLE;
    endcase    
end

// Sequential Logic
always@(posedge CLK)
begin
    if (RESET)
    begin
        Curr_State <= STATE_IDLE;
        Curr_BYTE_READY <= 'h0;
        Curr_BYTE_READ <= 'h0;
        Curr_BYTE_ERROR_CODE <= 'h0;
        Curr_bit_counter <= 'h0; 
        Curr_TIMER_RESET <= 'h1;
    end
    else
    begin
        Curr_State <= Next_State;
        Curr_BYTE_READY <= Next_BYTE_READY;
        Curr_BYTE_READ <= Next_BYTE_READ;
        Curr_BYTE_ERROR_CODE <= Next_BYTE_ERROR_CODE;
        Curr_bit_counter <= Next_bit_counter;
        Curr_TIMER_RESET <= Next_TIMER_RESET;
    end 
end

// Continuous Assignment of Outputs
assign BYTE_READ = Curr_BYTE_READ;
assign BYTE_READY = Curr_BYTE_READY;
assign BYTE_ERROR_CODE = Curr_BYTE_ERROR_CODE;
assign STATE = Curr_bit_counter;


endmodule
