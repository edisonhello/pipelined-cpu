module ShiftLeft1 (i_i, o_o);

input [31:0] i_i;
output [31:0] o_o;

assign o_o = { i_i[30:0], 1'b0 };

endmodule
