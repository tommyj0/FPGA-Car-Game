`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2025 04:25:57 PM
// Design Name: 
// Module Name: seg7_Driver
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


module seg7_Driver(
        // Standard Inputs
    input           RESET,
    input           CLK,
    // Bus I/O
    input  [7:0]    BUS_ADDR,
    inout  [7:0]    BUS_DATA,
    input           BUS_WE,
    // 7seg outputs
    output    [3:0]    SEG_SELECT_OUT,
    output        [7:0]    HEX_OUT
);


// 7-Seg wires
wire [1:0] StrobeCount;
wire [3:0] SEG_BIN;

// RAM address parameters
parameter RAMBaseAddr = 8'hD0;
parameter RAMSize = 'h2;


//Tristate
wire [7:0] BufferedBusData;
reg [7:0] Out;
reg RAMBusWE;
reg [7:0] Mem [0:1];

assign BufferedBusData = BUS_DATA;

//single port ram 
always@(posedge CLK)
begin
    // Brute-force RAM address decoding. Think of a simpler way...
    if ((BUS_ADDR >= RAMBaseAddr) & (BUS_ADDR < RAMBaseAddr + RAMSize)) 
    begin
        if(BUS_WE) // check that the bus is in write mode
        begin
            case(BUS_ADDR) // write to appropriate reg
                8'hD0: Mem[0] <= BufferedBusData;
                8'hD1: Mem[1] <= BufferedBusData;
            endcase
        end 
    end 
end


MouseCounter # (
    .MAX(10000),
    .WIDTH(20)
) CLK_10k (
    .CLK(CLK),
    .RESET(RESET),
    .EN(1'b1),
    .COUNT(),
    .TRIG_OUT(CLK_10k_TRIG)
);

MouseCounter # (
    .MAX(3),
    .WIDTH(2)
) StrobeCounter (
    .CLK(CLK),
    .RESET(RESET),
    .EN(CLK_10k_TRIG),
    .COUNT(StrobeCount),
    .TRIG_OUT()
);


seg7decoder u_seg7decoder(
    .SEG_SELECT_IN(StrobeCount),
    .BIN_IN(SEG_BIN),
    .DOT_IN('h0),
    .SEG_SELECT_OUT(SEG_SELECT_OUT),
    .HEX_OUT(HEX_OUT)
);

mux_4x1 u_mux_4x1( 
        .IN1(Mem[1][3:0]),                 // 4-bit input
        .IN2(Mem[1][7:4]),                 // 4-bit input
        .IN3(Mem[0][3:0]),                 // 4-bit input
        .IN4(Mem[0][7:4]),                 // 4-bit input
        .CTRL(StrobeCount),               // Control 
        .OUT(SEG_BIN)                       
);      
    
    
endmodule
