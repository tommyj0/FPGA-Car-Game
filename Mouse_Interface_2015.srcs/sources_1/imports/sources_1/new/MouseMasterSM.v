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

module MouseMasterSM (
    input               CLK,
    input               RESET,
    // Transmitter Control
    output           SEND_BYTE,
    output  [7:0]    BYTE_TO_SEND,
    input               BYTE_SENT,
    // Receiver Control
    output           READ_ENABLE,
    input [7:0]         BYTE_READ,
    input [1:0]         BYTE_ERROR_CODE,
    input               BYTE_READY,
    // Data Registers
    output  [7:0]       MOUSE_DX,
    output  [7:0]       MOUSE_DY,
    output  [7:0]       MOUSE_STATUS,
    output [3:0]        MASTER_STATE_CODE, 
    output              SEND_INTERRUPT
);

// define state parameters
localparam STATE_RESET            = 4'd0;
localparam STATE_RESET_ACK        = 4'd1;
localparam STATE_SELF_TEST        = 4'd2;
localparam STATE_CHECK_ID         = 4'd3;
localparam STATE_START_TRANS      = 4'd4;
localparam STATE_START_TRANS_ACK  = 4'd5;
localparam STATE_READ_STATUS      = 4'd6;
localparam STATE_READ_X           = 4'd7;
localparam STATE_READ_Y           = 4'd8;

// Define TRANSMIT/RECEIVE BITS
localparam RESET_BYTE = 8'hFF;
localparam RESET_ACK_BYTE = 8'hFA;
localparam SELF_TEST_PASSED_BYTE = 8'hAA;
localparam MOUSE_ID_BYTE = 8'h00;
localparam START_TRANS_BYTE = 8'hF4;
localparam START_TRANS_ACK_BYTE_1 = 8'hF4;
localparam START_TRANS_ACK_BYTE_2 = 8'hFA;

// Sequential Regs
reg [3:0]   Curr_State;
reg         Curr_TIMER_RESET;
reg         Curr_SEND_BYTE;
reg [7:0]   Curr_BYTE_TO_SEND;
reg         Curr_READ_ENABLE;
reg [7:0]   Curr_MOUSE_DX;
reg [7:0]   Curr_MOUSE_DY;
reg [7:0]   Curr_MOUSE_STATUS;
reg         Curr_SEND_INTERRUPT;

// Combinational Regs
reg [3:0]   Next_State;
reg         Next_TIMER_RESET;
reg         Next_SEND_BYTE;
reg [7:0]   Next_BYTE_TO_SEND;
reg         Next_READ_ENABLE;
reg [7:0]   Next_MOUSE_DX;
reg [7:0]   Next_MOUSE_DY;
reg [7:0]   Next_MOUSE_STATUS;
reg         Next_SEND_INTERRUPT;

