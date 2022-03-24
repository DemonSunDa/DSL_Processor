`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:59
// Design Name: Processor
// Module Name: ROM_TB
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


module ROM_TB(

);

    reg CLK;
    reg [7:0] BusAddr;
    wire [7:0] BusData; // pure output to Data

    ROM uut(
        .CLK(CLK),
        .DATA(BusData),
        .ADDR(BusAddr)
    );


    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        BusAddr = 8'hFF; // CPU state on reset

        #50     BusAddr = 8'h80;
        #10     BusAddr = 8'hFF;

        #100    BusAddr = 8'h00;
        #10     BusAddr = 8'hFF;

        // Since processor always address the next byte of current PC with a CLK delay
        // the fastest PC change would be a CLK

        forever #10 BusAddr = BusAddr + 1;
        
        #100000
        $finish;
    end
endmodule
