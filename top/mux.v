module MUX2x1(  input [WIDTH-1:0] IN_A, //SEL = 0
                input [WIDTH-1:0] IN_B, //SEL = 1
                input SEL,
                output [WIDTH-1:0]OUT);
    parameter WIDTH = 8;
    assign OUT = (IN_A & {WIDTH{~SEL}}) | (IN_B & {WIDTH{SEL}});
endmodule