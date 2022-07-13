module tester();
    reg INPUT_KEY;
    reg VALID_CMD;
    reg RW_MEM;
    reg [7:0] ADDR;
    reg [7:0] IN_A;
    reg [7:0] IN_B;
    reg [3:0] SEL;
    reg CONFIG_DIV;
    reg [31:0] DIN;
    wire CALC_ACTIVE;
    wire CALC_MODE;
    wire BUSY;
    wire D_OUT_VALID;
    wire D_OUT;
    wire CLK_Tx;
    reg RESET;
    wire CLK;

    Clock clk(CLK);
    BINARY_CALC CALC(   .INPUT_KEY(INPUT_KEY),
                        .VALID_CMD(VALID_CMD),
                        .RW_MEM(RW_MEM),
                        .ADDR(ADDR),
                        .IN_A(IN_A),
                        .IN_B(IN_B),
                        .SEL(SEL),
                        .CONFIG_DIV(CONFIG_DIV),
                        .DIN(DIN),
                        .CALC_ACTIVE(CALC_ACTIVE),
                        .CALC_MODE(CALC_MODE),
                        .BUSY(BUSY),
                        .D_OUT_VALID(D_OUT_VALID),
                        .D_OUT(D_OUT),
                        .CLK_Tx(CLK_Tx),
                        .RESET(RESET),
                        .CLK(CLK));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
        //$dumpvars(0,INPUT_KEY,VALID_CMD,CALC_ACTIVE,CALC_MODE,CLK,RESET,D_OUT_VALID,D_OUT,CLK_Tx);//all of it
        //$dumpvars(0,INPUT_KEY,VALID_CMD,CALC_ACTIVE,CALC_MODE,CLK,RESET);//check for proper activation
        //$dumpvars(0,D_OUT_VALID,D_OUT,CLK_Tx,DEBUG);//check for transfer
        RESET = 1;
        
        IN_A = 10;
        IN_B = 7;
        SEL = 0;//a+b

        RW_MEM = 1;

#10     RESET = 0;


//input the password
        VALID_CMD = 1;

        INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 0; //activate and start in mode 0

//setup the freq divisor
#10     DIN = 1;
        CONFIG_DIV = 1;
#10     CONFIG_DIV = 0;

//transfer the data over serial - success
#500    RESET = 1;


//reset the system
#20     RESET = 0;
        INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1;
#10     INPUT_KEY = 0;
#10     INPUT_KEY = 1; //activate and start in mode 1

//setup the freq divisor
#10     DIN = 2;
        CONFIG_DIV = 1;
#10     CONFIG_DIV = 0;


//setup and save the first calculation
#10     VALID_CMD = 0;
        ADDR = 0;
        RW_MEM = 1;

#10     VALID_CMD = 1;
#20     VALID_CMD = 0;
//setup and save the second calculation
        ADDR = 5;
        IN_A = 28;
        IN_B = 4;
        SEL = 3;// A/B
#10     VALID_CMD = 1;
#20     VALID_CMD = 0;
//setup reading the result of the first operation
        ADDR = 0;
        RW_MEM = 0;
#10     VALID_CMD = 1;
#670    VALID_CMD = 0;
        ADDR = 5;

#10     VALID_CMD = 1;
#670    VALID_CMD = 0;

#50     $finish();

    end
endmodule