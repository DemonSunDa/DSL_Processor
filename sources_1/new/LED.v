`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 23.03.2022 23:47:35
// Design Name: Processor
// Module Name: LED
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      LED module interracting with main bus.
//      Output device.
//      Addressed at    0xC0    lower byte
//                      0xC1    higher byte
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LED(
    // Standard signals
    input CLK,
    input RESET,
    // BUS signals
    input [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    // LEDs
    output reg [7:0] LEDH,
    output reg [7:0] LEDL
);

    parameter LEDBaseAddr = 8'hC0;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            LEDH <= 8'h00;
            LEDL <= 8'hF0;
        end
        else begin
            if ((BUS_ADDR == LEDBaseAddr) & BUS_WE) begin // CPU writing to LED module low byte
                LEDL <= BUS_DATA;
                LEDH <= LEDH;
            end
            else if ((BUS_ADDR == LEDBaseAddr + 8'h01) & BUS_WE) begin // CPU writing to LED module high byte
                LEDL <= LEDL;
                LEDH <= BUS_DATA;
            end
            else begin
                LEDH <= LEDH;
                LEDL <= LEDL;
            end
        end
    end

endmodule
