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


module Processor(
    //Standard Signals
    input CLK,
    input RESET,
    //BUS Signals
    inout [7:0] BUS_DATA,
    output [7:0] BUS_ADDR,
    output BUS_WE,
    // ROM signals
    output [7:0] ROM_ADDRESS,
    input [7:0] ROM_DATA,
    // INTERRUPT signals
    input [1:0] BUS_INTERRUPTS_RAISE,
    output [1:0] BUS_INTERRUPTS_ACK
);

//The main data bus is treated as tristate, so we need a mechanism to handle this.
//Tristate signals that interface with the main state machine
wire [7:0] BusDataIn;
reg [7:0] CurrBusDataOut, NextBusDataOut;
reg CurrBusDataOutWE, NextBusDataOutWE;
//Tristate Mechanism
assign BusDataIn = BUS_DATA;
assign BUS_DATA = CurrBusDataOutWE ? CurrBusDataOut : 8'hZZ;
assign BUS_WE = CurrBusDataOutWE;
//Address of the bus
reg [7:0] CurrBusAddr, NextBusAddr;
assign BUS_ADDR = CurrBusAddr;
//The processor has two internal registers to hold data between operations, and a third to hold
//the current program context when using function calls.
reg [7:0] CurrRegA, NextRegA;
reg [7:0] CurrRegB, NextRegB;
reg CurrRegSelect, NextRegSelect;
reg [7:0] CurrProgContext, NextProgContext;
//Dedicated Interrupt output lines - one for each interrupt line
reg [1:0] CurrInterruptAck, NextInterruptAck;
assign BUS_INTERRUPTS_ACK = CurrInterruptAck;
//Instantiate program memory here
//There is a program counter which points to the current operation. The program counter
//has an offset that is used to reference information that is part of the current operation
reg [7:0] CurrProgCounter, NextProgCounter;
reg [1:0] CurrProgCounterOffset, NextProgCounterOffset;
wire [7:0] ProgMemoryOut;
wire [7:0] ActualAddress;
assign ActualAddress = CurrProgCounter + CurrProgCounterOffset;
// ROM signals
assign ROM_ADDRESS = ActualAddress;
assign ProgMemoryOut = ROM_DATA;

//Instantiate the ALU
//The processor has an integrated ALU that can do several different operations
wire [7:0] AluOut;

ALU ALU0(
    //standard signals
    .CLK(CLK),
    .RESET(RESET),
    //I/O
    .IN_A(CurrRegA),
    .IN_B(CurrRegB),
    .IN_OPP_TYPE(ProgMemoryOut[7:4]),
    .OUT_RESULT(AluOut)
);

//The microprocessor is essentially a state machine, with one sequential pipeline
//of states for each operation.
//The current list of operations is:
// 0: Read from memory to A
// 1: Read from memory to B
// 2: Write to memory from A
// 3: Write to memory from B
// 4: Do maths with the ALU, and save result in reg A
// 5: Do maths with the ALU, and save result in reg B
// 6: if A (== or < or > B) GoTo ADDR
// 7: Goto ADDR
// 8: Go to IDLE
// 9: End thread, goto idle state and wait for interrupt.
// 10: Function call
// 11: Return from function call
// 12: Dereference A
// 13: Dereference B

