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
    always @(posedge CLK or posedge RESET)
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