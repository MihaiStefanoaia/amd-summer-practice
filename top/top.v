module BINARY_CALC( input INPUT_KEY,
                    input VALID_CMD,
                    input RW_MEM,
                    input [7:0] ADDR,
                    input [7:0] IN_A,
                    input [7:0] IN_B,
                    input [3:0] SEL,
                    input CONFIG_DIV,
                    input [31:0] DIN,
                    output CALC_ACTIVE,
                    output CALC_MODE,
                    output BUSY,
                    output D_OUT_VALID,
                    output D_OUT,
                    output CLK_Tx,
                    input RESET,
                    input CLK,
                    output [31:0] DEBUG);
    localparam ZERO = 8'b0;
    
    wire CTRL_ACTIVE;
    assign CALC_ACTIVE = CTRL_ACTIVE;

    wire RESET_INTERNAL;
    assign RESET_INTERNAL = RESET & ~CTRL_ACTIVE;
    
    wire RW_INTERNAL;
    assign RW_INTERNAL = RW_MEM & CTRL_ACTIVE;

    wire CTRL_RW_MEM;
    wire CTRL_ACCESS_MEM;

    wire CTRL_MODE;
    wire CTRL_SAMPLE_DATA; //PARALLEL_LOAD
    wire CTRL_TRANSFER_DATA; //CLK DIV ENABLE
    assign CALC_MODE = CTRL_MODE;

    wire TX_DONE;

    controller CONTROLLER(  .ACTIVE(CTRL_ACTIVE),
                            .MODE(CTRL_MODE),
                            .ACCESS_MEM(CTRL_ACCESS_MEM),
                            .RW_MEM(CTRL_RW_MEM),
                            .PARALLEL_LOAD(CTRL_SAMPLE_DATA),
                            .Tx_DATA(CTRL_TRANSFER_DATA),
                            .BUSY(BUSY),
                            .INPUT_KEY(INPUT_KEY),
                            .VALID_CMD(VALID_CMD),
                            .RW(RW_INTERNAL),
                            .Tx_DONE(TX_DONE),
                            .RESET(RESET),
                            .CLK(CLK));

    wire [7:0]A_INTERNAL;
    wire [7:0]B_INTERNAL;
    wire [3:0]SEL_INTERNAL;
    MUX2x1 A(IN_A,ZERO,RESET_INTERNAL,A_INTERNAL);
    MUX2x1 B(IN_B,ZERO,RESET_INTERNAL,B_INTERNAL);
    MUX2x1 #(.WIDTH(4)) 
           SEL_(SEL,ZERO[3:0],RESET_INTERNAL,SEL_INTERNAL);

    wire [7:0]ALU_OUT_TMP;
    wire [3:0]FLAG_TMP;

    M_ALU ALU(  .ALU_OUT_TMP(ALU_OUT_TMP),
                .FLAG_TMP(FLAG_TMP),
                .A(A_INTERNAL),
                .B(B_INTERNAL),
                .SEL_TMP(SEL_INTERNAL));

    wire [31:0]DATA_TMP;

    concatenator BUFFER(.A(A_INTERNAL),
                        .B(B_INTERNAL),
                        .C(ALU_OUT_TMP),
                        .D(SEL_INTERNAL),
                        .E(FLAG_TMP),
                        .OUT(DATA_TMP));
    
    wire [31:0]MEM_DATA_OUT;
    wire [31:0]PARALLEL_DATA_OUT;

    MEMORY MEM( .Din(DATA_TMP),
                .Addr(ADDR),
                .RW(CTRL_RW_MEM),
                .Valid(CTRL_ACCESS_MEM),
                .D_OUT(MEM_DATA_OUT),
                .RESET(RESET_INTERNAL),
                .CLK(CLK));

    MUX2x1 #(.WIDTH(32)) 
           DATA_SEL(DATA_TMP,MEM_DATA_OUT,CTRL_MODE,PARALLEL_DATA_OUT);

    wire CLK_TX_TMP;
    assign CLK_Tx = CLK_TX_TMP;

    REGISTRU_SHIFT_PARALLELLOAD shift(  .DIN(PARALLEL_DATA_OUT),
                                        .PARALLEL_LOAD(CTRL_SAMPLE_DATA),
                                        .START_TX(CTRL_TRANSFER_DATA),
                                        .TX_DONE(TX_DONE),
                                        .Tx_BUSY(D_OUT_VALID),
                                        .SOUT(D_OUT),
                                        .RESET(RESET_INTERNAL),
                                        .CLK(CLK),
                                        .CLK_Tx(CLK_TX_TMP));

    DIV_frecventa REDUCER(  .DIN_n(DIN),
                            .CONFIG_DIV(CONFIG_DIV),
                            .RESET(RESET_INTERNAL),
                            .CLK(CLK),
                            .ENABLE(CTRL_TRANSFER_DATA),
                            .CLK_OUT(CLK_TX_TMP));

    assign DEBUG = PARALLEL_DATA_OUT;
                            
endmodule