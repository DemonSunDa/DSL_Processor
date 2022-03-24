`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:59
// Design Name: Processor
// Module Name: Swithes_TB
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


module Swithes_TB(

);

    reg CLK;
    reg RESET;
    reg [7:0] BusAddr;
    wire [7:0] BusData;
    reg BusWE;
    reg [7:0] SWH;
    reg [7:0] SWL;

    Switches uut(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_ADDR(BusAddr),
        .BUS_DATA(BusData),
        .BUS_WE(BusWE),
        .SWH(SWH),
        .SWL(SWL)
    );


    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        RESET = 1'b1;
        BusAddr = 8'hFF; // CPU state on reset
        BusWE = 1'b0; // CPU not writing
        SWH = 8'h00; // display XY
        SWL = 8'h01; // car type blue
        
        #100    RESET = 0;

        #50     BusAddr = 8'hE0; // addressing SWL
        #10     BusAddr = 8'hFF; // address lasts for 1 CLK

        #50     BusAddr = 8'hE1;
        #10     BusAddr = 8'hFF;

        #100    SWH = 8'hFF;
                BusAddr = 8'hE1;
        #10     BusAddr = 8'hFF;

        #50     BusAddr = 8'hE1;
        #10     BusAddr = 8'hFF;
        
        #100000
        $finish;
    end
endmodule
