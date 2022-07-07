module controller(  output ACTIVE,
                    output MODE,
                    output ACCESS_MEM,
                    output RW_MEM,
                    output PARALLEL_LOAD,
                    output Tx_DATA,
                    output BUSY,
                    input  INPUT_KEY,
                    input  VALID_CMD,
                    input  RW,
                    input  Tx_DONE,
                    input  RESET,
                    input CLK);
    wire ACTIVE_TMP;
    wire MODE_TMP;

    assign ACTIVE = ACTIVE_TMP;
    assign MODE = MODE_TMP;

    wire [2:0]tmp;
    
    DEC_INPUT_KEY DRM(ACTIVE_TMP,MODE_TMP,INPUT_KEY,VALID_CMD,RESET,CLK,tmp);
    CONTROL_RW_FLOW CTRL(ACCESS_MEM,RW_MEM,PARALLEL_LOAD,Tx_DATA,BUSY,ACTIVE_TMP,MODE_TMP,VALID_CMD,RW,Tx_DONE,RESET,CLK);
endmodule

module DEC_INPUT_KEY(   output reg ACTIVE,
                        output reg MODE,
                        input      INPUT_KEY,
                        input      VALID,
                        input      RESET,
                        input      CLK,
                        output reg [2:0] DEBUG_STATE);
    reg s0;
    reg s1;
    reg s2;

    always @(posedge CLK or posedge RESET)
    begin
        if(RESET)
        begin
            s0 <= 0;
            s1 <= 0;
            s2 <= 0;
            ACTIVE <= 0;
            MODE <= 0;
        end
        else
        begin
            s0 <= (s2 & ~s1 & s0) | (VALID & ~INPUT_KEY & s2 & ~s1) | (VALID & INPUT_KEY & ~s2 & ~s0);
            s1 <= (s2 & s1 & ~s0) | (VALID & INPUT_KEY & s1 & ~s0) | (VALID & INPUT_KEY & s2 & ~s0) | (VALID & INPUT_KEY & ~s2 & ~s1 & s0);
            s2 <= (s2 & s1 & ~s0) | (s2 & ~s1 & s0) | (VALID & s2 & ~s1) | (VALID & ~INPUT_KEY & ~s2 & s1 & s0);
            ACTIVE <= (s2 & s1 & ~s0) | (s2 & ~s1 & s0);

            DEBUG_STATE = {s2,s1,s0};
        end
    end
endmodule

module Clock(output c);
    reg value;
    assign c = value;

    initial
        value = 0;

    always
    #5 value = ~value;
endmodule

module tester();
    wire ACTIVE;
    wire MODE;
    reg  INPUT_KEY;
    reg  VALID_CMD;
    reg  RESET;
    wire CLK;
    wire [2:0]STATE;
    Clock clk(CLK);
    DEC_INPUT_KEY dec(ACTIVE,MODE,INPUT_KEY,VALID_CMD,RESET,CLK,STATE);

    initial
    begin
        $dumpfile("dump.vcd");
        $dumpvars(0,ACTIVE,MODE,INPUT_KEY,VALID_CMD,RESET,CLK,STATE);

        RESET = 1;
        VALID_CMD = 0;

#5      RESET = 0;

        //fail on the first input
#10     VALID_CMD = 1;
        INPUT_KEY = 0;

        //fail on the second input
#7     RESET = 1;
#3      RESET = 0;
#5      INPUT_KEY = 1;
#10     INPUT_KEY = 1;

        //fail on the third input
#12     RESET = 1;
#3      RESET = 0;
#5      INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 0;

        //fail on the fourth input
#12     RESET = 1;
#3      RESET = 0;
#5      INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1;
#10     INPUT_KEY = 1;

        //succeed with mode 0
#12     RESET = 1;
#3      RESET = 0;
#5      INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 0;

#20     

        //succeed with mode 1
#12     RESET = 1;
#3      RESET = 0;
#5      INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1;

#20     $finish();
    end
endmodule


module CONTROL_RW_FLOW( output reg ACCESS_MEM,
                        output reg RW_MEM,
                        output reg PARALLEL_LOAD,
                        output reg Tx_DATA,
                        output reg BUSY,
                        input      ACTIVE,
                        input      MODE,
                        input      VALID_CMD,
                        input      RW,
                        input      Tx_DONE,
                        input      RESET,
                        input      CLK);
endmodule

module D_FF(output reg Q,
            input      D,
            input      CLK);
    always @(posedge CLK)
    begin
        Q <= D;
    end
endmodule

