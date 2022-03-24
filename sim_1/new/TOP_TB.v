`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:59
// Design Name: Processor
// Module Name: TOP_TB
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


module TOP_TB(

);

    reg CLK;
    reg RESET;
    wire [3:0] DISP_SEL_OUT;
    wire [7:0] DISP_OUT;
    wire CLK_MOUSE;
    wire DATA_MOUSE;
    wire IR_LED;
    wire [7:0] LEDH;
    wire [7:0] LEDL;
    reg [7:0] SWH;
    reg [7:0] SWL;

    TOP uut (
        .CLK(CLK),
        .RESET(RESET),
        .DISP_SEL_OUT(DISP_SEL_OUT),
        .DISP_OUT(DISP_OUT),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .IR_LED(IR_LED),
        .LEDH(LEDH),
        .LEDL(LEDL),
        .SWH(SWH),
        .SWL(SWL)
    );
    
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        RESET = 1'b1;
        SWH = 8'h00; // display XY
        SWL = 8'h01; // car type blue
        
        #10000  RESET = 0;
    end
endmodule
