
module MUX32_3(a_i, b_i, c_i, ctrl_i, o_o);

input [31:0] a_i, b_i, c_i;
input [1:0]  ctrl_i;
output [31:0] o_o;

reg [31:0] r_o_o;

always @ (a_i or b_i or ctrl_i or c_i) begin
	if (ctrl_i == 2'b00)        r_o_o = a_i;
    else if(ctrl_i == 2'b10)    r_o_o = c_i;
	else r_o_o = b_i;
end

assign o_o = r_o_o;

endmodule