// Reset Timer
MouseCounter # (
    .WIDTH(27),
    .MAX(10000000)
) ResetTimerSM (
    .CLK(CLK),
    .RESET(Curr_TIMER_RESET),
    .EN(1'h1),
    .TRIG_OUT(TIMER_TRIG),
    .COUNT()
);

// Combinational Block
always@(*) 
begin
        // Set Default Values
        Next_MOUSE_DX = Curr_MOUSE_DX;
        Next_MOUSE_DY = Curr_MOUSE_DY;
        Next_MOUSE_STATUS = Curr_MOUSE_STATUS;
        Next_SEND_INTERRUPT = 'b0;
        Next_READ_ENABLE = Curr_READ_ENABLE;
        Next_SEND_BYTE = Curr_SEND_BYTE;
        Next_BYTE_TO_SEND = Curr_BYTE_TO_SEND;
        Next_State = Curr_State;
        Next_TIMER_RESET = Curr_TIMER_RESET;
        case(Curr_State)
            STATE_RESET: // Send RESET BYTE
            begin
                Next_TIMER_RESET = 'h1;
                Next_SEND_INTERRUPT = 'h0;
                Next_READ_ENABLE = 1'h0;
                Next_SEND_BYTE = 1'h1;
                Next_BYTE_TO_SEND = RESET_BYTE;
                if (BYTE_SENT) 
                begin
                    Next_State = STATE_RESET_ACK;
                    Next_SEND_BYTE = 'h0;
                    Next_BYTE_TO_SEND = 'h0;
                end
            end
            
            STATE_RESET_ACK: // Wait for RESET ACK BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_SEND_BYTE = 1'h0;
                    Next_READ_ENABLE = 1'h1;
                    if (BYTE_READY) begin 
                        Next_TIMER_RESET =1'h1;
                        if (BYTE_READ == RESET_ACK_BYTE && BYTE_ERROR_CODE == 2'h0) begin
                            Next_State = STATE_SELF_TEST;
                        end
                        else
                            Next_State = STATE_RESET;
                    end
                    else
                        Next_TIMER_RESET = 1'h0;
                end
            end
            
            STATE_SELF_TEST: // Wait for SELF TEST PASSED BYTE 
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_SEND_BYTE = 1'h0;
                    Next_READ_ENABLE = 1'h1;
                    if (BYTE_READY)
                    begin
                        Next_TIMER_RESET = 1'h1;
                        if (BYTE_READ == SELF_TEST_PASSED_BYTE && BYTE_ERROR_CODE == 2'h0) 
                            Next_State = STATE_CHECK_ID;
                        else
                            Next_State = STATE_RESET;
                    end             
                    else
                    begin
                        Next_TIMER_RESET = 1'h0;
                    end     
                end        
            end
            
            STATE_CHECK_ID: // Wait for MOUSE ID BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_READ_ENABLE = 1'h1;
                    if (BYTE_READY)
                    begin
                        Next_TIMER_RESET = 1'h1;
                        if (BYTE_READ == MOUSE_ID_BYTE && BYTE_ERROR_CODE == 'h0) 
                        begin
                            Next_State = STATE_START_TRANS;
                        end   
                        else
                            Next_State = STATE_RESET;
                    end
                    else
                    begin
                        Next_TIMER_RESET = 1'h0;
                    end
                end
            end     
            
            STATE_START_TRANS: // Send Start TRANS BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_READ_ENABLE = 1'h0;
                    if (BYTE_SENT) 
                    begin
                        Next_SEND_BYTE = 'h0;
                        Next_BYTE_TO_SEND = 'h0;
                        Next_State = STATE_START_TRANS_ACK;
                    end
                    else
                    begin
                        Next_BYTE_TO_SEND = 8'hF4;
                        Next_SEND_BYTE = 1'h1;
                    end
                end
            end
            
            STATE_START_TRANS_ACK: // Wait for TRANS ACK BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_READ_ENABLE = 1'h1;
                    if (BYTE_READY)
                    begin
    //                    Next_READ_ENABLE = 'h0;
                        Next_TIMER_RESET = 1'h1;
                        if  ((BYTE_READ == START_TRANS_ACK_BYTE_1 || BYTE_READ == START_TRANS_ACK_BYTE_2) && BYTE_ERROR_CODE == 2'h0) 
                        begin
                            Next_State = STATE_READ_STATUS;
                        end    
                        else
                            Next_State = STATE_RESET;
                    end
                    else
                        Next_TIMER_RESET = 1'h0;
                end
            end
            
            STATE_READ_STATUS: // Read the STATUS BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_READ_ENABLE = 1'h1;
                    Next_SEND_INTERRUPT = 1'h0;
                    if (BYTE_READY)
                    begin
                        Next_READ_ENABLE = 1'h0;
                        Next_TIMER_RESET = 'h1;
                        if (BYTE_READ[3] && BYTE_ERROR_CODE == 2'h0) 
                        begin
                            Next_MOUSE_STATUS = BYTE_READ;
                            Next_State = STATE_READ_X;
                        end
                        else 
                        begin
                            Next_State = STATE_RESET;
                        end
                    end
                    else
                    begin
                        Next_READ_ENABLE = 1'h1;
                        Next_TIMER_RESET = 'h0;
                    end
                end
            end
           
            
            STATE_READ_X: // Read the X BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                    Next_READ_ENABLE = 1'h1;
                    if (BYTE_READY)
                    begin
                        Next_TIMER_RESET = 'h1;
                        if (BYTE_ERROR_CODE == 2'h0) begin
                            Next_MOUSE_DX = BYTE_READ;
                            Next_READ_ENABLE = 1'h0;
                            Next_State = STATE_READ_Y;
                        end
                        else if (BYTE_ERROR_CODE != 2'h0) begin
                            Next_State = STATE_RESET;
                        end
                    end
                    else
                        Next_TIMER_RESET = 'h0;
                end
            end
            
            STATE_READ_Y: // Read the Y BYTE
            begin
                if (TIMER_TRIG)
                    Next_State = STATE_RESET;
                else
                begin
                Next_READ_ENABLE = 1'h1;
                if (BYTE_READY)
                begin
                    Next_TIMER_RESET = 'h1;
                    if (BYTE_ERROR_CODE == 2'h0) 
                    begin
                        Next_MOUSE_DY = BYTE_READ;
                        Next_READ_ENABLE = 1'h0;
                        Next_State = STATE_READ_STATUS;
                        Next_SEND_INTERRUPT = 1'h1;
                    end
                    else if (BYTE_ERROR_CODE != 2'h0) begin
                        Next_State = STATE_RESET;
                    end
                end
                else
                    Next_TIMER_RESET = 'h0;


                end
            end
            default:
                Next_State = STATE_RESET;
        endcase
end

// Sequential Block
always@(posedge CLK)
begin
    if (RESET)
    begin
        Curr_State <= STATE_RESET;
        Curr_TIMER_RESET <= 'b0;
        Curr_SEND_BYTE <= 'b0;
        Curr_BYTE_TO_SEND <= 'b0;
        Curr_READ_ENABLE <= 'b0;
        Curr_MOUSE_DX <= 'b0;
        Curr_MOUSE_DY <= 'b0;
        Curr_MOUSE_STATUS <= 'b0;
        Curr_SEND_INTERRUPT <= 'b0;
    end
    else
    begin
        Curr_State <= Next_State;
        Curr_TIMER_RESET <= Next_TIMER_RESET;
        Curr_SEND_BYTE <= Next_SEND_BYTE;
        Curr_BYTE_TO_SEND <= Next_BYTE_TO_SEND;
        Curr_READ_ENABLE <= Next_READ_ENABLE;
        Curr_MOUSE_DX <= Next_MOUSE_DX;
        Curr_MOUSE_DY <= Next_MOUSE_DY;
        Curr_MOUSE_STATUS <= Next_MOUSE_STATUS;
        Curr_SEND_INTERRUPT <= Next_SEND_INTERRUPT;
    end
end

// assign outputs 
assign MASTER_STATE_CODE = Curr_State;
assign SEND_BYTE = Curr_SEND_BYTE;
assign BYTE_TO_SEND = Curr_BYTE_TO_SEND;
assign READ_ENABLE = Curr_READ_ENABLE;
assign MOUSE_DX = Curr_MOUSE_DX;
assign MOUSE_DY = Curr_MOUSE_DY;
assign MOUSE_STATUS = Curr_MOUSE_STATUS;
assign SEND_INTERRUPT = Curr_SEND_INTERRUPT;

endmodule