parameter [7:0] //Program thread selection
IDLE = 8'hF0, //Waits here until an interrupt wakes up the processor.
GET_THREAD_START_ADDR_0 = 8'hF1, //Wait.
GET_THREAD_START_ADDR_1 = 8'hF2, //Apply the new address to the program counter.
GET_THREAD_START_ADDR_2 = 8'hF3, //Wait. Goto ChooseOp.
//Operation selection
//Depending on the value of ProgMemOut, goto one of the instruction start states.
CHOOSE_OPP = 8'h00,
//Data Flow
READ_FROM_MEM_TO_A = 8'h10, //Wait to find what address to read, save reg select.
READ_FROM_MEM_TO_B = 8'h11, //Wait to find what address to read, save reg select.
READ_FROM_MEM_0 = 8'h12, //Set BUS_ADDR to designated address.
READ_FROM_MEM_1 = 8'h13, //wait - Increments program counter by 2. Reset offset.
READ_FROM_MEM_2 = 8'h14, //Writes memory output to chosen register, end op.
WRITE_TO_MEM_FROM_A = 8'h20, //Reads Op+1 to find what address to Write to.
WRITE_TO_MEM_FROM_B = 8'h21, //Reads Op+1 to find what address to Write to.
WRITE_TO_MEM_0 = 8'h22, //wait - Increments program counter by 2. Reset offset.
//Data Manipulation
DO_MATHS_OPP_SAVE_IN_A = 8'h30, //The result of maths op. is available, save it to Reg A.
DO_MATHS_OPP_SAVE_IN_B = 8'h31, //The result of maths op. is available, save it to Reg B.
DO_MATHS_OPP_0 = 8'h32, //wait for new op address to settle. end op.
// START
IF_A_EQUALITY_B_GOTO = 8'h40, // 
IF_A_EQUALITY_B_GOTO_0 = 8'h41, // 
IF_A_EQUALITY_B_GOTO_1 = 8'h42, // 
IF_A_EQUALITY_B_GOTO_2 = 8'h43, // 
GOTO = 8'h50,
GOTO_0 = 8'h51,
GOTO_1 = 8'h52,
FUNCTION_START = 8'h60,
FUNCTION_START_0 = 8'h61,
FUNCTION_START_1 = 8'h62,
RETURN = 8'h70,
RETURN_0 = 8'h71,
DE_REFERENCE_A = 8'h80, // Wait to find what address to read, save reg select
DE_REFERENCE_B = 8'h81, // Wait to find what address to read, save reg select
DE_REFERENCE_0 = 8'h82, // Set BUS_ADDR to designated adress, wait - Increments program counter by 2. Reset Offset
DE_REFERENCE_1 = 8'h83; // Write memory output to chosen register, end op

// END
/*
Complete the above parameter list for In/Equality, Goto Address, Goto Idle, function start, Return from
function, and Dereference operations.
*/
//  TODO // KINDA DONE
//Sequential part of the State Machine.
reg [7:0] CurrState, NextState;
always@(posedge CLK) 
begin
    if(RESET) begin
        CurrState = 8'h00;
        CurrProgCounter = 8'h00;
        CurrProgCounterOffset = 2'h0;
        CurrBusAddr = 8'hFF; //Initial instruction after reset.
        CurrBusDataOut = 8'h00;
        CurrBusDataOutWE = 1'b0;
        CurrRegA = 8'h00;
        CurrRegB = 8'h00;
        CurrRegSelect = 1'b0;
        CurrProgContext = 8'h00;
        CurrInterruptAck = 2'b00;
    end else begin
        CurrState = NextState;
        CurrProgCounter = NextProgCounter;
        CurrProgCounterOffset = NextProgCounterOffset;
        CurrBusAddr = NextBusAddr;
        CurrBusDataOut = NextBusDataOut;
        CurrBusDataOutWE = NextBusDataOutWE;
        CurrRegA = NextRegA;
        CurrRegB = NextRegB;
        CurrRegSelect = NextRegSelect;
        CurrProgContext = NextProgContext;
        CurrInterruptAck = NextInterruptAck;
    end
end

