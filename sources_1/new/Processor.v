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
    reg currBusDataOutWe, nextBusDataOutWE;

    // Tristate mechanism
    assign BusDataIn = BUS_DATA;
    assign BUS_DATA = currBusDataOutWe ? currBusDataOut : 8'hZZ;
    assign BUS_WE = currBusDataOutWe;

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


endmodule
