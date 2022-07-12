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