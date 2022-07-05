module M_ALU(   output reg[7:0] ALU_OUT_TMP,
                output reg[3:0] FLAG_TMP,
                input     [7:0] A, 
                input     [7:0] B,
                input     [3:0] SEL_TMP);

    reg eq0_eval;
    reg overflow_eval;
    
    always @(A or B or SEL_TMP)
    begin
        case(SEL_TMP)
            4'h0:begin //addition
                ALU_OUT_TMP <= A + B;
                FLAG_TMP <= 4'h0 | (((A + B) % 256 == 0) ? 4'h1 : 4'h0) | ((A + B > 255) ? 4'h2 : 4'h0);
            end
            4'h1:begin//subtraction
                ALU_OUT_TMP <= A - B;
                FLAG_TMP <= 4'h0 | (((A - B) % 256 == 0) ? 4'h1 : 4'h0) | ((A < B) ? 4'h8 : 4'h0);
            end
            4'h2:begin//multiplication
                ALU_OUT_TMP <= A * B;
                FLAG_TMP <= 4'h0 | (((A * B) % 256 == 0) ? 4'h1 : 4'h0) | ((A > 8'hF || B > 8'hF) ? 4'h4 : 4'h0); //not sure abut the overflow tag
            end
            4'h3:begin//division
                if(B != 0)
                begin
                    ALU_OUT_TMP <= A / B;
                    FLAG_TMP <= 4'h0 | ((A / B == 0) ? 4'h1 : 4'h0) | ((A < B) ? 4'h8 : 4'h0);
                end
                else    //not sure if ok
                begin
                    ALU_OUT_TMP <= 0;
                    FLAG_TMP <= 4'h1;
                end
            end
            4'h4:begin//left shift
                ALU_OUT_TMP <= A << B;
                FLAG_TMP <= 4'h0 | (((A << B) % 256 == 0) ? 4'h1 : 4'h0) | ((B <= 8 && A[ 7 - (B-1)%8] == 1) ? 4'h2 : 4'h0);
            end
            4'h5:begin//right shift
                ALU_OUT_TMP <= A >> B;
                FLAG_TMP <= 4'h0 | (((A >> B) % 256 == 0) ? 4'h1 : 4'h0) | ((B <= 8 && A[ (B-1)%8 ] == 1) ? 4'h2 : 4'h0);
            end
            4'h6:begin//AND
                ALU_OUT_TMP <= A & B;
                FLAG_TMP <= 4'h0 | (((A & B) == 0) ? 4'h1 : 4'h0);
            end
            4'h7:begin//OR
                ALU_OUT_TMP <= A | B;
                FLAG_TMP <= 4'h0 | (((A | B) == 0) ? 4'h1 : 4'h0);
            end
            4'h8:begin//XOR
                ALU_OUT_TMP <= A ^ B;
                FLAG_TMP <= 4'h0 | (((A ^ B) == 0) ? 4'h1 : 4'h0);
            end
            4'h9:begin//NXOR
                ALU_OUT_TMP <= (~(A ^ B));
                FLAG_TMP <= 4'h0 | (((~(A ^ B)) == 8'h00) ? 4'h1 : 4'h0);
            end
            4'hA:begin//NAND
                ALU_OUT_TMP <= ~(A & B);
                FLAG_TMP <= 4'h0 | (((~(A & B)) == 8'h00) ? 4'h1 : 4'h0);
            end
            4'hB:begin//NOR
                ALU_OUT_TMP <= ~(A | B);
                FLAG_TMP <= 4'h0 | (((~(A | B)) == 8'h00) ? 4'h1 : 4'h0);
            end
            default:begin
                ALU_OUT_TMP <= 8'h00;
                FLAG_TMP <= 4'h0;
            end
            endcase
    end
endmodule

module alu_arith_tester();
    wire [7:0] ALU_OUT_TMP;
    wire [3:0] FLAG_TMP;
    reg  [7:0] A;
    reg  [7:0] B;
    reg  [3:0] SEL_TMP;
    M_ALU alu(ALU_OUT_TMP,FLAG_TMP,A,B,SEL_TMP);

    initial
    begin
        $display("SEL   A   B OUT FLAGS");
        $monitor("  %h %d %d %d  %b",SEL_TMP,A,B,ALU_OUT_TMP,FLAG_TMP);
        //addition testing
        SEL_TMP = 0;
        begin
            //regular addition
            A = 1;
            B = 1;

            //addition that equals to 0
