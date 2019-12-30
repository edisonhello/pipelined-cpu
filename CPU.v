module CPU (clk_i, rst_i, start_i, 
			mem_data_i, mem_ack_i, mem_data_o, mem_addr_o, mem_enable_o, mem_write_o);

// Ports
input clk_i, rst_i, start_i;
input [255:0] mem_data_i;
input mem_ack_i;
output [255:0] mem_data_o;
output [31:0] mem_addr_o;
output mem_enable_o, mem_write_o;

wire [31:0] next_pc, now_pc_IF, instruction_IF, pc_select_0,
			instruction_ID, now_pc_ID, imm_ID, reg_data_1_ID, reg_data_2_ID,
			now_pc_EX, pc_adder_b, reg_data_1_EX, reg_data_2_EX, alu_b, alu_result_EX, imm_EX,
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

wire mem_stall;

//lawfung
wire pc_control, IFID_control;
PC PC(
    .clk_i          (clk_i),
	.rst_i			(rst_i),
    .start_i        (start_i),
	.stall_i		(mem_stall),
    .PCWrite_i      (pc_control),   //lawfung
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

dcache_top dcache(
    .clk_i			(clk_i), 
    .rst_i			(rst_i), 
    // to Data Memory interface        
    .mem_data_i		(mem_data_i), 
    .mem_ack_i		(mem_ack_i),     
    .mem_data_o		(mem_data_o), 
    .mem_addr_o		(mem_addr_o),
    .mem_enable_o	(mem_enable_o), 
    .mem_write_o	(mem_write_o), 
    // to CPU interface    
    .p1_data_i		(reg_data_2_MEM), 
    .p1_addr_i		(alu_result_MEM),
    .p1_MemRead_i	(memread_selector), 
    .p1_MemWrite_i	(memwrite_selector), 
    .p1_data_o		(memory_data_MEM), 
    .p1_stall_o		(mem_stall)
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
    .i_i            (imm_ID),   //lawfung
    .o_o            (pc_adder_b)
);
//lawfung
wire [31:0] jmp_pc;
Adder NextPCAdder(
    .a_i            (now_pc_ID),    //lawfung
    .b_i            (pc_adder_b),   
    .o_o            (jmp_pc),
    .carry_o        ()
);

MUX32 PCSrcMUX(
    .a_i            (pc_select_0),
    .b_i            (jmp_pc),           //lawfung
    .ctrl_i         (next_pc_selector),
    .o_o            (next_pc)
);
//lawfung
wire [1:0] forwardA, forwardB;
wire [31:0] ALU_new_sr1, ALU_new_sr2;
//lawfung
MUX32_3 ALUSrc1(
    .a_i            (reg_data_1_EX),
    .b_i            (reg_write_data_WB),
    .c_i            (alu_result_MEM),
    .ctrl_i         (forwardA),
    .o_o            (ALU_new_sr1)
);
//lawfung
MUX32_3 ALUSrc2(
    .a_i            (reg_data_2_EX),
    .b_i            (reg_write_data_WB),
    .c_i            (alu_result_MEM),
    .ctrl_i         (forwardB),
    .o_o            (ALU_new_sr2)
);

MUX32 ALUSrcMUX(
    .a_i            (ALU_new_sr2),  //lawfung
    .b_i            (imm_EX),
    .ctrl_i         (alusrc_selector),
    .o_o            (alu_b)
);

ALU ALU(
    .a_i            (ALU_new_sr1),    //lawfung
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
//lawfung
wire control_mux_control;
Hazard Hazard(
    .rs1_i          (instruction_ID[19:15]),
    .rs2_i          (instruction_ID[24:20]),
    .rrd_i          (reg_write_addr_EX),
    .mem_rd_i       (control_EX[3]),
    .mux_o          (control_mux_control),
    .pc_write_o     (pc_control),
    .IFID_write_o   (IFID_control),
    .exi_rs2_i		(instruction_ID[5])
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
//lawufng
wire [7:0] control_ID_new;
//lawfung
MUX32_8 ControlMUX(
    .a_i            (control_ID),
    .ctrl_i         (control_mux_control),
    .o_o            (control_ID_new)
);

ALUControl ALUControl(
    .aluop_i        (alu_op),
    // .inst_i         ({instruction[30], instruction[25], instruction[14:12]}),
    .inst_i			(alu_ctrl_input_EX),
    .aluctrl_o      (alu_ctrl)
);

//lawfung
Equal BranchEqual(
	.a_i			(reg_data_1_ID),
	.b_i			(reg_data_2_ID),
	.o_o			(alu_zero_MEM_new)
);
//lawfung
AND BranchAND(
	.a_i			(control_ID[2]),
	.b_i			(alu_zero_MEM_new),
	.o_o			(next_pc_selector)
);

IFIDReg IFIDReg(
	.clk_i			(clk_i),
	.nowpc_i		(now_pc_IF), 
	.instruction_i	(instruction_IF),
	.stall_i		(mem_stall),
	.nowpc_o		(now_pc_ID),
	.instruction_o  (instruction_ID),
    //lawfung
    .IFID_write_i   (IFID_control),
    .flush_i        (next_pc_selector)
);

//lawfung
wire [4:0] rs1_ID, rs2_ID;

IDEXReg IDEXReg(
	.clk_i				(clk_i),
	.nowpc_i			(now_pc_ID),
	.reg_data_1_i		(reg_data_1_ID),
	.reg_data_2_i		(reg_data_2_ID),
	.imm_i				(imm_ID),
	.alu_ctrl_instr_i	({ instruction_ID[30], instruction_ID[25], instruction_ID[14:12] }),
	.reg_write_addr_i	(instruction_ID[11:7]),
	.stall_i			(mem_stall),
	.control_i			(control_ID_new),       //lawfung
	.nowpc_o			(now_pc_EX),
	.reg_data_1_o		(reg_data_1_EX),
	.reg_data_2_o		(reg_data_2_EX),
	.imm_o				(imm_EX),
	.alu_ctrl_instr_o	(alu_ctrl_input_EX),
	.reg_write_addr_o	(reg_write_addr_EX),
	.control_o			({ alusrc_selector, alu_op ,control_EX }),
    //lawfung
    .rs1_i              (instruction_ID[19:15]),
    .rs2_i              (instruction_ID[24:20]),
    .rs1_o              (rs1_ID),
    .rs2_o              (rs2_ID)
);

EXMEMReg EXMEMReg(
	.clk_i				(clk_i),
	// .pc_select_1_i		(pc_select_1_EX),
	.alu_zero_i			(alu_zero_EX),
	.alu_result_i		(alu_result_EX),
	.reg_data_2_i		(ALU_new_sr2),    //lawfung
	.reg_write_addr_i	(reg_write_addr_EX),
	.control_i			(control_EX),
	.stall_i			(mem_stall),
	// .pc_select_1_o		(pc_select_1_MEM),
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
	.stall_i			(mem_stall),
	.mem_read_data_o	(memory_data_WB),
	.alu_result_o		(alu_result_WB),
	.reg_write_addr_o	(reg_write_addr_WB),
	.control_o			({ memtoreg_selector, regwrite_selector })
);
//lawfung
Forward Forwarding_unit(
    .rs1_i              (rs1_ID),
    .rs2_i              (rs2_ID),
    .ex_mem_rrd_i       (reg_write_addr_MEM),
    .mem_wb_rrd_i       (reg_write_addr_WB),
    .ex_mem_wb_i        (control_MEM[0]),
    .mem_wb_wb_i        (regwrite_selector),
    .forwardA_o         (forwardA),
    .forwardB_o         (forwardB)
);

endmodule

