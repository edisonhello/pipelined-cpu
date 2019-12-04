module ImmGen (inst_i, o_o);

input [31:0] inst_i;
output [31:0] o_o;

reg [11:0] r_imm;

always @ (inst_i) begin
	case (inst_i[6:5])
		2'b00: r_imm = {inst_i[31:20]}; // lw
		2'b01: r_imm = {inst_i[31:25], inst_i[11:7]}; // sw
		2'b11: r_imm = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]}; // beq
	endcase
end

assign o_o = {{ 20{r_imm[11]}}, r_imm[11:0] };

endmodule
