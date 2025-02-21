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
// Completes the transmission cycle of the PS2 protocol
// Controlled by the Master SM
//////////////////////////////////////////////////////////////////////////////////



module MouseTransmitter(
    input           RESET,
    input           CLK,
    input           CLK_MOUSE_IN,
    output          CLK_MOUSE_OUT_EN,
    input           DATA_MOUSE_IN,
    output          DATA_MOUSE_OUT,
    output          DATA_MOUSE_OUT_EN,
    input           SEND_BYTE,
    input [7:0]     BYTE_TO_SEND,
    output          BYTE_SENT,
    output [3:0]    STATE
);

// state parameters
localparam STATE_IDLE          = 'd0;
localparam STATE_HOST_CLK_LOW  = 'd1;
localparam STATE_HOST_DATA_LOW = 'd2;
localparam STATE_HOST_CLK_Z    = 'd3;
localparam STATE_DEV_CLK_LOW   = 'd4;
localparam STATE_TRANS_DATA    = 'd6;
localparam STATE_TRANS_ACK_H   = 'd7;
localparam STATE_TRANS_ACK_L   = 'd8;

// Sequential Registers
reg [3:0]   Curr_State;
reg         Curr_CLK_MOUSE_OUT_EN;
reg         Curr_DATA_MOUSE_OUT;
reg         Curr_DATA_MOUSE_OUT_EN;
reg         Curr_BYTE_SENT;
reg  [3:0]  Curr_data_index;
reg         Curr_Hold_Counter_RESET;



// Combinational Registers
reg [3:0]   Next_State;
reg         Next_CLK_MOUSE_OUT_EN;
reg         Next_DATA_MOUSE_OUT;
reg         Next_DATA_MOUSE_OUT_EN;
reg         Next_BYTE_SENT;
reg  [3:0]  Next_data_index;
reg         Next_Hold_Counter_RESET;

// wires
wire [13:0] Hold_Counter_COUNT;
wire [10:0] data_transmit;

