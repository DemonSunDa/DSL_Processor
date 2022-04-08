`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:59
// Design Name: Processor
// Module Name: TOP
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      Top module of the whole architecture.
//      INOUT   Mouse
//      INPUT   Switches
//      OUTPUT  IR
//      OUTPUT  7-segment display
//      OUTPUT  LEDs
// Dependencies: 
//      Processor.v
//          ALU.v
//      RAM.v
//      ROM.v
//      Timer.v
//      Seg7Display.v
//          Generic_counter.v
//          Mux4bit5.v
//          Seg7Decoder.v
//      IO_Mouse.v
//          MouseTransceiver.v
//              MouseTransmitter.v
//              MouseReceiver.v
//              MouseMasterSM.v
//      IR_IO.v
//          Generic_counter.v
//          IRTransmitterSM.v
//              Generic_counter.v
//      LED.v
//      Switches.v
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP(
    // Standard signals
    input CLK,
    input RESET,
    // 7-Seg display
    output [3:0] DISP_SEL_OUT,
    output [7:0] DISP_OUT,
    // IO Mouse
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // IR
    output IR_LED,
    // LED
    output [7:0] LEDH,
    output [7:0] LEDL,
    // Switches
    input [7:0] SWH,
    input [7:0] SWL
);

    // Main bus
    wire [7:0] BUS_ADDR;
    wire [7:0] BUS_DATA;
    wire BUS_WE;

    // ROM bus
    wire [7:0] ROM_ADDRESS;
    wire [7:0] ROM_DATA;

    // Interrupt
    wire [1:0] BUS_INTERRUPT_RAISE;
    wire [1:0] BUS_INTERRUPT_ACK;

    Processor CPU(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // ROM bus signals
        .ROM_DATA(ROM_DATA),
        .ROM_ADDRESS(ROM_ADDRESS),
        // Interrupt signals
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK)
    );

    RAM MEM_DATA(
        // Standard signals
        .CLK(CLK),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE)
    );

    ROM MEM_INST(
        // Standard signals
        .CLK(CLK),
        // ROM bus signals
        .DATA(ROM_DATA),
        .ADDR(ROM_ADDRESS)
    );

    Timer TIMER0(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // Interrupt signals
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[1]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[1])
    );

    Seg7Display DISPLAY(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // Display
        .DISP_SEL_OUT(DISP_SEL_OUT),
        .DISP_OUT(DISP_OUT)
    );

    IO_Mouse MOUSE(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // IO mouse
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        // Interrupt signals
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[0]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[0])
    );

    IO_IR IR(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // IR
        .IR_LED(IR_LED)
    );

    LED LED(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // LED
        .LEDH(LEDH),
        .LEDL(LEDL)
    );

    Switches SW(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // Main bus signals
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        // Switches
        .SWH(SWH),
        .SWL(SWL)
    );

endmodule
