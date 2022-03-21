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
// 
// Dependencies: 
// 
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
    inout DATA_MOUSE
);



endmodule
