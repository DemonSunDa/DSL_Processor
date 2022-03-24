`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:59
// Design Name: Processor
// Module Name: Display_TB
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


module Display_TB(

);

    reg CLK;
    reg RESET;
    reg [7:0] BusAddr;
    reg [7:0] BusData; // Display is pure output, use reg for inputting to Display
    reg BusWE;
    wire [3:0] DISP_SEL_OUT;
    wire [7:0] DISP_OUT;

    LED uut(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_ADDR(BusAddr),
        .BUS_DATA(BusData),
        .BUS_WE(BusWE),
        .DISP_SEL_OUT(DISP_SEL_OUT),
        .DISP_OUT(DISP_OUT)
    );


    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        RESET = 1'b1;
        BusAddr = 8'hFF; // CPU state on reset
        BusWE = 1'b0; // CPU not writing

        #100    RESET = 1'b0;
        #100    BusAddr = 8'hD0; // addressing left byte
                BusWE = 1'b1;
                BusData = 8'hFF;
        #10     BusAddr = 8'hFF;
                BusWE = 1'b0;

        #50     BusAddr = 8'hD1; // addressing right byte
                BusWE = 1'b1;
                BusData = 8'hF0;
        #10     BusAddr = 8'hFF;
                BusWE = 1'b0;

        #100000
        $finish;
    end
endmodule
