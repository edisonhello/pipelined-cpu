
module MUX32_8(a_i, ctrl_i, o_o);

input [7:0] a_i;
input ctrl_i;
output [7:0] o_o;

reg [7:0] r_o_o;

always @ (a_i or ctrl_i) begin
	if (ctrl_i == 1'b0) r_o_o = a_i;
	else r_o_o = 8'b00000000;
end

assign o_o = r_o_o;

endmodule
