`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2022 01:16:20
// Design Name: 
// Module Name: TOP_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
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

    TOP uut (
        .CLK(CLK),
        .RESET(RESET),
        .DISP_SEL_OUT(DISP_SEL_OUT),
        .DISP_OUT(DISP_OUT),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .IR_LED(IR_LED),
        .LEDH(LEDH),
        .LEDL(LEDL)
    );
    
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        RESET = 1;
        
        #10000
        RESET = 0;
    end
endmodule
