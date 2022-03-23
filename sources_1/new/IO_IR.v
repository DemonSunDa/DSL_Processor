`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 22.03.2022 21:35:40
// Design Name: Processor
// Module Name: IO_IR
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


module IO_IR(
    // Standard signals
    input CLK,
    input RESET,
    // Bus signals
    input [7:0] BUS_DATA, // no output to bus needed
    input [7:0] BUS_ADDR,
    input BUS_WE,
    // IR
    output reg IR_LED
);

////BLUE
    parameter HCYC_PULSE_B      = 1389 - 1; // 100M / 36K / 2
    parameter SZ_START_B        = 191 - 1;
    parameter SZ_CARSEL_B       = 47 - 1;
    parameter SZ_GAP_B          = 25 - 1;
    parameter SZ_ASSERT_B       = 47 - 1;
    parameter SZ_DEASSERT_B     = 22 - 1;
////BLUE

////YELLOW
    parameter HCYC_PULSE_Y      = 1250 - 1; // 100M / 40K / 2
    parameter SZ_START_Y        = 88 - 1;
    parameter SZ_CARSEL_Y       = 22 - 1;
    parameter SZ_GAP_Y          = 40 - 1;
    parameter SZ_ASSERT_Y       = 44 - 1;
    parameter SZ_DEASSERT_Y     = 22 - 1;
////YELLOW

////GREEN
    parameter HCYC_PULSE_G      = 1333 - 1; // 100M / 37.5K / 2
    parameter SZ_START_G        = 88 - 1;
    parameter SZ_CARSEL_G       = 44 - 1;
    parameter SZ_GAP_G          = 40 - 1;
    parameter SZ_ASSERT_G       = 44 - 1;
    parameter SZ_DEASSERT_G     = 22 - 1;
////GREEN

////RED
    parameter HCYC_PULSE_R      = 1389 - 1; // 100M / 36K / 2
    parameter SZ_START_R        = 192  - 1;
    parameter SZ_CARSEL_R       = 24 - 1;
    parameter SZ_GAP_R          = 24 - 1;
    parameter SZ_ASSERT_R       = 48 - 1;
    parameter SZ_DEASSERT_R     = 24 - 1;
////RED

    parameter IRBaseAddr = 8'h90;


    reg [7:0] BusDataIn;
    wire [3:0] COMMAND;
    wire [3:0] CarType;
    wire idcCarType;

    always @(posedge CLK) begin
        if (RESET) begin
            BusDataIn <= 8'h01; // Default to COMMAND 0000, CarType 0001
        end
        else begin
            if ((BUS_ADDR == IRBaseAddr) & BUS_WE) begin // CPU writing to IR module
                BusDataIn <= BUS_DATA;
            end
            else begin
                BusDataIn <= BusDataIn;
            end
        end
    end

    assign COMMAND = BusDataIn[7:4];
    assign CarType = BusDataIn[3:0];
    assign idcCarType = (&CarType[1:0]) | (&CarType[3:2]) | (!(^CarType));


    wire SEND_PACKET;
    wire [23:0] ctr_sendpacket;

    Generic_counter # (
        .CTR_WIDTH(24),
        .CTR_MAX(9999999)
    )
    SendPacket (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(1'b1),
        .OUT_TRIG(SEND_PACKET),
        .OUT_CTR(ctr_sendpacket)
    );


    wire IR_LED_B;
    wire IR_LED_Y;
    wire IR_LED_G;
    wire IR_LED_R;
    
    // 0 only when CarType is one of the following, otherwise stop IR
    // 0001 - BLUE
    // 0010 - YELLOW
    // 0100 - GREEN
    // 1000 - RED

    IRTransmitterSM # (
        .HCYC_PULSE(HCYC_PULSE_B),
        .SZ_START(SZ_START_B),
        .SZ_CARSEL(SZ_CARSEL_B),
        .SZ_GAP(SZ_GAP_B),
        .SZ_ASSERT(SZ_ASSERT_B),
        .SZ_DEASSERT(SZ_DEASSERT_B)
    )
    IR_B (
        // Standard signals
        .CLK(CLK),
        .RESET(RESET | (!CarType[0])),
        // Bus signals
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        // IR
        .IR_LED(IR_LED_B)
    );

    IRTransmitterSM # (
        .HCYC_PULSE(HCYC_PULSE_Y),
        .SZ_START(SZ_START_Y),
        .SZ_CARSEL(SZ_CARSEL_Y),
        .SZ_GAP(SZ_GAP_Y),
        .SZ_ASSERT(SZ_ASSERT_Y),
        .SZ_DEASSERT(SZ_DEASSERT_Y)
    )
    IR_Y (
        // Standard signals
        .CLK(CLK),
        .RESET(RESET | (!CarType[1])),
        // Bus signals
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        // IR
        .IR_LED(IR_LED_Y)
    );

    IRTransmitterSM # (
        .HCYC_PULSE(HCYC_PULSE_G),
        .SZ_START(SZ_START_G),
        .SZ_CARSEL(SZ_CARSEL_G),
        .SZ_GAP(SZ_GAP_G),
        .SZ_ASSERT(SZ_ASSERT_G),
        .SZ_DEASSERT(SZ_DEASSERT_G)
    )
    IR_G (
        // Standard signals
        .CLK(CLK),
        .RESET(RESET | (!CarType[2])),
        // Bus signals
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        // IR
        .IR_LED(IR_LED_G)
    );

    IRTransmitterSM # (
        .HCYC_PULSE(HCYC_PULSE_R),
        .SZ_START(SZ_START_R),
        .SZ_CARSEL(SZ_CARSEL_R),
        .SZ_GAP(SZ_GAP_R),
        .SZ_ASSERT(SZ_ASSERT_R),
        .SZ_DEASSERT(SZ_DEASSERT_R)
    )
    IR_R (
        // Standard signals
        .CLK(CLK),
        .RESET(RESET | (!CarType[3])),
        // Bus signals
        .COMMAND(COMMAND),
        .SEND_PACKET(SEND_PACKET),
        // IR
        .IR_LED(IR_LED_R)
    );


    always @(posedge CLK) begin
        if (RESET) begin
            IR_LED <= 1'b0;
        end
        else begin
            case (CarType)
                4'b0001 : IR_LED <= IR_LED_B;
                4'b0010 : IR_LED <= IR_LED_Y;
                4'b0100 : IR_LED <= IR_LED_G;
                4'b1000 : IR_LED <= IR_LED_R;
                default : IR_LED <= 1'b0;
            endcase
        end
    end

endmodule