//Combinatorial section – large!
always@* begin
    //Generic assignment to reduce the complexity of the rest of the S/M
    NextState = CurrState;
    NextProgCounter = CurrProgCounter;
    NextProgCounterOffset = 2'h0;
    NextBusAddr = 8'hFF;
    NextBusDataOut = CurrBusDataOut;
    NextBusDataOutWE = 1'b0;
    NextRegA = CurrRegA;
    NextRegB = CurrRegB;
    NextRegSelect = CurrRegSelect;
    NextProgContext = CurrProgContext;
    NextInterruptAck = 2'b00;
    //Case statement to describe each state
    case (CurrState)
        ///////////////////////////////////////////////////////////////////////////////////////
        //Thread states.
        IDLE: 
        begin
            if(BUS_INTERRUPTS_RAISE[0]) begin // Interrupt Request A.
                NextState = GET_THREAD_START_ADDR_0;
                NextProgCounter = 8'hFF;
                NextInterruptAck = 2'b01;
            end else if(BUS_INTERRUPTS_RAISE[1]) begin //Interrupt Request B.
                NextState = GET_THREAD_START_ADDR_0;
                NextProgCounter = 8'hFE;
                NextInterruptAck = 2'b10;
            end else begin
                NextState = IDLE;
                NextProgCounter = 8'hFF; //Nothing has happened.
                NextInterruptAck = 2'b00;
            end
        end
        //Wait state - for new prog address to arrive.
        GET_THREAD_START_ADDR_0: begin
            NextState = GET_THREAD_START_ADDR_1;
        end
            //Assign the new program counter value
            GET_THREAD_START_ADDR_1: begin
            NextState = GET_THREAD_START_ADDR_2;
            NextProgCounter = ProgMemoryOut;
        end
        //Wait for the new program counter value to settle
        GET_THREAD_START_ADDR_2:
        NextState = CHOOSE_OPP;
        ///////////////////////////////////////////////////////////////////////////////////////
        //CHOOSE_OPP - Another case statement to choose which operation to perform
        CHOOSE_OPP: begin
            case (ProgMemoryOut[3:0])
            4'h0: NextState = READ_FROM_MEM_TO_A;
            4'h1: NextState = READ_FROM_MEM_TO_B;
            4'h2: NextState = WRITE_TO_MEM_FROM_A;
            4'h3: NextState = WRITE_TO_MEM_FROM_B;
            4'h4: NextState = DO_MATHS_OPP_SAVE_IN_A;
            4'h5:NextState = DO_MATHS_OPP_SAVE_IN_B;
            4'h6:NextState = IF_A_EQUALITY_B_GOTO;
            4'h7: NextState = GOTO;
            4'h8:NextState = IDLE;
            4'h9:NextState = FUNCTION_START;
            4'hA:NextState = RETURN;
            4'hB:NextState = DE_REFERENCE_A;
            4'hC:NextState = DE_REFERENCE_B;
            default:
                NextState = CurrState;
            endcase
            NextProgCounterOffset = 2'h1;
        end
        ///////////////////////////////////////////////////////////////////////////////////////
        //READ_FROM_MEM_TO_A : here starts the memory read operational pipeline.
        //Wait state - to give time for the mem address to be read. Reg select is set to 0
        READ_FROM_MEM_TO_A:
        begin
            NextState = READ_FROM_MEM_0;
            NextRegSelect = 1'b0;
        end
        //READ_FROM_MEM_TO_B : here starts the memory read operational pipeline.
        //Wait state - to give time for the mem address to be read. Reg select is set to 1
        READ_FROM_MEM_TO_B:
        begin
            NextState = READ_FROM_MEM_0;
            NextRegSelect = 1'b1;
        end
        //The address will be valid during this state, so set the BUS_ADDR to this value.
        READ_FROM_MEM_0: 
        begin
            NextState = READ_FROM_MEM_1;
            NextBusAddr = ProgMemoryOut;
        end
        //Wait state - to give time for the mem data to be read
        //Increment the program counter here. This must be done 2 clock cycles ahead
        //so that it presents the right data when required.
        READ_FROM_MEM_1: 
        begin
            NextState = READ_FROM_MEM_2;
            NextProgCounter = CurrProgCounter + 2;
        end
        //The data will now have arrived from memory. Write it to the proper register.
        
        READ_FROM_MEM_2: 
        begin
            NextState = CHOOSE_OPP;
            if(!CurrRegSelect)
                NextRegA = BusDataIn;
            else
                NextRegB = BusDataIn;
        end
        ///////////////////////////////////////////////////////////////////////////////////////
        //WRITE_TO_MEM_FROM_A : here starts the memory write operational pipeline.
        //Wait state - to find the address of where we are writing
        //Increment the program counter here. This must be done 2 clock cycles ahead
        //so that it presents the right data when required.
        WRITE_TO_MEM_FROM_A:
        begin
            NextState = WRITE_TO_MEM_0;
            NextRegSelect = 1'b0;
            NextProgCounter = CurrProgCounter + 2;
        end
        //WRITE_TO_MEM_FROM_B : here starts the memory write operational pipeline.
        //Wait state - to find the address of where we are writing
        //Increment the program counter here. This must be done 2 clock cycles ahead
        // so that it presents the right data when required.
        WRITE_TO_MEM_FROM_B:
        begin
            NextState = WRITE_TO_MEM_0;
            NextRegSelect = 1'b1;
            NextProgCounter = CurrProgCounter + 2;
        end
        //The address will be valid during this state, so set the BUS_ADDR to this value,
        //and write the value to the memory location.
        WRITE_TO_MEM_0: 
        begin
            NextState = CHOOSE_OPP;
            NextBusAddr = ProgMemoryOut;
            if(!NextRegSelect)
                NextBusDataOut = CurrRegA;
            else
                NextBusDataOut = CurrRegB;
            NextBusDataOutWE = 1'b1;
        end
        ///////////////////////////////////////////////////////////////////////////////////////
        //DO_MATHS_OPP_SAVE_IN_A : here starts the DoMaths operational pipeline.
        //Reg A and Reg B must already be set to the desired values. The MSBs of the
        // Operation type determines the maths operation type. At this stage the result is
        // ready to be collected from the ALU.
        DO_MATHS_OPP_SAVE_IN_A: 
        begin
            NextState = DO_MATHS_OPP_0;
            NextRegA = AluOut;
            NextProgCounter = CurrProgCounter + 1;
        end
        //DO_MATHS_OPP_SAVE_IN_B : here starts the DoMaths operational pipeline
        //when the result will go into reg B.
        DO_MATHS_OPP_SAVE_IN_B: 
        begin
            NextState = DO_MATHS_OPP_0;
            NextRegB = AluOut;
            NextProgCounter = CurrProgCounter + 1;
        end
        //Wait state for new prog address to settle.
        DO_MATHS_OPP_0: NextState = CHOOSE_OPP;
        //////////////////////////// START ////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////////////////////////
        // IF_A_EQUALITY_B_GOTO : here starts the goto address operational pipeline
        // Check equality, branch if true, do nothing if false
        IF_A_EQUALITY_B_GOTO:
        begin
            if (AluOut) // maths operation should already be completed as it was initiated in CHOOSE_OPP stage
                NextState = IF_A_EQUALITY_B_GOTO_0;
            else
            begin
                NextProgCounter = CurrProgCounter + 2;
                NextState = IF_A_EQUALITY_B_GOTO_1;
            end
        end
        
        // assign Prog address to ADDR
        IF_A_EQUALITY_B_GOTO_0:
        begin
            NextProgCounter =  ProgMemoryOut; // perform branch 
            NextState = IF_A_EQUALITY_B_GOTO_1;
        end
        // Prog now settled
        IF_A_EQUALITY_B_GOTO_1:
        begin
            NextState = CHOOSE_OPP;
        end  
        
        //////////////////////////////////////////////////////////////////////////////////////
        // GOTO: here starts the goto address operational pipeline
        // wait for ProgMemory to settle
        GOTO:
        begin
            NextState = GOTO_0;
        end
        // assign Prog address to ROM MEM
        GOTO_0:
        begin
            NextProgCounter =  ProgMemoryOut;
            NextState = GOTO_1;
        end
        // Prog now settled
        GOTO_1:
        begin
            NextState = CHOOSE_OPP;
        end  
        
        //////////////////////////////////////////////////////////////////////////////////////
        // FUNCTION START : here starts the function call operational pipeline
        // Update Program Context with the Program Counter and wait for rom data to settle
        FUNCTION_START:
        begin
            NextState = FUNCTION_START_0;
            NextProgContext = CurrProgCounter;
        end
        // assign Prog address
        FUNCTION_START_0:
        begin
            NextProgCounter = ProgMemoryOut;
            NextState = FUNCTION_START_1;
        end
        // Prog now settled
        FUNCTION_START_1:
        begin
            NextState = CHOOSE_OPP;
        end
         
        //////////////////////////////////////////////////////////////////////////////////////
        // RETURN : here starts the return operational pipeline
        // Update Program Counter with the Program Context and wait for prog address to settle
        RETURN:
        begin
            NextState = RETURN_0;
            NextProgCounter = CurrProgContext;
        end
        // PC is now settled, return to choose opp
        RETURN_0:
        begin
            NextState = CHOOSE_OPP;
        end
        
        //////////////////////////////////////////////////////////////////////////////////////
        //DE_REFERENCE_A : here starts the dereference operational pipeline.
        //Wait state - to give time for the mem data to be read. Reg select is set to 0
        DE_REFERENCE_A:
        begin
            NextState = DE_REFERENCE_0;
            NextRegSelect = 1'b0;
            NextBusAddr = CurrRegA;
        end
        //DE_REFERENCE_B : here starts the memory read operational pipeline.
        //Wait state - to give time for the mem data to be read. Reg select is set to 1
        DE_REFERENCE_B:
        begin
            NextState = DE_REFERENCE_0;
            NextRegSelect = 1'b1;
            NextBusAddr = CurrRegB;
        end
        //Wait state - to give time for the mem data to be read
        //Increment the program counter here. This must be done 2 clock cycles ahead
        //so that it presents the right data when required.
        DE_REFERENCE_0: 
        begin
            NextState = DE_REFERENCE_1;
            NextProgCounter = CurrProgCounter + 2;
        end
        //The data will now have arrived from memory. Write it to the proper register.
        DE_REFERENCE_1: 
        begin
            NextState = CHOOSE_OPP;
            if(!CurrRegSelect)
                NextRegA = BusDataIn;
            else
                NextRegB = BusDataIn;
        end
        
        //////////////////////////// END ////////////////////////////////////

        /*
        Complete the above case statement for In/Equality, Goto Address, Goto Idle, function start, Return
        from
        function, and Dereference operations.
        */
        // TODO
    endcase
end


endmodule