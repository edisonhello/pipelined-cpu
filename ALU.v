`define OR  3'b001
`define AND 3'b000
`define ADD 3'b010
`define SUB 3'b110
`define MUL 3'b100

module ALU (a_i, b_i, ctrl_i, zero_o, res_o);

input [31:0] a_i, b_i;
input [2:0] ctrl_i;
output zero_o;
output [31:0] res_o;

reg [31:0] r_res_o;
reg r_zero_o;

always @ (a_i or b_i or ctrl_i) begin
	case (ctrl_i)
        `OR:  r_res_o = a_i | b_i;
        `AND: r_res_o = a_i & b_i;
        `ADD: r_res_o = a_i + b_i;
        `SUB: r_res_o = a_i - b_i;
        `MUL: r_res_o = a_i * b_i;
	endcase
	if (r_res_o == 0)
		r_zero_o = 1;
	else 
		r_zero_o = 0;
end

assign zero_o = r_zero_o;
assign res_o = r_res_o;

endmodule
