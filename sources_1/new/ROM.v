`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:45:54
// Design Name: Processor
// Module Name: ROM
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


module ROM(
    // Standard signals
    input CLK,
    // BUS signals
    output reg [7:0] DATA,
    input [7:0] ADDR
);

    parameter RAMAddrWidth = 8;

    // Memory
    reg [7:0] ROM [(2 ** RAMAddrWidth - 1):0];

    // Load program
    initial $readmemh("Complete_Demo_ROM.txt", ROM);

    // Single port rom
    always @(posedge CLK) begin
        DATA <= ROM[ADDR];
    end

endmodule
