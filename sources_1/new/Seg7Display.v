`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 25.02.2022 00:15:22
// Design Name: Processor
// Module Name: Seg7Display
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      Top level of 7-segment display module interracting with main bus.
// Dependencies: 
//      Generic_counter.v
//      Mux4bit5.v
//      Seg7Decoder.v
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Seg7Display(
    // Standard Inputs
    input CLK,
    input RESET,
    // BUS signals
    input [7:0] BUS_DATA, // does not need output
    input [7:0] BUS_ADDR,
    input BUS_WE,
    // Display
    output [3:0] DISP_SEL_OUT,
    output [7:0] DISP_OUT
);

    parameter DisplayBaseAddr = 8'hD0; // 7seg base address in the memory map

    reg [7:0] DispL;
    reg [7:0] DispR;

    always @(posedge CLK) begin
        if ((BUS_ADDR == DisplayBaseAddr) & BUS_WE) begin // writing to MouseX value
            DispL <= BUS_DATA;
            DispR <= DispR;
        end
        else if ((BUS_ADDR == DisplayBaseAddr + 8'h01) & BUS_WE) begin // writing to MouseY value
            DispL <= DispL;
            DispR <= BUS_DATA;
        end
        else begin
            DispL <= DispL;
            DispR <= DispR;
        end
    end


    // Display input
    reg [3:0] dispIN0;
    reg [3:0] dispIN1;
    reg [3:0] dispIN2;
    reg [3:0] dispIN3;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            dispIN0 <= 1000;
            dispIN1 <= 1000;
            dispIN2 <= 1000;
            dispIN3 <= 1000;
        end
        else begin
            dispIN0 <= DispR[3:0];
            dispIN1 <= DispR[7:4];
            dispIN2 <= DispL[3:0];
            dispIN3 <= DispL[7:4];
        end
    end
// Display input


// 7 Segment Display
    wire [4:0] dotBinIn;
    wire [3:0] segSelOut;
    wire [7:0] hexOut;

    wire trig_1kHz;
    wire [16:0] ctr_1kHz;
    wire trig_strobe;
    wire [1:0] ctr_strobe;

    Generic_counter # (
        .CTR_WIDTH(17),
        .CTR_MAX(99999)
    )
    Ctr1kHz (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(1'b1),
        .OUT_TRIG(trig_1kHz),
        .OUT_CTR(ctr_1kHz)
    );

    Generic_counter # (
        .CTR_WIDTH(2),
        .CTR_MAX(3)
    )
    CtrStrobe (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(trig_1kHz),
        .OUT_TRIG(trig_strobe),
        .OUT_CTR(ctr_strobe)
    );

    Mux4bit5 Multiplexer (
        .CONTROL(ctr_strobe),
        .IN0({1'b0, dispIN0}),
        .IN1({1'b0, dispIN1}),
        .IN2({1'b1, dispIN2}),
        .IN3({1'b0, dispIN3}),
        .OUT(dotBinIn)
    );

    Seg7Decoder Disp (
        .SEG_SELECT_IN(ctr_strobe),
        .BIN_IN(dotBinIn[3:0]),
        .DOT_IN(dotBinIn[4]),
        .SEG_SELECT_OUT(segSelOut),
        .HEX_OUT(hexOut)
    );
// 7 Segment Display

    assign DISP_SEL_OUT = segSelOut;
    assign DISP_OUT = hexOut;

endmodule
