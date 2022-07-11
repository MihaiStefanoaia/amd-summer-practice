module REGISTRU_SHIFT_PARALLELLOAD( input [31:0]DIN,
                                    input PARALLEL_LOAD,
                                    input START_TX,
                                    input RESET,
                                    input CLK,
                                    input CLK_Tx,
                                    output reg TX_DONE,
                                    output Tx_BUSY,
                                    output SOUT);
    reg [31:0]data;
    reg [5:0]pointer;
    reg serial_enable;
    reg serial_data;
    reg done;

    assign Tx_BUSY = serial_enable; 
    assign SOUT = serial_data & CLK_Tx;

    always @(posedge CLK or posedge RESET)
    begin
        if(RESET)
        begin
            serial_enable <= 0;
            data  <= 32'b0;
            pointer <= 5'b0;
            done <= 0;
            serial_data <= 0;
        end
        else
        begin
            if(PARALLEL_LOAD && !START_TX)
            begin
                data <= DIN;
                pointer <= 0;
            end
            else if(!PARALLEL_LOAD && START_TX)
            begin
                if(!serial_enable)
                begin
                    serial_enable <= 1;
                    pointer <=0;
                end
            end
        end

        if(done)
        begin
            TX_DONE <= 1;
            done <= 0;
        end
        else
        begin
            TX_DONE <= 0;
        end
    end

    always @(posedge CLK_Tx)
    begin
        if(serial_enable)
        begin
            if(pointer != 32)
            begin
                serial_data <= data[pointer];
                pointer <= pointer + 1;
            end
            else
            begin
                serial_enable <= 0;
                done <= 1;
            end
        end
    end
endmodule

module tester();
    reg [31:0]DIN;
    reg PARALLEL_LOAD;
    reg START_TX;
    reg RESET;
    wire CLK;
    wire CLK_Tx;
    wire TX_DONE;
    wire Tx_BUSY;
    wire SOUT;

    Clock clk(CLK);
    Clock_tx clk_tx(CLK_Tx);
    REGISTRU_SHIFT_PARALLELLOAD DUT(DIN, PARALLEL_LOAD, START_TX, RESET, CLK, CLK_Tx, TX_DONE, Tx_BUSY, SOUT);

    initial
    begin
        $dumpfile("transfer.vcd");
        $dumpvars(0,DIN, PARALLEL_LOAD, START_TX, RESET, CLK, CLK_Tx, TX_DONE, Tx_BUSY, SOUT);
        RESET = 1;

#5      RESET = 0;
        DIN = 32'h12345678;
        PARALLEL_LOAD = 1;
        START_TX = 0;

#5      PARALLEL_LOAD = 0;
        START_TX = 1;

#10     PARALLEL_LOAD = 0;
        START_TX = 0;


#680    $finish();
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

module Clock_tx(output c);
    reg value;
    assign c = value;

    initial
        value = 0;

    always
    begin
    #15 value = ~value;
    #5  value = ~value;
    end
endmodule