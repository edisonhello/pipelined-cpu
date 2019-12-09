
module Hazard(rs1_i, rs2_i, rrd_i, mem_rd_i, mux_o, IFID_write_o, pc_write_o);

input [4:0] rs1_i, rs2_i, rrd_i;
input       mem_rd_i;
output      mux_o;
output      pc_write_o, IFID_write_o;

wire hazard_occur ;

assign hazard_occur = ( (mem_rd == 1'b1)   &&   (rs1_i == rrd_i || rd2_i == rrd_i) && rrd_i != 5'b0);

assign mux_o = hazard_occur;

assign IFID_write_o = hazard_occur == 1'b1 ? 1'b0 : 1'b1;

assign pc_write_o =   hazard_occur == 1'b1 ? 1'b0 : 1'b1;

endmodule
