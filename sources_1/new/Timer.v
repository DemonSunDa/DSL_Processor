`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.03.2022 20:46:18
// Design Name: Processor
// Module Name: Timer
// Project Name: DSL
// Target Devices: Artix-7
// Tool Versions: Vivado 2015
// Description: 
//      Timer module interracting with main bus.
//      Addressed at    0xF0    reports current timer value
//                      0xF1    address of a timer interrupt interval register, 100 ms by default
//                      0xF2    resets the timer, restart counting from zero
//                      0xF3    address of an interrupt enable register, allows the microprocessor to disable the timer
//      With an interrupt interface INTERRUPT[1].
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Timer(
    // Standard signals
    input CLK,
    input RESET,
    // BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    // Interrupt signals
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK
);

    parameter TimerBaseAddr = 8'hF0; // timer base address in the memory map
    parameter InitialInterruptRate = 100; // default interrupt rate leading to 1 interrupt every 100 ms
    parameter InitialInterruptEnable = 1'b1; // by default the interrupt is enabled

    //////////////////////////////////////////////////////////////////////////////
    // BaseAddr + 0 -> reports current timer value
    // BaseAddr + 1 -> address of a timer interrupt interval register, 100 ms by default
    // BaseAddr + 2 -> resets the timer, restart counting from zero
    // BaseAddr + 3 -> address of an interrupt enable register, allows the microprocessor to disable the timer

    // This module will raise an interrupt flag when the designated time is up. It will
    // automatically set the time of the next interrupt to the time of the last interrupt plus
    // a configurable values (in ms).

    // Interrupt rate configuration - The rate is initialised to 100 by the parameterabove, but can
    // also be set by the processor by writing to mem addrress BaseAddr + 1
    reg [7:0] InterruptRate;

    always @(posedge CLK) begin
        if (RESET) begin
            InterruptRate <= InitialInterruptRate;
        end
        else begin
            if ((BUS_ADDR == TimerBaseAddr + 8'h01) & BUS_WE) begin
                InterruptRate <= BUS_DATA;
            end
            else begin
                InterruptRate <= InterruptRate;
            end
        end
    end

    // Interrupt enable configuration - If this is not set to 1, no interrupts will be created
    reg InterruptEnable;

    always @(posedge CLK) begin
        if (RESET) begin
            InterruptEnable <= InitialInterruptEnable;
        end
        else begin
            if ((BUS_ADDR == TimerBaseAddr + 8'h03) & BUS_WE) begin
                InterruptEnable <= BUS_DATA[0];
            end
            else begin
                InterruptEnable <= InterruptEnable;
            end
        end
    end

    // First lower the clock speed from 100 MHz to 1 KHz (1ms period)
    reg [31:0] DownCounter;
    always @(posedge CLK) begin
        if (RESET) begin
            DownCounter <= 0;
        end
        else begin
            if (DownCounter == 32'd99999) begin
                DownCounter <= 0;
            end
            else begin
                DownCounter <= DownCounter + 1;
            end
        end
    end

    // Record the last time an interrupt was sent, and add a value to it to determine
    // if it is time to raise the interrupt

    // 1ms counter (Timer)
    reg [31:0] Timer;

    always @ (posedge CLK) begin
        if (RESET | (BUS_ADDR == TimerBaseAddr + 8'h02)) begin
            Timer <= 0;
        end
        else begin
            if (DownCounter == 0) begin
                Timer <= Timer + 1'b1;
            end
            else begin
                Timer <= Timer;
            end
        end
    end

    // Interrupt generation
    reg TargetReached;
    reg [31:0] LastTime;

    always @(posedge CLK) begin
        if (RESET) begin
            TargetReached <= 1'b0;
            LastTime <= 0;
        end
        else if ((LastTime + InterruptRate) == Timer) begin
            if (InterruptEnable) begin
                TargetReached <= 1'b1;
            end
            else begin
                TargetReached <= TargetReached;
            end
            LastTime <= Timer;
        end
        else begin
            TargetReached <= 1'b0;
        end
    end

    // Broadcast the interrupt
    reg Interrupt;

    always @(posedge CLK) begin
        if (RESET) begin
            Interrupt <= 1'b0;
        end
        else if (TargetReached) begin
            Interrupt <= 1'b1;
        end
        else if (BUS_INTERRUPT_ACK) begin
            Interrupt <= 1'b0;
        end
        else begin
            Interrupt <= Interrupt;
        end
    end

    assign BUS_INTERRUPT_RAISE = Interrupt;

    // Tristate output for interrupt timer output value
    reg TransmitTimerValue;

    always @(posedge CLK) begin
        if (BUS_ADDR == TimerBaseAddr) begin
            TransmitTimerValue <= 1'b1;
        end
        else begin
            TransmitTimerValue <= 1'b0;
        end
    end

    assign BUS_DATA = TransmitTimerValue ? Timer[7:0] : 8'hZZ;

endmodule
