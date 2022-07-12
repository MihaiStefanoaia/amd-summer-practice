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