
module Adder(a_i, b_i, o_o, carry_o);

input [31:0] a_i, b_i;
output [31:0] o_o;
output carry_o;

assign {carry_o, o_o} = a_i + b_i;

endmodule
