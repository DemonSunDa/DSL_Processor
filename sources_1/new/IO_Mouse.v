`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 22.03.2022 14:16:24
// Design Name: Processor
// Module Name: IO_Mouse
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      Wrapping up the mouse module interracting with main bus.
//      Input device.
//      Addressed at    0xA0    status
//                      0xA1    X
//                      0xA2    Y
//                      0xA3    Z
//      With a interrupt interface INTERRUPT[0].
// Dependencies: 
//      MouseTransceiver.v
//          MouseTransmitter.v
//          MouseReceiver.v
//          MouseMasterSM.v
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IO_Mouse(
    // Standard signals
    input CLK,
    input RESET,
    // BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    // IO mouse
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // interrupt signals
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK
);

    parameter MouseBaseAddr = 8'hA0; // mouse base address in the memory map
    // 4 bytes are used inetead of 3, for Z


    wire [7:0] BusDataIn;
    reg [7:0] Out;
    reg IOBusWE; // mouse write to bus enabler

    assign BUS_DATA = IOBusWE ? Out : 8'hZZ;
    assign BusDataIn = BUS_DATA;


    wire [3:0] MouseStatus;
    wire [7:0] MouseX;
    wire [7:0] MouseY;
    wire [7:0] MouseZ;
    wire SendInterrupt;

    MouseTransceiver mouse(
        // Standard signals
        .CLK(CLK),
        .RESET(RESET),
        // IO mouse
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        // Mouse info
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        .MouseZ(MouseZ),
        .SendInterrupt(SendInterrupt)
    );


    // Clock the interrupt
    reg Interrupt;

    always @(posedge CLK) begin
        if (RESET) begin
            Interrupt <= 1'b1;
        end
        else if (SendInterrupt) begin
            Interrupt <= 1'b1;
        end
        else if (BUS_INTERRUPT_ACK) begin // clear the flag on ack
            Interrupt <= 1'b0;
        end
        else begin
            Interrupt <= Interrupt;
        end
    end

    assign BUS_INTERRUPT_RAISE = Interrupt;


    reg [7:0] InternalMem[3:0]; // 4 bytes

    // Refresh the stored values every CLK
    always @(posedge CLK) begin
        if ((BUS_ADDR >= MouseBaseAddr) & (BUS_ADDR < MouseBaseAddr + 8'h04)) begin // if mouse addressed
            if (BUS_WE) begin // if CPU writing
                InternalMem[BUS_ADDR[3:0]] <= BusDataIn; // lower 4 bits of the address
                IOBusWE <= 1'b0;
            end
            else begin
                InternalMem[0] <= InternalMem[0];
                InternalMem[1] <= InternalMem[1];
                InternalMem[2] <= InternalMem[2];
                InternalMem[3] <= InternalMem[2];
                IOBusWE <= 1'b1;
            end
        end
        else begin
            InternalMem[0] <= {4'b0, MouseStatus};
            InternalMem[1] <= MouseX;
            InternalMem[2] <= MouseY;
            InternalMem[3] <= MouseZ;
            IOBusWE <= 1'b0;
        end
    end

    // Clocked output
    always @(posedge CLK) begin
        Out <= InternalMem[BUS_ADDR[3:0]];
    end

endmodule
