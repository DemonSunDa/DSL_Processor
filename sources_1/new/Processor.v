`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:41:54
// Design Name: Processor
// Module Name: Processor
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
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
    // Standard signals
    input CLK,
    input RESET,
    // BUS signals
    inout [7:0] BUS_DATA,
    output [7:0] BUS_ADDR,
    output BUS_WE,
    // ROM signals
    output [7:0] ROM_ADDRESS,
    input ROM_DATA,
    // INTERRUPT signals
    input [1:0] BUS_INTERRUPT_RAISE,
    output [1:0] BUS_INTERRUPT_ACK
);

    // The main data bus is treated as tristate
    // Tristate signals that interface with the main state machine
    wire [7:0] BusDataIn;
    reg [7:0] currBusDataOut, nextBusDataOut;
    reg currBusDataOutWE, nextBusDataOutWE;

    // Tristate mechanism
    assign BusDataIn = BUS_DATA;
    assign BUS_DATA = currBusDataOutWE ? currBusDataOut : 8'hZZ;
    assign BUS_WE = currBusDataOutWE;

    // Address of the bus
    reg [7:0] currBusAddr, nextBusAddr;
    assign BUS_ADDR = currBusAddr;

    // The processor has two internal registers to hold data between operations,
    // and a third to hold the current program context when using function calls
    reg [7:0] currRegA, nextRegA;
    reg [7:0] currRegB, nextRegB;
    reg currRegSelect, nextRegSelect;
    reg [7:0] currProgContrext, nextProgContext;

    // Dedicated interrupt output lines - one for each interrupt line
    reg [1:0] currInterruptAck, nextInterruptAck;
    assign BUS_INTERRUPT_ACK = currInterruptAck;

    // Instantiate program memory
    // A program counter points to the current operation. The PC has an offset
    // that is used to reference information that is part of the current operation
    reg [7:0] currProgCtr, nextProgCtr;
    reg [1:0] currProgCtrOffset, nextProgCtrOffset;
    wire [7:0] ProgMemoryOut;
    wire [7:0] ActualAddress;
    assign ActualAddress = currProgCtr + currProgCtrOffset;

    // ROM signals
    assign ROM_ADDRESS = ActualAddress;
    assign ProgMemoryOut = ROM_DATA;

    // Instantiate the ALU
    // The processor has an integrated ALU that can do several different operations
    wire [7:0] AluOut;
    ALU ALU0(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // I/O
        .IN_A(currRegA),
        .IN_B(currRegB),
        .IN_OPP_TYPE(ProgMemoryOut[7:4]),
        .OUT_RESULT(AluOut)
    );

    // The microprocessor is essentially a state machine,
    // with one sequential pipeline of states for each operation
    // The current list of operation:
    // 0: Read from memory to A
    // 1: Read from memory to B
    // 2: Write to memory from A
    // 3: Write to memory from B
    // 4: Do maths with ALU, and save result in reg A
    // 5: Do maths with ALU, and save result in reg B
    // 6: If (A == or < or > B) goto ADDR
    // 7: Goto ADDR
    // 8: Goto IDLE
    // 9: End thread, goto IDLE state and wait for interrupt
    // 10: Function call
    // 11: Return from function call
    // 12: Dereference A
    // 13: Dereference B

    parameter [7:0]
    // Program thread selection
    IDLE = 8'hF0, // waits here until an interrupt
    GET_THREAD_START_ADDR_0 =   8'hF1, // wait
    GET_THREAD_START_ADDR_1 =   8'hF2, // apply the new address to the program counter
    GET_THREAD_START_ADDR_2 =   8'hF3, // wait, goto ChooseOp

    // Operation selection
    // Depending on the value of ProgMemOut, goto one of the instruction start states
    CHOOSE_OPP =                8'h00,

    // Data flow
    READ_FROM_MEM_TO_A =        8'h10, // wait to find what address to read, save reg select
    READ_FROM_MEM_TO_B =        8'h11, // wait to find what address to read, save reg select
    READ_FROM_MEM_0 =           8'h12, // set BUS_ADDR to designated address
    READ_FROM_MEM_1 =           8'h13, // wait, increments PC by 2, reset offset
    READ_FROM_MEM_2 =           8'h14, // write memory output to chosen register, end op

    WRITE_TO_MEM_FROM_A =       8'h20, // Reads Op + 1 to find the address to write to
    WRITE_TO_MEM_FROM_B =       8'h21, // Reads Op + 1 to find the address to write to
    WRITE_TO_MEM_0 =            8'h22, // wait for new op address to settle, end op

    // Data manipulation
    DO_MATHS_OPP_SAVE_IN_A =    8'h30, // the result of maths op is available, save to reg A
    DO_MATHS_OPP_SAVE_IN_B =    8'h31, // the result of maths op is available, save to reg B
    DO_MATHS_OPP_0 =            8'h32, // wait for new op address to settle, end op

    // TODO In/Equality
    // TODO Goto ADDR
    // TODO Goto IDLE
    // TODO Functrion Call
    // TODO Function Return
    // TODO Dereference


    // Sequential SM
    reg [7:0] currState, nextState;

    always @(posedge CLK) begin
        if (RESET) begin
            currState =         8'h00;
            currProgCtr =       8'h00;
            currProgCtrOffset = 2'b00;
            currBusAddr =       8'hFF; // initial instruction after reset
            currBusDataOut =    8'h00;
            currBusDataOutWE =  1'b0;
            currRegA =          8'h00;
            currRegB =          8'h00;
            currRegSelect =     1'b0;
            currProgContext =   8'h00;
            currInterruptAck =  2'b00;
        end
        else begin
            currState =         nextState;
            currProgCtr =       nextProgCtr;
            currProgCtrOffset = nextProgCtrOffset;
            currBusAddr =       nextBusAddr;
            currBusDataOut =    nextBusDataOut;
            currBusDataOutWE =  nextBusDataOutWE;
            currRegA =          nextRegA;
            currRegB =          nextRegB;
            currRegSelect =     nextRegSelect;
            currProgContext =   nextProgContext;
            currInterruptAck =  nextInterruptAck;
        end
    end

    // Combinational SM
    always @(*) begin
        nextState =             currState;
        nextProgCtr =           currProgCtr;
        nextProgCtrOffset =     2'h0; // only keep offset for one CLK
        nextBusAddr =           8'hFF;
        nextBusDataOut =        currBusDataOut;
        nextBusDataOutWE =      1'b0;
        nextRegA =              currRegA;
        nextRegB =              currRegB;
        nextRegSelect =         currRegSelect;
        nextProgContext =       currProgContext;
        nextInterruptAck =      2'b00;

        case (currState)
            // Thread state
            IDLE : begin
                if (BUS_INTERRUPT_RAISE[0]) begin // interrupt request A
                    nextState = GET_THREAD_START_ADDR_0;
                    nextProgCtr = 8'hFF;
                    nextInterruptAck = 2'b01;
                end
                else if (BUS_INTERRUPT_RAISE[1]) begin // interrupt request B
                    nextState = GET_THREAD_START_ADDR_0;
                    nextProgCtr = 8'hFE;
                    nextInterruptAck = 2'b10;
                end
                else begin
                    nextState = IDLE;
                    nextProgCtr = 8'hFF; // nothing has happened
                    nextInterruptAck = 2'b00;
                end
            end

            // Wait state, for new prog address to arrive
            GET_THREAD_START_ADDR_0 : begin
                nextState = GET_THREAD_START_ADDR_1;
            end

            // Assign the new PC value
            GET_THREAD_START_ADDR_1 : begin
                nextState = GET_THREAD_START_ADDR_2;
                nextProgCtr = ProgMemoryOut;
            end

            // wait for the new PC value to settle
            GET_THREAD_START_ADDR_2 : begin
                nextState = CHOOSE_OPP;
            end

            // CHOOSE_OPP
            CHOOSE_OPP : begin
                case (ProgMemoryOut[3:0])
                    4'h0    : nextState = READ_FROM_MEM_TO_A;
                    4'h1    : nextState = READ_FROM_MEM_TO_A;
                    4'h2    : nextState = WRITE_TO_MEM_FROM_A;
                    4'h3    : nextState = WRITE_TO_MEM_FROM_B;
                    4'h4    : nextState = DO_MATHS_OPP_SAVE_IN_A;
                    4'h5    : nextState = DO_MATHS_OPP_SAVE_IN_B;
                    4'h6    : nextState = IF_A_EQUALITY_B_GOTO;
                    4'h7    : nextState = GOTO;
                    4'h8    : nextState = IDLE;
                    4'h9    : nextState = FUNCTION_START;
                    4'hA    : nextState = RETURN;
                    4'hB    : nextState = DE_REERENCE_A;
                    4'hC    : nextState = DE_REERENCE_B;
                    default : nextState = currState;
                endcase
                nextProgCtrOffset = 2'b01;
            end

        // READ_FROM_MEM
            // READ_FROM_MEM_TO_A: here starts the memory read operational pipeline
            // wait state, to give time for hte mem address to be read, reg select is set to 0
            READ_FROM_MEM_TO_A : begin
                nextState = READ_FROM_MEM_0;
                nextRegSelect = 1'b0;
            end

            // READ_FROM_MEM_TO_B: here starts the memory read operational pipeline
            // wait state, to give time for hte mem address to be read, reg select is set to 1
            READ_FROM_MEM_TO_B : begin
                nextState = READ_FROM_MEM_0;
                nextRegSelect = 1'b1;
            end

            // The address will be valid during this state, set BUS_ADDR to this value
            READ_FROM_MEM_0 : begin
                nextState = READ_FROM_MEM_1;
                nextBusAddr = ProgMemoryOut;
            end

            // Wait state, to give time for the mem data to be read
            // Increment the program counter here
            //! 2 CLK ahead
            READ_FROM_MEM_1 : begin
                nextState = READ_FROM_MEM_2;    
                nextProgCtr = currProgCtr + 2;
            end

            // The data will now have arrived from memory
            // Write to destignated register
            READ_FROM_MEM_2 : begin
                nextState = CHOOSE_OPP;
                if (!currRegSelect) begin
                    nextRegA = BusDataIn;
                end
                else begin
                    nextRegB = BusDataIn;
                end
            end


        // WRITE_FROM_MEM
            // WRITE_TO_MEM_FROM_A : here starts the memory write operational pipeline.
            // Wait state, to find the address of where we are writing
            // Increment the program counter here
            //! 2 CLK ahead
            WRITE_TO_MEM_FROM_A : begin
                nextState = WRITE_TO_MEM_0;
                nextRegSelect = 1'b0;
                nextProgCtr = currProgCtr + 2;
            end

            // WRITE_TO_MEM_FROM_B : here starts the memory write operational pipeline.
            // Wait state, to find the address of where we are writing
            // Increment the program counter here
            //! 2 CLK ahead
            WRITE_TO_MEM_FROM_B : begin
                nextState = WRITE_TO_MEM_0;
                nextRegSelect = 1'b1;
                nextProgCtr = currProgCtr + 2;
            end

            // The address will be valid during this state, set BUS_ADDR to this value
            WRITE_TO_MEM_0 : begin
                nextState = CHOOSE_OPP;
                nextBusAddr = ProgMemoryOut;
                if (!nextRegSelect) begin
                    nextBusDataOut = currRegA;
                end
                else begin
                    nextBusDataOut = currRegB;
                end
                nextBusDataOutWE = 1'b1;
            end


        // ALU
            // DO_MATHS_OPP_SAVE_IN_A : here starts the DoMaths operational pipeline
            // Reg A and Reg B must already be set to the desired values
            // The MSBs of the Operation type determines the maths operation type
            // At this stage the result is ready to be collected from the ALU
            DO_MATHS_OPP_SAVE_IN_A : begin
                nextState = DO_MATHS_OPP_0;
                nextRegA = AluOut;
                nextProgCtr = currProgCtr + 1;
            end

            DO_MATHS_OPP_SAVE_IN_B : begin
                nextState = DO_MATHS_OPP_0;
                nextRegB = AluOut;
                nextProgCtr = currProgCtr + 1;
            end

            // Wait state for new prog address to settle
            DO_MATHS_OPP_0 : nextState = CHOOSE_OPP;


        // TODO In/Equality
            // A == B
            BREQ_ADDR

            // A < B
            BGTQ_ADDR

            // A > B
            BLTQ_ADDR


            // TODO Goto ADDR
            // TODO Goto IDLE
            // TODO Functrion Call
            // TODO Function Return
            // TODO Dereference


        endcase
    end
endmodule
