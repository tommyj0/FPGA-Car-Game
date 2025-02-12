`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2025 03:31:29 PM
// Design Name: 
// Module Name: MasterSM_tb
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


module MasterSM_tb();

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

localparam RESET_BYTE = 8'hFF;
localparam RESET_ACK_BYTE = 8'hFA;
localparam SELF_TEST_PASSED_BYTE = 8'hAA;
localparam MOUSE_ID_BYTE = 8'h00;
localparam START_TRANS_BYTE = 8'hF4;
localparam START_TRANS_ACK_BYTE_1 = 8'hF4;
localparam START_TRANS_ACK_BYTE_2 = 8'hFA;

// configure inputs
reg         CLK = 'b0;
reg         RESET = 'b1;

reg         BYTE_SENT = 'b0;

reg [7:0]   BYTE_READ = 'h0;
reg [1:0]   BYTE_ERROR_CODE = 'h0;
reg         BYTE_READY = 'h0;

// configure outputs
wire        SEND_BYTE;
wire [7:0]  BYTE_TO_SEND;
wire        READ_ENABLE;

wire [7:0]  MOUSE_DX;
wire [7:0]  MOUSE_DY;
wire [7:0]  MOUSE_STATUS;
wire [3:0]  MASTER_STATE_CODE;
wire        SEND_INTERRUPT;

initial
    forever #5 CLK = ~CLK;
    
initial 
begin
    #100 RESET = 'b0;
end

// Cycle through every state providing correct inputs
always@(posedge CLK)
begin
    if (~RESET)
    begin

        case(MASTER_STATE_CODE)
        STATE_RESET:
        begin
            if (SEND_BYTE)
            begin
                #100 BYTE_SENT = 1'b1;
                #50 BYTE_SENT = 1'b0;
            end
        end
        STATE_RESET_ACK:
        begin
            if (READ_ENABLE)
            begin
                BYTE_READ = RESET_ACK_BYTE;
                BYTE_READY = 'h1;
                #20 BYTE_READY = 'h0;
            end
            else
            begin
                BYTE_READ = 'h0;
                BYTE_READY = 'h0;
            end
        end
        STATE_SELF_TEST:
        begin
            if (READ_ENABLE)
            begin
                BYTE_READ = SELF_TEST_PASSED_BYTE;
                BYTE_READY = 'h1;
                #20 BYTE_READY = 'h0;
            end
            else
            begin
                BYTE_READ = 'h0;
                BYTE_READY = 'h0;
            end
        end
        STATE_CHECK_ID:
        begin
            if (READ_ENABLE)
            begin
                BYTE_READ = MOUSE_ID_BYTE;
                BYTE_READY = 'h1;
                #20 BYTE_READY = 'h0;
            end
            else
            begin
                BYTE_READ = 'h0;
                BYTE_READY = 'h0;
            end
        end
        STATE_START_TRANS:
        begin
            if (SEND_BYTE)
            begin
                #100 BYTE_SENT = 1'b1;
                #50 BYTE_SENT = 1'b0;
            end
        end
        STATE_START_TRANS_ACK:
        begin
            if (READ_ENABLE)
            begin
                BYTE_READ = START_TRANS_ACK_BYTE_1;
                BYTE_READY = 'h1;
                #20 BYTE_READY = 'h0;
            end
            else
            begin
                BYTE_READ = 'h0;
                BYTE_READY = 'h0;
            end
        end
        STATE_READ_STATUS:
        begin
            if (READ_ENABLE)
            begin
                BYTE_READ = $random;
                BYTE_READ[3] = 1'b1;
                BYTE_READY = 'h1;
                #20 BYTE_READY = 'h0;
            end
            else
            begin
                BYTE_READ = 'h0;
                BYTE_READY = 'h0;
            end
        end
        STATE_READ_X:
        begin
            if (READ_ENABLE)
            begin
                BYTE_READ = $random;
                BYTE_READY = 'h1;
                #20 BYTE_READY = 'h0;
            end
            else
            begin
                BYTE_READ = 'h0;
                BYTE_READY = 'h0;
            end
        end
        STATE_READ_Y:
        begin
             if (READ_ENABLE)
             begin
                 BYTE_READ = $random;
                 BYTE_READY = 'h1;
                 #20 BYTE_READY = 'h0;
                 $display("\nCOMPLETED SM\n");
                 $finish;
             end
             else
             begin
                 BYTE_READ = 'h0;
                 BYTE_READY = 'h0;
             end

        end
        default:
        begin
            $display("\nIncorrect State Reached\n TEST FAILED\n"); 
            $finish;
        end
        endcase
    end

end
    



MouseMasterSM DUT (
    .CLK(CLK),                                  // input
    .RESET(RESET),                              // input
    // Transmitter    
    .SEND_BYTE(SEND_BYTE),          // output
    .BYTE_TO_SEND(BYTE_TO_SEND),    // output
    .BYTE_SENT(BYTE_SENT),          // input
    // Receiver  
    .READ_ENABLE(READ_ENABLE),         // output
    .BYTE_READ(BYTE_READ),             // input
    .BYTE_ERROR_CODE(BYTE_ERROR_CODE), // input
    .BYTE_READY(BYTE_READY),           // input
    // Data Registers
    .MOUSE_DX(MOUSE_DX),                        // output
    .MOUSE_DY(MOUSE_DY),                        // output   
    .MOUSE_STATUS(MOUSE_STATUS),                // output
    .MASTER_STATE_CODE(MASTER_STATE_CODE),
    .SEND_INTERRUPT(SEND_INTERRUPT)             // output
);


endmodule
