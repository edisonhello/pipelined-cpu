
module Forward(rs1_i, rs2_i, ex_mem_rrd_i, mem_wb_rrd_i, ex_mem_wb_i, mem_wb_wb_i, forwardA_o, forwardB_o);

input [4:0] rs1_i, rs2_i;
input [4:0] ex_mem_rrd_i, mem_wb_rrd_i;
input       ex_mem_wb_i , mem_wb_wb_i;
output [1:0] forwardA_o, forwardB_o;

assign forwardA_o = (ex_mem_wb_i == 1 && ex_mem_rrd_i != 5'b00000 && ex_mem_rrd_i == rs1_i) ? 2'b10
                    : (mem_wb_wb_i==1 && mem_wb_rrd_i != 5'b00000 && mem_wb_rrd_i == rs1_i) ? 2'b01
                    : 2'00;

assign forwardB_o = (ex_mem_wb_i == 1 && ex_mem_rrd_i != 5'b00000 && ex_mem_rrd_i == rs2_i) ? 2'b10
                    : (mem_wb_wb_i==1 && mem_wb_rrd_i != 5'b00000 && mem_wb_rrd_i == rs2_i) ? 2'b01
                    : 2'00;


endmodule
