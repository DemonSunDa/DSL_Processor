`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:18
// Design Name: Processor
// Module Name: Switches
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


module Switches(
    // Standard signals
    input CLK,
    input RESET,
    // BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    // Switches
    input [7:0] SWH,
    input [7:0] SWL
);

    parameter SwitchesBaseAddr = 8'hE0;

    wire [7:0] BusDataIn;
    reg [7:0] Out;
    reg IOBusWE; // switches write to bus enabler

    assign BUS_DATA = IOBusWE ? Out : 8'hZZ;
    assign BusDataIn = BUS_DATA;


    reg [7:0] InternalMem[1:0]; // 2 bytes

    // Refresh the stored values every CLK
    always @(posedge CLK) begin
        if ((BUS_ADDR >= SwitchesBaseAddr) & (BUS_ADDR < SwitchesBaseAddr + 8'h01)) begin // if switches addressed
            if (BUS_WE) begin // if CPU writing
                InternalMem[BUS_ADDR[3:0]] <= BusDataIn; // lower 4 bits of the address
                IOBusWE <= 1'b0;
            end
            else begin
                InternalMem[0] <= SWL;
                InternalMem[1] <= SWH;
                IOBusWE <= 1'b1;
            end
        end
        else begin
            InternalMem[0] <= InternalMem[0];
            InternalMem[1] <= InternalMem[1];
            IOBusWE <= 1'b0;
        end
    end

    // Clocked output
    always @(posedge CLK) begin
        Out <= InternalMem[BUS_ADDR[3:0]];
    end

endmodule
