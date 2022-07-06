module MEMORY(  output reg [31:0]D_OUT,
                input [31:0]Din,
                input [7:0]Addr,
                input RW,
                input Valid, //is this like a chip select/enable?
                input RESET,
                input CLK);
    parameter WIDTH = 8;

    reg [7:0]mem [(2 ** WIDTH) - 1 : 0];
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
                    {mem[Addr+0],mem[Addr+1],mem[Addr+2],mem[Addr+3]} <= Din;
                end
                else    //read
                begin
                    D_OUT <= {mem[Addr+0],mem[Addr+1],mem[Addr+2],mem[Addr+3]};
                end
            end
        end
    end
endmodule

// Code your testbench here
// or browse Examples
module tester();
    wire [31:0] D_OUT;
    reg  [31:0] Din;
    reg  [ 7:0] Addr;
    reg         RW;
    reg         Valid;
    reg         RESET;
    wire        CLK;

    Clock clk(CLK);
    MEMORY mem(D_OUT,Din,Addr,RW,Valid,RESET,CLK);

    initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0,Addr, Din, D_OUT, RW, Valid, CLK,RESET);
        $display("Addr      Din    D_OUT RW Valid CLK");
        $monitor("  %h %h %h  %b     %b   %b %d",Addr, Din, D_OUT, RW, Valid, CLK, $time);
        
        //setup the memory
        RESET = 1;
        Valid = 0;
        Addr  = 0;
        RW    = 1;
        Din   = 32'hACBD4432;

        //clear the reset and write at address 0 the 4 bytes
#5      RESET = 0;
        Valid = 1;

        //read the contents
#10     RW    = 0;

        //disable the chip and move to different address and write a different value to it
#10     Addr  = 4;
        Din   = 32'hDFD6BB42;
        RW    = 1;

        //move to address 4 and read the contents
#10     RW    = 0;
        Addr  = 4;

        //move back to address 0 and read the contents
#20     RW    = 0;
        Addr  = 0;

      
		//reset the memory
#10     RESET = 1;
        Valid = 0;
        Addr  = 0;
        RW    = 0;
        Din   = 32'hACBD4432;

        //clear the reset and read address 0
#5      RESET = 0;
#5      Valid = 1;
      
        //read address 4
#10     Addr = 4;
      
      
		//write to address 0
#10		Addr = 0;
      	RW = 1;
      
        //read the contents
#10     RW    = 0;

        //disable the chip and move to different address and write a different value to it
#10     Addr  = 4;
        Din   = 32'hDFD6BB42;
        RW    = 1;

        //move to address 4 and read the contents
#10     RW    = 0;
        Addr  = 4;

        //move back to address 0 and read the contents
#20     RW    = 0;
        Addr  = 0;

#10     $finish();
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