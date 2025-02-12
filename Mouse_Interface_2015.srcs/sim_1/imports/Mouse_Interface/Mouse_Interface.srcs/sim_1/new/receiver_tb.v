`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2025 01:25:19 PM
// Design Name: 
// Module Name: receiver_tb
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
// Testbench to test the functionality of the Receiver Module
//
//
//////////////////////////////////////////////////////////////////////////////////


module receiver_tb();

// configure testbench values
parameter [11:0] iters = 'd20; // set number of tests to run


integer passed_tests = 'd0;
integer j;

reg [7:0]   BYTE_TO_RECEIVE = 8'b10010110;
reg [3:0]   bit_counter = 'h0;
wire [10:0] PACKET_TO_RECEIVE;


// configure inputs
reg         CLK = 'b0;
reg         RESET = 'b1;
reg         READ_ENABLE = 'b0;
reg         CLK_MOUSE_IN = 'b1;
reg         DATA_MOUSE_IN = 'b0;


// configure outputs
wire [7:0]  BYTE_READ;
wire        BYTE_READY;
wire [1:0]  BYTE_ERROR_CODE;
wire [3:0]  STATE;


// continuous assignments
assign PACKET_TO_RECEIVE = {1'h1,~(^BYTE_TO_RECEIVE), BYTE_TO_RECEIVE, 1'h0};


MouseReceiver u_MouseReceiver(
    .RESET(RESET),                              // input    1b
    .CLK(CLK),                                  // input    1b
    .CLK_MOUSE_IN(CLK_MOUSE_IN),                // input    1b
    .DATA_MOUSE_IN(DATA_MOUSE_IN),              // input    1b 
    .READ_ENABLE(READ_ENABLE),                  // input    1b
    .BYTE_READ(BYTE_READ),                      // output   7b
    .BYTE_ERROR_CODE(BYTE_ERROR_CODE),          // output   2b
    .BYTE_READY(BYTE_READY),                    // output   1b
    .STATE(STATE)                               // output   4b
);

// clk setup
initial
    forever #5 CLK = ~CLK;
    

initial
begin
    $display("Starting Receiver Functionality Test");

    #40 RESET = 1'b0;
    #60 READ_ENABLE = 1'b1;
    #100;
    for (j=0; j < iters; j = j + 1)
    begin
        BYTE_TO_RECEIVE = $random; // Randomise received byte for each test
        for (integer i=0; i < 11; i = i + 1)
        begin
            #20  DATA_MOUSE_IN = PACKET_TO_RECEIVE[i];
            #100 CLK_MOUSE_IN = 'b0;
            #100 CLK_MOUSE_IN = 'b1;
        end
    end
    #200;
    // print # of tests passed
    $display("\n\n######################\n COVERAGE = %d % \n######################\n\n",100*passed_tests/iters );

    $finish;
end


always@(posedge CLK)
begin
    if (~RESET)
    begin
        while (~BYTE_READY)
            #1;
        if (BYTE_READY && BYTE_READ == BYTE_TO_RECEIVE)
        begin
            passed_tests = passed_tests + 1;
            $display("######################\nTEST %d PASSED\n",j + 1);
        end
        else
        begin
            $display("######################\nTEST %d FAILED\n",j + 1);
        end  
        while(BYTE_READY)
            #1;  
    end

end
    
endmodule
