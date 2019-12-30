
module Hazard(rs1_i, rs2_i, rrd_i, mem_rd_i, mux_o, IFID_write_o, pc_write_o, exi_rs2_i);

input [4:0] rs1_i, rs2_i, rrd_i;
input       mem_rd_i, exi_rs2_i;
output      mux_o;
output      pc_write_o, IFID_write_o;

wire hazard_occur;

assign hazard_occur = ( (mem_rd_i == 1'b1)   &&   (rs1_i == rrd_i || (rs2_i == rrd_i && exi_rs2_i == 1'b1)) && rrd_i != 5'b0);

assign mux_o = hazard_occur;

assign IFID_write_o = hazard_occur == 1'b1 ? 1'b0 : 1'b1;

assign pc_write_o =   hazard_occur == 1'b1 ? 1'b0 : 1'b1;

endmodule
