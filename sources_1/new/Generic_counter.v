`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:41:54
// Design Name: Processor
// Module Name: Generic_counter
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      A parameterised counter, with an enable bit.
//      Outputing a pulse signal when done.
//      As well as a continuos counter.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Generic_counter # (
    parameter CTR_WIDTH = 4,
    parameter CTR_MAX = 9
)
(
    input CLK,
    input RESET,
    input ENABLE,
    output OUT_TRIG,
    output [(CTR_WIDTH - 1):0] OUT_CTR
);
    
    reg [(CTR_WIDTH - 1):0] tp_ctr;
    reg tp_trig;
    
    always @(posedge CLK) begin
        if (RESET) begin
            tp_ctr <= 0;
        end
        else begin
            if (ENABLE) begin
                if (tp_ctr == CTR_MAX) begin
                    tp_ctr <= 0;
                end
                else begin
                    tp_ctr <= tp_ctr + 1;
                end
            end
            else begin
                tp_ctr <= tp_ctr;
            end
        end
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            tp_trig <= 0;
        end
        else begin
            if (ENABLE) begin
                if (tp_ctr == CTR_MAX) begin
                    tp_trig <= 1;
                end
                else begin
                    tp_trig <= 0;
                end
            end
            else begin
                tp_trig <= 0;
            end
        end
    end
    
    assign OUT_CTR = tp_ctr;
    assign OUT_TRIG = tp_trig;
endmodule

