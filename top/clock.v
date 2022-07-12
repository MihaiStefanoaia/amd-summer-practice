module Clock(output c);
    reg value;
    assign c = value;

    initial
        value = 0;

    always
    #5 value = ~value;
endmodule