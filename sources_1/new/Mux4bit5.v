`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:41:54
// Design Name: Processor
// Module Name: Mux4bit5
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


module Mux4bit5 (
    input [1:0] CONTROL,
    input [4:0] IN0,
    input [4:0] IN1,
    input [4:0] IN2,
    input [4:0] IN3,
    output reg [4:0] OUT
);

    always @(CONTROL or IN0 or IN1 or IN2 or IN3) begin
        case (CONTROL)
            2'b00       :   OUT <= IN0;
            2'b01       :   OUT <= IN1;
            2'b10       :   OUT <= IN2;
            2'b11       :   OUT <= IN3;
            default     :   OUT <= 5'b00000;
        endcase
    end

endmodule
