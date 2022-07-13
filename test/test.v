module test();
    wire clk;
    wire clk_w;
    reg valid;
    Clock CLK(clk,valid);
    Clock_W CLK_W(clk_w,valid);
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,clk,clk_w,valid);

        valid = 0;

#10     valid = 1;

#10     valid = 0;

#20     valid = 1;

#20     $finish();
    end

endmodule

module Clock(output c,input valid);
    reg value;
    assign c = value;

    initial
        value = 0;

    always
    #5 value = ~value & valid;
endmodule


module Clock_W(output c,input valid);
    reg value;
    assign c = value;

    initial
        value = 0;

    always
    value = #5 ~value & valid;
endmodule