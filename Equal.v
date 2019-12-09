
module Equal(a_i, b_i, o_o);

input [31:0] a_i, b_i;
output o_o;

assign o_o = (a_i ==  b_i);

endmodule
