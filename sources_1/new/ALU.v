`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:59
// Design Name: Processor
// Module Name: ALU
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


module ALU(
    // Standard signals
    input CLK,
    input RESET,
    // I/O
    input [7:0] IN_A,
    input [7:0] IN_B,
    input [3:0] ALU_Op_Code,
    output [7:0] OUT_RESULT
);

    reg [7:0] Out;

    // Arithmetic computation
    always @(posedge CLK) begin
        if (RESET) begin
            Out <= 0;
        end
        else begin
            case (ALU_Op_Code)
                // Math operations
                // add A + B
                4'h0    :   Out <= IN_A + IN_B;
                // subtract A - B
                4'h1    :   Out <= IN_A - IN_B;
                // multiply A * B
                4'h2    :   Out <= IN_A * IN_B;
                // shift left A << 1
                4'h3    :   Out <= IN_A << 1;
                // shift right A >> 1
                4'h4    :   Out <= IN_A >> 1;
                // increment A + 1
                4'h5    :   Out <= IN_A + 1'b1;
                // increment B + 1
                4'h6    :   Out <= IN_B + 1'b1;
                // decrement A - 1
                4'h7    :   Out <= IN_A - 1'b1;
                // decrement B - 1
                4'h8    :   Out <= IN_B - 1'b1;
                // In/Equality operation
                // A == B for BREQ ADDR
                4'h9    :   Out <= (IN_A == IN_B) ? 8'h01 : 8'h00;
                // A > B for BGTQ ADDR
                4'hA   :   Out <= (IN_A > IN_B) ? 8'h01 : 8'h00;
                // A < B for BLTQ ADDR
                4'hB   :   Out <= (IN_A < IN_B) ? 8'h01 : 8'h00;
                // Default A
                default :   Out <= IN_A;
            endcase
        end
    end

    assign OUT_RESULT = Out;

endmodule
