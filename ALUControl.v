`define OR  3'b001
`define AND 3'b000
`define ADD 3'b010
`define SUB 3'b110
`define MUL 3'b100

module ALUControl(aluop_i, inst_i, aluctrl_o);

input [1:0] aluop_i;
input [4:0] inst_i;
output [2:0] aluctrl_o;

reg [2:0] r_aluctrl_o;

always @ (aluop_i, inst_i) begin
    if (aluop_i[1:0] == 2'b00) begin // load, store
        r_aluctrl_o = `ADD;
    end else if (aluop_i[1:0] == 2'b01) begin // beq
        r_aluctrl_o = `SUB;
    end else if (aluop_i[1:0] == 2'b10) begin // r type
        if (inst_i[4:0] == 5'b00000) begin // add
            r_aluctrl_o = `ADD;
        end else if (inst_i[4:0] == 5'b10000) begin // sub
            r_aluctrl_o = `SUB;
        end else if (inst_i[4:0] == 5'b01000) begin // mul
            r_aluctrl_o = `MUL;
        end else if (inst_i[4:0] == 5'b00111) begin // and
            r_aluctrl_o = `AND;
        end else if (inst_i[4:0] == 5'b00110) begin // or
            r_aluctrl_o = `OR;
        end
    end else if (aluop_i[1:0] == 2'b11) begin // addi
        r_aluctrl_o = `ADD;
    end
end

assign aluctrl_o = r_aluctrl_o;

endmodule
