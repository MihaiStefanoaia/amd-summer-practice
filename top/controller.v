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

    wire [2:0]ignore;
    
    DEC_INPUT_KEY DRM(ACTIVE_TMP,MODE_TMP,INPUT_KEY,VALID_CMD,RESET,CLK,ignore);
    CONTROL_RW_FLOW CTRL(ACCESS_MEM,RW_MEM,PARALLEL_LOAD,Tx_DATA,BUSY,ACTIVE_TMP,MODE_TMP,VALID_CMD,RW,Tx_DONE,RESET,CLK,ignore);
endmodule

module DEC_INPUT_KEY(   output reg ACTIVE,
                        output reg MODE,
                        input      INPUT_KEY,
                        input      VALID,
                        input      RESET,
                        input      CLK,
                        output  [2:0] DEBUG_STATE);
    reg s0;
    reg s1;
    reg s2;
    wire s0_;
    wire s1_;
    wire s2_;
    assign s0_ = (s2 & ~s1 & s0) | (VALID & ~INPUT_KEY & s2 & ~s1) | (VALID & INPUT_KEY & ~s2 & ~s0);
    assign s1_ = (s2 & s1 & ~s0) | (VALID & INPUT_KEY & s1 & ~s0) | (VALID & INPUT_KEY & s2 & ~s0) | (VALID & ~INPUT_KEY & ~s2 & ~s1 & s0);
    assign s2_ = (s2 & s1 & ~s0) | (s2 & ~s1 & s0) | (VALID & s2 & ~s1) | (VALID & ~INPUT_KEY & ~s2 & s1 & s0);

    assign DEBUG_STATE = {s2,s1,s0};
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
            s0 <= s0_;
            s1 <= s1_;
            s2 <= s2_;
            
            ACTIVE <= (s2_ & s1_ & ~s0_) | (s2_ & ~s1_ & s0_);
            MODE <= (s2_ & s1_ & ~s0_);
        end
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
                        input      CLK,
                        output [2:0] DEBUG);
    reg [2:0] state;
    reg [2:0] next_state;

    assign DEBUG = state;
    
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET)
            state <= 0;
        else
            state <= next_state;
        
    end

    always @(state, ACTIVE,MODE,VALID_CMD,RW,Tx_DONE)
    begin
        case(state)
            0:begin
                if(VALID_CMD == 1 && RW == 0 && ACTIVE == 1 && MODE == 1 && Tx_DONE == 1) next_state <= 1;
                else if(VALID_CMD == 1 && RW == 1 && ACTIVE == 1 && MODE == 1) next_state <= 4;
                else if(VALID_CMD == 1 && ACTIVE == 1 && MODE == 0 && Tx_DONE == 1) next_state <= 5;
                else next_state <= 0;
            end
            1:begin
                if(ACTIVE == 1 && MODE == 1 && Tx_DONE == 1) next_state <= 2;
                else next_state <= 0;
            end
            2:begin
                if(ACTIVE == 1 && MODE == 1) next_state <= 3;
                else next_state <= 0;
            end
            3:begin
                if(ACTIVE == 1 && MODE == 1 && Tx_DONE == 0) next_state <= 3;
                else next_state <= 0;
            end
            4:begin
                next_state <= 0;
            end
            5:begin
                if(ACTIVE == 1 && MODE == 0) next_state <= 6;
                else next_state <= 0;
            end
            6:begin
                if(ACTIVE == 1 && MODE == 0 && Tx_DONE == 0) next_state <= 6;
                else next_state <= 0;
            end
        endcase
    end

    always @(state)
    begin
        case(state)
            0:begin
                ACCESS_MEM <= 0;
                RW_MEM <= 0;
                PARALLEL_LOAD <= 0;
                Tx_DATA <= 0;
                BUSY <= 0;
            end
            1:begin
                ACCESS_MEM <= 1;
                RW_MEM <= 0;
                PARALLEL_LOAD <= 0;
                Tx_DATA <= 0;
                BUSY <= 1;
            end
            2:begin
                ACCESS_MEM <= 0;
                RW_MEM <= 0;
                PARALLEL_LOAD <= 1;
                Tx_DATA <= 1;
                BUSY <= 1;
            end
            3:begin
                ACCESS_MEM <= 0;
                RW_MEM <= 0;
                PARALLEL_LOAD <= 0;
                Tx_DATA <= 0;
                BUSY <= 1;
            end
            4:begin
                ACCESS_MEM <= 1;
                RW_MEM <= 1;
                PARALLEL_LOAD <= 0;
                Tx_DATA <= 0;
                BUSY <= 0;
            end
            5:begin
                ACCESS_MEM <= 0;
                RW_MEM <= 0;
                PARALLEL_LOAD <= 1;
                Tx_DATA <= 1;
                BUSY <= 1;
            end
            6:begin
                ACCESS_MEM <= 0;
                RW_MEM <= 0;
                PARALLEL_LOAD <= 0;
                Tx_DATA <= 0;
                BUSY <= 1;
            end
        endcase
    end
endmodule