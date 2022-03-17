`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:44:27
// Design Name: Processor
// Module Name: RAM
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


module RAM(
    // Standard signals
    inout CLK,
    // BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    inout BUS_WE
);

    parameter RAMBaseAddr = 0;
    parameter RAMAddrWidth = 7; // 128 * 8 bits memory

    // Tristate
    wire [7:0] BufferedBusData;
    reg [7:0] Out;
    reg RAMBusWE;

    // Only place data on the bus if the processor is NOT writing, and it is addressing this memory
    assign BUS_DATA = RAMBusWE ? Out : 8'hZZ;
    assign BufferedBusData = BUS_DATA;

    // Memory
    reg [7:0] Mem [(2 ** RAMAddrWidth - 1):0];

    // Initialise the memory for data preloading, initialising variables, and declaring constants
    initial $readmemh("Complete_Demo_RAM.txt", Mem);

    // Single port ram
    always @(posedge CLK) begin
        // Brute-force RAM address decoding
        if ((BUS_ADDR >= RAMBaseAddr) & (BUS_ADDR < RAMBaseAddr + 128)) begin
            if (BUS_WE) begin
                Mem[BUS_ADDR[6:0]] <= BufferedBusData;
                RAMBusWE <= 1'b0;
            end
            else begin
                RAMBusWE = 1'b1;
            end
        end
        Out <= Mem[BUS_ADDR[6:0]];
    end

endmodule
