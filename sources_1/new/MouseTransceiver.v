`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 25.02.2022 00:15:22
// Design Name: Processor
// Module Name: MouseTransceiver
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      Top level of mouse module.
// Dependencies: 
//      MouseTransmitter.v
//      MouseReceiver.v
//      MouseMasterSM.v
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MouseTransceiver (
    // Standard signals
    input CLK,
    input RESET,
    // IO mouse
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // Mouse info
    output reg [3:0] MouseStatus,
    output reg [7:0] MouseX,
    output reg [7:0] MouseY,
    output reg [7:0] MouseZ,
    output SendInterrupt
);


    // X, Y limits of mouse position. For VGA screen 160 * 120
    parameter [7:0] MouseLimitX = 160;
    parameter [7:0] MouseLimitY = 120;
    parameter [7:0] MouseLimitZ = 256;


    // Tri-state signals
    reg ClkMouseIn;
    wire ClkMouseOutEnTrans;

    wire DataMouseIn;
    wire DataMouseOutTrans;
    wire DataMouseOutEnTrans;

    // CLK output
    assign CLK_MOUSE = ClkMouseOutEnTrans ? 1'b0 : 1'bz;
    // Data input
    assign DataMouseIn = DATA_MOUSE;
    // Data output
    assign DATA_MOUSE = DataMouseOutEnTrans ? DataMouseOutTrans : 1'bz;


    // Filter the incoming mouse clock to make sure it is stable
    reg [7:0] MouseClkFilter;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            ClkMouseIn <= 1'b0;
        end
        else begin
            MouseClkFilter[7:1] <= MouseClkFilter[6:0];
            MouseClkFilter[0] <= CLK_MOUSE;

            // wait for 8 cycles and test if all the CLK inputs are the same
            if (ClkMouseIn & (MouseClkFilter == 8'h00)) begin
                ClkMouseIn <= 1'b0;
            end
            else if (~ClkMouseIn & (MouseClkFilter == 8'hFF)) begin
                ClkMouseIn <= 1'b1;
            end
        end
    end


    wire SendByteToMouse;
    wire ByteSentToMouse;
    wire [7:0] ByteToSendToMouse;
    MouseTransmitter T (
        // Standard Inputs
        .CLK(CLK),
        .RESET(RESET),
        // Mouse IO
        .CLK_MOUSE_IN(ClkMouseIn),
        .CLK_MOUSE_OUT_EN(ClkMouseOutEnTrans),
        .DATA_MOUSE_IN(DataMouseIn),
        .DATA_MOUSE_OUT(DataMouseOutTrans),
        .DATA_MOUSE_OUT_EN(DataMouseOutEnTrans),
        // Control
        .SEND_BYTE(SendByteToMouse),
        .BYTE_TO_SEND(ByteToSendToMouse),
        .BYTE_SENT(ByteSentToMouse)
    );


    wire ReadEnable;
    wire [7:0] ByteRead;
    wire [1:0] ByteErrorCode;
    wire ByteReady;
    MouseReceiver R (
        // Standard Inputs
        .CLK(CLK),
        .RESET(RESET),
        // Mouse IO
        .CLK_MOUSE_IN(ClkMouseIn),
        .DATA_MOUSE_IN(DataMouseIn),
        // Control
        .READ_ENABLE(ReadEnable),
        .BYTE_READ(ByteRead),
        .BYTE_ERROR_CODE(ByteErrorCode),
        .BYTE_READY(ByteReady)
    );


    wire [7:0] MouseStatusRaw;
    wire [7:0] MouseDxRaw;
    wire [7:0] MouseDyRaw;
    wire [7:0] MouseDzRaw;
    wire [3:0] MasterStateCode;
    MouseMasterSM MSM (
        // Standard Inputs
        .CLK(CLK),
        .RESET(RESET),
        // Transmitter Interface
        .SEND_BYTE(SendByteToMouse),
        .BYTE_TO_SEND(ByteToSendToMouse),
        .BYTE_SENT(ByteSentToMouse),
        // Receiver Interface
        .READ_ENABLE(ReadEnable),
        .BYTE_READ(ByteRead),
        .BYTE_ERROR_CODE(ByteErrorCode),
        .BYTE_READY(ByteReady),
        // Data Registers
        .MOUSE_STATUS(MouseStatusRaw),
        .MOUSE_DX(MouseDxRaw),
        .MOUSE_DY(MouseDyRaw),
        .MOUSE_DZ(MouseDzRaw),
        .SEND_INTERRUPT(SendInterrupt),
        .MasterStateCode(MasterStateCode)
    );


// Pre-processing - handling of overflow and signs.
// More importantly, this keeps tabs on the actual X/Y
// location of the mouse.
    wire signed [8:0] MouseDx;
    wire signed [8:0] MouseDy;
    wire signed [8:0] MouseNewX;
    wire signed [8:0] MouseNewY;
    wire signed [8:0] MouseDz;
    wire signed [8:0] MouseNewZ;
//    reg [3:0] MouseStatus;
//    reg [7:0] MouseX;
//    reg [7:0] MouseY;
//    reg [7:0] MouseZ;

    // DX and DY are modified to take account of overflow and direction
    assign MouseDx = (MouseStatusRaw[6]) ? (MouseStatusRaw[4] ? {MouseStatusRaw[4],8'h00} : {MouseStatusRaw[4],8'hFF} ) : {MouseStatusRaw[4],MouseDxRaw[7:0]};
    assign MouseDy = (MouseStatusRaw[7]) ? (MouseStatusRaw[5] ? {MouseStatusRaw[5],8'h00} : {MouseStatusRaw[5],8'hFF} ) : {MouseStatusRaw[5],MouseDyRaw[7:0]};
    assign MouseDz = {MouseDzRaw[7], MouseDzRaw[7:0]};

    assign MouseNewX = {1'b0, MouseX} + MouseDx;
    assign MouseNewY = {1'b0, MouseY} + MouseDy;
    assign MouseNewZ = {1'b0, MouseZ} + MouseDz;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            MouseStatus <= 0;
            MouseX <= MouseLimitX / 2;
            MouseY <= MouseLimitY / 2;
            MouseZ <= MouseLimitZ / 2;
        end
        else if (SendInterrupt) begin
            MouseStatus <= MouseStatusRaw[3:0];

            // X is modified based on DX with limits on max and min
            if (MouseNewX < 0) begin
                MouseX <= 0;
            end
            else if (MouseNewX > (MouseLimitX - 1)) begin
                MouseX <= MouseLimitX - 1;
            end
            else begin
                MouseX <= MouseNewX[7:0];
            end

            // Y is modified based on DY with limits on max and min
            if (MouseNewY < 0) begin
                MouseY <= 0;
            end
            else if (MouseNewY > (MouseLimitY - 1)) begin
                MouseY <= MouseLimitY - 1;
            end
            else begin
                MouseY <= MouseNewY[7:0];
            end

            //Z is modified based on DZ with limits on max and min
            if (MouseNewZ < 0) begin
                MouseZ <= 0;
            end
            else if (MouseNewZ > (MouseLimitZ - 1)) begin
                MouseZ <= MouseLimitZ - 1;
            end
            else begin
                MouseZ <= MouseNewZ[7:0];
            end
        end
    end
// Pre-processing

endmodule