#5          A = 0;
            B = 0;

            //addition that overflows
#5          A = 200;
            B = 100;

            //addition that overflows and equals to 0
#5          A = 200;
            B = 56;
        end

        //subtraction testing
#5      SEL_TMP = 1;
        begin
            //regular subtraction
            A = 5;
            B = 2;

            //subtraction that equals to 0
#5          A = 10;
            B = 10;

            //underflow subtraction
#5          A = 9;
            B = 10;

            //there is no underflow subtraction that equals to 0
            //--
        end

        //multiplication testing
#5      SEL_TMP = 2;
        begin
            //regular multiplication
            A = 10;
            B = 7;

            //multiplication that equals to 0
#5          A = 0;
            B = 0;

            //multiplication that overflows due to A
#5          A = 16;
            B = 4;
                        
            //multiplication that overflows due to B
#5          A = 4;
            B = 16;

            //multiplication that overflows and equals to 0
#5          A = 16;
            B = 16;
        end

        //division testing
#5      SEL_TMP = 3;
        begin
            //regular division
            A = 135;
            B = 5;

            //division by 0
#5          A = 11;
            B = 0;

            //underflow division
#5          A = 12;
            B = 33;

            //division of 0 - also underflows
#5          A = 0;
            B = 11;
        end

        //left shift testing
#5      SEL_TMP = 4;
        begin
            //regular left shift
            A = 12;
            B = 2;

            //shift where carry = 1
#5          A = 129;
            B = 1;

            //shift eq 0
#5          A = 128;
            B = 2;

            //shift by 0
#5          A = 12;
            B = 0;

            //shifting of 0
#5          A = 0;
            B = 11;
        end

        //right shift testing
#5      SEL_TMP = 5;
        begin
            //regular right shift
            A = 12;
            B = 2;

            //shift where carry = 1
#5          A = 24;
            B = 4;

            //shift eq 0
#5          A = 8;
            B = 5;

            //shift by 0
#5          A = 12;
            B = 0;

            //shifting of 0
#5          A = 0;
            B = 11;
        end

    end
endmodule


module alu_bin_tester();
    wire [7:0] ALU_OUT_TMP;
    wire [3:0] FLAG_TMP;
    reg  [7:0] A;
    reg  [7:0] B;
    reg  [3:0] SEL_TMP;
    M_ALU alu(ALU_OUT_TMP,FLAG_TMP,A,B,SEL_TMP);

    initial
    begin
#130    $display("SEL        A        B      OUT FLAGS");
        $monitor("  %h %b %b %b  %b",SEL_TMP,A,B,ALU_OUT_TMP,FLAG_TMP);

        //AND testing
#5      SEL_TMP = 4'h6;
        begin
            //regular
            A = 8'b11000001;
            B = 8'b00111001;

            //eq 0
#5          A = 8'b11000011;
            B = 8'b00111100;
        end

        //OR testing
#5      SEL_TMP = 4'h7;
        begin
            //regular
            A = 8'b11000001;
            B = 8'b00111001;

            //eq 0
#5          A = 8'b00000000;
            B = 8'b00000000;
        end

        //XOR testing
#5      SEL_TMP = 4'h8;
        begin
            //regular
            A = 8'b11000001;
            B = 8'b00111001;

            //eq 0
#5          A = 8'b10011000;
            B = 8'b10011000;
        end

        //NXOR testing
#5      SEL_TMP = 4'h9;
        begin
            //regular
            A = 8'b11000001;
            B = 8'b00111001;

            //eq 0
#5          A = 8'b00001111;
            B = 8'b11110000;
        end

        //NAND testing
#5      SEL_TMP = 4'hA;
        begin
            //regular
            A = 8'b11000001;
            B = 8'b00111001;

            //eq 0
#5          A = 8'b11111111;
            B = 8'b11111111;
        end

        //NOR testing
#5      SEL_TMP = 4'hB;
        begin
            //regular
            A = 8'b11000001;
            B = 8'b00111001;

            //eq 0
#5          A = 8'b00001111;
            B = 8'b11110000;
        end
    end

endmodule