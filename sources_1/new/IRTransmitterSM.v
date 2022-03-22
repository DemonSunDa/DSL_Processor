`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Dawei Sun
// 
// Create Date: 17.02.2022 21:42:40
// Design Name: Processor
// Module Name: IRTransmitterSM
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


module IRTransmitterSM(
    // standard signals
    input CLK,
    input RESET,
    // bus interface signals
    input [3:0] COMMAND,
    input SEND_PACKET,
    //IR LED signal
    output IR_LED
);


//////BLUE
//    parameter HCYC_PULSE    = 1389 - 1; // 100M / 36K / 2
//    parameter SZ_START      = 191 - 1;
//    parameter SZ_CARSEL     = 47 - 1;
//    parameter SZ_GAP        = 25 - 1;
//    parameter SZ_ASSERT     = 47 - 1;
//    parameter SZ_DEASSERT   = 22 - 1;
//////BLUE

////YELLOW
    parameter HCYC_PULSE    = 1250 - 1; // 100M / 40K / 2
    parameter SZ_START      = 88 - 1;
    parameter SZ_CARSEL     = 22 - 1;
    parameter SZ_GAP        = 40 - 1;
    parameter SZ_ASSERT     = 44 - 1;
    parameter SZ_DEASSERT   = 22 - 1;
////YELLOW

//////GREEN
//    parameter HCYC_PULSE    = 1333 - 1; // 100M / 37.5K / 2
//    parameter SZ_START      = 88 - 1;
//    parameter SZ_CARSEL     = 44 - 1;
//    parameter SZ_GAP        = 40 - 1;
//    parameter SZ_ASSERT     = 44 - 1;
//    parameter SZ_DEASSERT   = 22 - 1;
//////GREEN

//////RED
//    parameter HCYC_PULSE    = 1389 - 1; // 100M / 36K / 2
//    parameter SZ_START      = 192  - 1;
//    parameter SZ_CARSEL     = 24 - 1;
//    parameter SZ_GAP        = 24 - 1;
//    parameter SZ_ASSERT     = 48 - 1;
//    parameter SZ_DEASSERT   = 24 - 1;
//////RED

    
    parameter START     = 4'b0000;
    parameter GAP1      = 4'b0001;
    parameter CARSEL    = 4'b0010;
    parameter GAP2      = 4'b0011;
    parameter RIGHT     = 4'b0100;
    parameter GAP3      = 4'b0101;
    parameter LEFT      = 4'b0110;
    parameter GAP4      = 4'b0111;
    parameter BACKWARD  = 4'b1000;
    parameter GAP5      = 4'b1001;
    parameter FORWARD   = 4'b1010;
    parameter GAP6      = 4'b1011;

    wire trig_sigpulse; // trigger for signal generation
    wire [11:0] ctr_sigpulse;
    wire trig_carpulse; // trigger for one cycle of signal, f(trig_carpulse) = 1/2 f(trig_sigpulse)
    wire ctr_carpulse;

    reg [3:0] st_curr;
    reg [3:0] st_next;
    reg [7:0] ctr_curr;
    reg [7:0] ctr_next;
    reg tp_IR_curr; // IR signal envelope
    reg tp_IR_next;
    
    reg [3:0] store_cm; // command storage for one cycle of signal
    
    reg pulse_sig; // signal
    reg tp_out;


//  pulse signal
    Generic_counter # (
        .CTR_WIDTH(12),
        .CTR_MAX(HCYC_PULSE)
    )
    SigPulse (
        .CLK(CLK),
        .RESET(SEND_PACKET),
        .ENABLE(1'b1),
        .OUT_TRIG(trig_sigpulse),
        .OUT_CTR(ctr_sigpulse)
    );

    always @(posedge CLK or posedge SEND_PACKET or posedge RESET) begin
        if (RESET | SEND_PACKET) begin
            pulse_sig <= 1'b0;
        end
        else begin
            if (trig_sigpulse) begin
                pulse_sig <= ~pulse_sig;
            end
            else begin
                pulse_sig <= pulse_sig;
            end
        end
    end

    Generic_counter # (
        .CTR_WIDTH(1),
        .CTR_MAX(1)
    )
    CarPulse (
        .CLK(CLK),
        .RESET(SEND_PACKET),
        .ENABLE(trig_sigpulse),
        .OUT_TRIG(trig_carpulse),
        .OUT_CTR(ctr_carpulse)
    );
//  pulse signal


//  command storage
    always @(posedge CLK or posedge SEND_PACKET or posedge RESET) begin
        if (RESET) begin
            store_cm <= 4'b0000;
        end
        else begin
            if (SEND_PACKET | trig_carpulse) begin
                store_cm <= COMMAND;
            end
            else begin
                store_cm <= store_cm;
            end
        end
    end
//  command storage


//  IR_SM
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            st_curr <= GAP6;
            ctr_curr <= 0;
            tp_IR_curr <= 1'b0;
        end
        else begin
            if (SEND_PACKET) begin
                st_curr <= START;
                ctr_curr <= 1'b0;
                tp_IR_curr <= 1'b1;
            end
            else begin
                if (trig_carpulse) begin
                    st_curr <= st_next;
                    ctr_curr <= ctr_next;
                    tp_IR_curr <= tp_IR_next;
                end
                else begin
                    st_curr <= st_curr;
                    ctr_curr <= ctr_curr;
                    tp_IR_curr <= tp_IR_curr;
                end
            end
        end
    end

    always @(*) begin
        case (st_curr)
            START : begin
                if (ctr_curr == SZ_START) begin
                    st_next <= GAP1;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b0;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b1;
                end
            end
            GAP1 : begin
                if (ctr_curr == SZ_GAP) begin
                    st_next <= CARSEL;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
            CARSEL : begin
                if (ctr_curr == SZ_CARSEL) begin
                    st_next <= GAP2;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b0;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b1;
                end
            end
            GAP2 :  begin
                if (ctr_curr == SZ_GAP) begin
                    st_next <= RIGHT;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
            RIGHT : begin
                if (store_cm[0]) begin
                    if (ctr_curr == SZ_ASSERT) begin // assert
                        st_next <= GAP3;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
                else begin
                    if (ctr_curr == SZ_DEASSERT) begin // deassert
                        st_next <= GAP3;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
            end
            GAP3 :  begin
                if (ctr_curr == SZ_GAP) begin
                    st_next <= LEFT;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
            LEFT :  begin
                if (store_cm[1]) begin
                    if (ctr_curr == SZ_ASSERT) begin
                        st_next <= GAP4;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
                else begin
                    if (ctr_curr == SZ_DEASSERT) begin
                        st_next <= GAP4;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
            end
            GAP4 :  begin
                if (ctr_curr == SZ_GAP) begin
                    st_next <= BACKWARD;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
            BACKWARD :  begin
                if (store_cm[2]) begin
                    if (ctr_curr == SZ_ASSERT) begin
                        st_next <= GAP5;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
                else begin
                    if (ctr_curr == SZ_DEASSERT) begin
                        st_next <= GAP5;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
            end
            GAP5 :  begin
                if (ctr_curr == SZ_GAP) begin
                    st_next <= FORWARD;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
            FORWARD :  begin
                if (store_cm[3]) begin
                    if (ctr_curr == SZ_ASSERT) begin
                        st_next <= GAP6;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
                else begin
                    if (ctr_curr == SZ_DEASSERT) begin
                        st_next <= GAP6;
                        ctr_next <= 0;
                        tp_IR_next <= 1'b0;
                    end
                    else begin
                        st_next <= st_curr;
                        ctr_next <= ctr_curr + 1;
                        tp_IR_next <= 1'b1;
                    end
                end
            end
            GAP6 :  begin
                if (SEND_PACKET) begin
                    st_next <= START;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
            default : begin
                if (SEND_PACKET) begin
                    st_next <= START;
                    ctr_next <= 0;
                    tp_IR_next <= 1'b1;
                end
                else begin
                    st_next <= st_curr;
                    ctr_next <= ctr_curr + 1;
                    tp_IR_next <= 1'b0;
                end
            end
        endcase
    end
//  IR_SM


//  output
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            tp_out <= 1'b0;
        end
        else begin
            tp_out <= (tp_IR_curr & pulse_sig);
        end
    end
    
    assign IR_LED = tp_out;
//  output
endmodule
