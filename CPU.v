module CPU (clk_i, start_i);

// Ports
input clk_i;
input start_i;

wire [31:0] next_pc, now_pc_IF, instruction_IF, pc_select_0, pc_select_1_MEM,
			instruction_ID, now_pc_ID, imm_ID, reg_data_1_ID, reg_data_2_ID,
			now_pc_EX, pc_adder_b, pc_select_1_EX, reg_data_1_EX, reg_data_2_EX, alu_b, alu_result_EX, imm_EX,
			alu_result_MEM, reg_data_2_MEM, memory_data_MEM, 
			memory_data_WB, alu_result_WB, reg_write_data_WB;
wire [4:0] reg_write_addr_EX, reg_write_addr_MEM, reg_write_addr_WB,
		   alu_ctrl_input_EX;

wire [7:0] control_ID;
wire [4:0] control_EX;
wire [2:0] alu_ctrl;
wire [1:0] control_MEM, alu_op;
wire alusrc_selector, memwrite_selector, memread_selector, is_branch, memtoreg_selector, regwrite_selector, next_pc_selector,
	 alu_zero_EX, alu_zero_MEM;

PC PC(
    .clk_i          (clk_i),
    .start_i        (start_i),
    .PCWrite_i      (1'b1),
    .pc_i           (next_pc),
    .pc_o           (now_pc_IF)
);

Instruction_Memory Instruction_Memory(
    .addr_i         (now_pc_IF),
    .instr_o        (instruction_IF)
);

Registers Registers(
    .clk_i          (clk_i),
    .RS1addr_i      (instruction_ID[19:15]),
    .RS2addr_i      (instruction_ID[24:20]),
	.RDaddr_i		(reg_write_addr_WB),
    .RDdata_i       (reg_write_data_WB),
    .RegWrite_i     (regwrite_selector),
    .RS1data_o      (reg_data_1_ID),
    .RS2data_o      (reg_data_2_ID)
);

Data_Memory Data_Memory(
    .clk_i          (clk_i),
    .addr_i         (alu_result_MEM),
    .MemWrite_i     (memwrite_selector),
    .data_i         (reg_data_2_MEM),
    .data_o         (memory_data_MEM)
);

Adder PC4Adder(
    .a_i            (now_pc_IF),
    .b_i            (32'b100),
    .o_o            (pc_select_0),
    .carry_o        ()
);

ImmGen ImmGen(
    .inst_i         (instruction_ID),
    .o_o            (imm_ID)
);

ShiftLeft1 ShiftLeft1(
    .i_i            (imm_EX),
    .o_o            (pc_adder_b)
);

Adder NextPCAdder(
    .a_i            (now_pc_EX),
    .b_i            (pc_adder_b),
    .o_o            (pc_select_1_EX),
    .carry_o        ()
);

MUX32 PCSrcMUX(
    .a_i            (pc_select_0),
    .b_i            (pc_select_1_MEM),
    .ctrl_i         (next_pc_selector),
    .o_o            (next_pc)
);

MUX32 ALUSrcMUX(
    .a_i            (reg_data_2_EX),
    .b_i            (imm_EX),
    .ctrl_i         (alusrc_selector),
    .o_o            (alu_b)
);

ALU ALU(
    .a_i            (reg_data_1_EX),
    .b_i            (alu_b),
    .ctrl_i         (alu_ctrl),
    .zero_o         (alu_zero_EX),
    .res_o          (alu_result_EX)
);

MUX32 MemToRegMUX(
    .a_i            (alu_result_WB),
    .b_i            (memory_data_WB),
    .ctrl_i         (memtoreg_selector),
    .o_o            (reg_write_data_WB)
);

Control Control(
    .op_i           (instruction_ID[6:0]),
    .branch_o       (control_ID[2]),
    .memread_o      (control_ID[3]),
    .memwrite_o     (control_ID[4]),
    .memtoreg_o     (control_ID[1]),
    .alusrc_o       (control_ID[7]),
    .aluop_o        (control_ID[6:5]),
    .regwrite_o     (control_ID[0])
);

ALUControl ALUControl(
    .aluop_i        (alu_op),
    // .inst_i         ({instruction[30], instruction[25], instruction[14:12]}),
	.inst_i			(alu_ctrl_input_EX),
    .aluctrl_o      (alu_ctrl)
);

AND BranchAND(
	.a_i			(is_branch),
	.b_i			(alu_zero_MEM),
	.o_o			(next_pc_selector)
);

IFIDReg IFIDReg(
	.clk_i			(clk_i),
	.nowpc_i		(now_pc_IF), 
	.instruction_i	(instruction_IF),
	.nowpc_o		(now_pc_ID),
	.instruction_o  (instruction_ID)
);

IDEXReg IDEXReg(
	.clk_i				(clk_i),
	.nowpc_i			(now_pc_ID),
	.reg_data_1_i		(reg_data_1_ID),
	.reg_data_2_i		(reg_data_2_ID),
	.imm_i				(imm_ID),
	.alu_ctrl_instr_i	({ instruction_ID[30], instruction_ID[25], instruction_ID[14:12] }),
	.reg_write_addr_i	(instruction_ID[11:7]),
	.control_i			(control_ID),
	.nowpc_o			(now_pc_EX),
	.reg_data_1_o		(reg_data_1_EX),
	.reg_data_2_o		(reg_data_2_EX),
	.imm_o				(imm_EX),
	.alu_ctrl_instr_o	(alu_ctrl_input_EX),
	.reg_write_addr_o	(reg_write_addr_EX),
	.control_o			({ alusrc_selector, alu_op ,control_EX })
);

EXMEMReg EXMEMReg(
	.clk_i				(clk_i),
	.pc_select_1_i		(pc_select_1_EX),
	.alu_zero_i			(alu_zero_EX),
	.alu_result_i		(alu_result_EX),
	.reg_data_2_i		(reg_data_2_EX),
	.reg_write_addr_i	(reg_write_addr_EX),
	.control_i			(control_EX),
	.pc_select_1_o		(pc_select_1_MEM),
	.alu_zero_o			(alu_zero_MEM),
	.alu_result_o		(alu_result_MEM),
	.reg_data_2_o		(reg_data_2_MEM),
	.reg_write_addr_o	(reg_write_addr_MEM),
	.control_o			({ memwrite_selector, memread_selector, is_branch, control_MEM })
);

MEMWBReg MEMWBReg(
	.clk_i				(clk_i),
	.mem_read_data_i	(memory_data_MEM),
	.alu_result_i		(alu_result_MEM),
	.reg_write_addr_i	(reg_write_addr_MEM),
	.control_i			(control_MEM),
	.mem_read_data_o	(memory_data_WB),
	.alu_result_o		(alu_result_WB),
	.reg_write_addr_o	(reg_write_addr_WB),
	.control_o			({ memtoreg_selector, regwrite_selector })
);

endmodule

