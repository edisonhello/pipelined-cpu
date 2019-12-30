
module IFIDReg(clk_i, nowpc_i, instruction_i, stall_i, nowpc_o, instruction_o, IFID_write_i, flush_i);

input clk_i, stall_i, IFID_write_i, flush_i;  //lawfung
input [31:0] nowpc_i, instruction_i;
output [31:0] nowpc_o, instruction_o;

reg [31:0] nowpc, instruction;

//lawfung
always @ (posedge clk_i) begin
	if (stall_i) begin end
    else if (flush_i == 1'b1) begin
        nowpc <= 32'b0;
        instruction <= 32'b0;
    end else if (IFID_write_i == 1'b1) begin
        nowpc <= nowpc_i;
        instruction <= instruction_i;
    end
end

assign nowpc_o = nowpc;
assign instruction_o = instruction;

endmodule

module IDEXReg(clk_i, nowpc_i, reg_data_1_i, reg_data_2_i, imm_i, alu_ctrl_instr_i, reg_write_addr_i, control_i, stall_i,
                      nowpc_o, reg_data_1_o, reg_data_2_o, imm_o, alu_ctrl_instr_o, reg_write_addr_o, control_o,
                      rs1_i, rs2_i, rs1_o, rs2_o);      //lawfung

input clk_i, stall_i;
input [31:0] nowpc_i, reg_data_1_i, reg_data_2_i, imm_i;
input [4:0] alu_ctrl_instr_i, reg_write_addr_i;
input [7:0] control_i;
//lawfung
input [4:0] rs1_i, rs2_i;
output [31:0] nowpc_o, reg_data_1_o, reg_data_2_o, imm_o;
output [4:0] alu_ctrl_instr_o, reg_write_addr_o;
output [7:0] control_o;
//lawfung
output [4:0] rs1_o, rs2_o;

reg [31:0] r1, r2, r3, r4;
reg [4:0] r5, r6;
reg [7:0] r7;
reg [4:0] r8, r9;

always @ (posedge clk_i) begin
	if (stall_i) begin end
	else begin
		r1 <= nowpc_i;
		r2 <= reg_data_1_i;
		r3 <= reg_data_2_i;
		r4 <= imm_i;
		r5 <= alu_ctrl_instr_i;
		r6 <= reg_write_addr_i;
		r7 <= control_i;
		r8 <= rs1_i;
		r9 <= rs2_i;
	end
end

assign nowpc_o = r1;
assign reg_data_1_o = r2;
assign reg_data_2_o = r3;
assign imm_o = r4;
assign alu_ctrl_instr_o = r5;
assign reg_write_addr_o = r6;
assign control_o = r7;
assign rs1_o = r8;
assign rs2_o = r9;

endmodule

module EXMEMReg(clk_i, alu_zero_i, alu_result_i, reg_data_2_i, reg_write_addr_i, control_i, stall_i,
					   alu_zero_o, alu_result_o, reg_data_2_o, reg_write_addr_o, control_o);

input clk_i, stall_i;
input [31:0] alu_result_i, reg_data_2_i;
input [4:0] reg_write_addr_i;
input [4:0] control_i;
input alu_zero_i;

output [31:0] alu_result_o, reg_data_2_o;
output [4:0] reg_write_addr_o;
output [4:0] control_o;
output alu_zero_o;

reg [31:0] r1, r2;
reg [4:0] r3;
reg [4:0] r4;
reg r5;

always @ (posedge clk_i) begin
	if (stall_i) begin end
	else begin
		r1 <= alu_result_i;
		r2 <= reg_data_2_i;
		r3 <= reg_write_addr_i;
		r4 <= control_i;
		r5 <= alu_zero_i;
	end
end

assign alu_result_o = r1;
assign reg_data_2_o = r2;
assign reg_write_addr_o = r3;
assign control_o = r4;
assign alu_zero_o = r5;

endmodule

module MEMWBReg(clk_i, mem_read_data_i, alu_result_i, reg_write_addr_i, control_i, stall_i,
					   mem_read_data_o, alu_result_o, reg_write_addr_o, control_o);

input clk_i, stall_i;
input [31:0] mem_read_data_i, alu_result_i;
input [4:0] reg_write_addr_i;
input [1:0] control_i;

output [31:0] mem_read_data_o, alu_result_o;
output [4:0] reg_write_addr_o;
output [1:0] control_o;

reg [31:0] r1, r2;
reg [4:0] r3;
reg [1:0] r4;

always @ (posedge clk_i) begin
	if (stall_i) begin end
	else begin
		r1 <= mem_read_data_i;
		r2 <= alu_result_i;
		r3 <= reg_write_addr_i;
		r4 <= control_i;
	end
end

assign mem_read_data_o = r1;
assign alu_result_o = r2;
assign reg_write_addr_o = r3;
assign control_o = r4;

endmodule
