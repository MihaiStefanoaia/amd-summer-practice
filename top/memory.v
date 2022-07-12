module MEMORY(  output reg [31:0]D_OUT,
                input [31:0]Din,
                input [WIDTH-1:0]Addr,
                input RW,
                input Valid, //is this like a chip select/enable?
                input RESET,
                input CLK);
    parameter WIDTH = 8;

    reg [31:0]mem [(2 ** WIDTH) - 1 : 0];
    integer i;
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET)
        begin
            D_OUT <= 32'h00000000;
            for(i = 0; i < (2 ** WIDTH); i = i + 1)
                mem[i] <= 8'h00;
        end
        else
        begin
            if(Valid)
            begin
                if(RW)  //write
                begin
                    $display("gets here and writes");
                    mem[Addr] <= Din;
                end
                else    //read
                begin
                    D_OUT <= mem[Addr];
                end
            end
        end
    end
endmodule