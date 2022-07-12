module DIV_frecventa(   input [31:0]DIN_n,
                        input CONFIG_DIV,
                        input RESET,
                        input CLK,
                        input ENABLE,
                        output CLK_OUT);
    reg [31:0] conf;
    reg [31:0] counter;
    wire even;
    reg odd;
    assign even = (conf <= counter * 2);
    assign CLK_OUT = ((conf == 1) ? (CLK) : (even || odd)) && ENABLE;
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            odd <= 1;
            conf <= 32'b1;
            counter <= 32'b0;
        end
        else
        begin
            if(!ENABLE)
            begin
                counter <= 0;

                if(CONFIG_DIV)
                begin
                    conf <= DIN_n;
                    counter <= 0;
                end
            end
            else
            begin
                if(conf == 0) //just in case
                    conf <= 32'b1;
                else
                begin
                    if(conf == counter + 1)
                        counter <= 32'b0;
                    else
                        counter <= counter + 1;
                end                
            end
        end
    end

    always @(negedge CLK) begin
        if(conf[0] && !odd)
        begin
            if(conf == counter + 1)
            begin
                odd <= 1;
            end
        end
        else
            odd <= 0;
    end
endmodule

module tester();
    reg [31:0]DIN_n;
    reg CONFIG_DIV;
    reg RESET;
    wire CLK;
    reg ENABLE;
    wire CLK_OUT;
    Clock clk(CLK);
    DIV_frecventa divf(DIN_n, CONFIG_DIV, RESET, CLK, ENABLE, CLK_OUT);

    initial
    begin
        $dumpfile("div.vcd");
        $dumpvars(0,DIN_n,CONFIG_DIV,RESET,CLK,ENABLE,CLK_OUT);
        RESET = 1;
        ENABLE = 1;

#10     RESET = 0;

#20     ENABLE = 0;
        CONFIG_DIV = 1;
        DIN_n = 3;

#10     ENABLE = 1;

#120    ENABLE = 0;

#50     ENABLE = 1;

#200    $finish();
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