MouseCounter# (
    .MAX(15000),
    .WIDTH(14)
) HoldCounter (
    .CLK(CLK),
    .RESET(Curr_Hold_Counter_RESET),
    .EN(1'b1),
    .COUNT(Hold_Counter_COUNT),
    .TRIG_OUT()
);

reg             CLK_MOUSE_DLY;
reg             CLK_MOUSE_DLY_DLY;
wire    falling_edge;

always@(posedge CLK)
begin
    CLK_MOUSE_DLY <= CLK_MOUSE_IN;
    CLK_MOUSE_DLY_DLY <= CLK_MOUSE_DLY;
end

assign  falling_edge = ~CLK_MOUSE_DLY & CLK_MOUSE_DLY_DLY;


// Combinational Block
always@(*) 
begin
    Next_data_index = Curr_data_index;
    Next_State = Curr_State;
    Next_CLK_MOUSE_OUT_EN = Curr_CLK_MOUSE_OUT_EN; 
    Next_DATA_MOUSE_OUT_EN = Curr_DATA_MOUSE_OUT_EN; 
    Next_DATA_MOUSE_OUT = Curr_DATA_MOUSE_OUT; 
    Next_BYTE_SENT = 'h0; 
    Next_Hold_Counter_RESET = 'h0;
    case(Curr_State)
        STATE_IDLE: 
        begin
            Next_data_index = 'h0;
            Next_CLK_MOUSE_OUT_EN = 'h0; 
            Next_DATA_MOUSE_OUT_EN = 'h0; 
            Next_DATA_MOUSE_OUT = 'h0; 
            Next_BYTE_SENT = 'h0; 
            Next_Hold_Counter_RESET = 'h1;
            if (SEND_BYTE)
            begin
                Next_State = STATE_HOST_CLK_LOW;
            end
        end
        
        STATE_HOST_CLK_LOW:  // Pull CLK low for 120us
        begin
            Next_CLK_MOUSE_OUT_EN = 1'h1;
//            Next_Hold_Counter_RESET = 1'h0;
            if (Hold_Counter_COUNT >= 12000) 
            begin
                Next_Hold_Counter_RESET = 1'h1;
                Next_State = STATE_HOST_DATA_LOW;
            end
            else
            begin
                Next_Hold_Counter_RESET = 1'h0;
            end
        end
        
        STATE_HOST_DATA_LOW:  // Pull Data Low and Release CLK
        begin
            Next_CLK_MOUSE_OUT_EN = 1'h0;
            Next_DATA_MOUSE_OUT_EN = 1'h1;
            Next_DATA_MOUSE_OUT = 1'h0;
            Next_Hold_Counter_RESET = 1'h1;
            Next_State = STATE_TRANS_DATA;
        end
        STATE_TRANS_DATA: // Ensure CLK  hi
        begin
            Next_DATA_MOUSE_OUT_EN = 1'h1;
            if (Curr_data_index >= 'hb)
            begin
                Next_DATA_MOUSE_OUT_EN = 1'h0;  
                Next_CLK_MOUSE_OUT_EN = 1'h0;
                Next_State = STATE_TRANS_ACK_H;
            end
            else if (falling_edge)
            begin
                Next_Hold_Counter_RESET = 1'h1;
                Next_State = STATE_TRANS_DATA;
            end
            else if (Hold_Counter_COUNT == 1500)
            begin
                Next_Hold_Counter_RESET = 1'h0;
                Next_DATA_MOUSE_OUT = data_transmit[Curr_data_index]; // Data Update here
                Next_data_index = Curr_data_index + 1;
            end
        end
         STATE_TRANS_ACK_H: // Wait for Start of ACK
         begin
            Next_DATA_MOUSE_OUT_EN = 1'h0;
            Next_CLK_MOUSE_OUT_EN = 1'h0;
            if (~DATA_MOUSE_IN && ~CLK_MOUSE_IN) 
            begin
                Next_State = STATE_TRANS_ACK_L;
            end
         end
         STATE_TRANS_ACK_L: // Confirm end of ACK
         begin
            if (SEND_BYTE == 1'h0) // wait for release
                Next_State = STATE_IDLE;
            if (DATA_MOUSE_IN && CLK_MOUSE_IN)
            begin
                Next_BYTE_SENT = 1'h1;
            end
        end     
        default:
            Next_State = STATE_IDLE;
    endcase
end

// Sequential Block
always@(posedge CLK)
begin
    if (RESET)
    begin
        Curr_State <= STATE_IDLE;
        Curr_CLK_MOUSE_OUT_EN <= 'b0;
        Curr_DATA_MOUSE_OUT <= 'b0;
        Curr_DATA_MOUSE_OUT_EN <= 'b0;
        Curr_BYTE_SENT <= 'b0;
        Curr_data_index <= 'b0;
        Curr_Hold_Counter_RESET <= 'b0;
    end
    else
    begin
        Curr_State <= Next_State;
        Curr_CLK_MOUSE_OUT_EN <= Next_CLK_MOUSE_OUT_EN;
        Curr_DATA_MOUSE_OUT <= Next_DATA_MOUSE_OUT;
        Curr_DATA_MOUSE_OUT_EN <= Next_DATA_MOUSE_OUT_EN;
        Curr_BYTE_SENT <= Next_BYTE_SENT;
        Curr_data_index <= Next_data_index;
        Curr_Hold_Counter_RESET <= Next_Hold_Counter_RESET;

    end
end

// assign outputs
assign STATE = Curr_data_index;
assign data_transmit = {1'h1,~(^BYTE_TO_SEND), BYTE_TO_SEND, 1'h0};
assign CLK_MOUSE_OUT_EN = Curr_CLK_MOUSE_OUT_EN;
assign DATA_MOUSE_OUT = Curr_DATA_MOUSE_OUT;
assign DATA_MOUSE_OUT_EN = Curr_DATA_MOUSE_OUT_EN;
assign BYTE_SENT = Curr_BYTE_SENT;

endmodule