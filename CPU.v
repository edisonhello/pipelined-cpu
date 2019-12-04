module CPU (clk_i, start_i);

// Ports
input clk_i;
input start_i;

wire [31:0] now_pc, next_pc, pc_select_0, pc_select_1, pc_adder_b;
wire [31:0] instruction, imm;
wire [31:0] reg_data_1, reg_data_2, alu_b, alu_result, reg_write_data, memory_data;

wire is_branch, memread_selector, memtoreg_selector, memwrite_selector, alusrc_selector, regwrite_selector, next_pc_selector;
wire [1:0] alu_op;
wire [2:0] alu_ctrl;

PC PC(
    .clk_i          (clk_i),
    .start_i        (start_i),
    .PCWrite_i      (1'b1),
    .pc_i           (next_pc),
    .pc_o           (now_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i         (now_pc),
    .instr_o        (instruction)
);

Registers Registers(
    .clk_i          (clk_i),
    .RS1addr_i      (instruction[19:15]),
    .RS2addr_i      (instruction[24:20]),
    .RDaddr_i       (instruction[11:7]),
    .RDdata_i       (reg_write_data),
    .RegWrite_i     (regwrite_selector),
    .RS1data_o      (reg_data_1),
    .RS2data_o      (reg_data_2)
);

Data_Memory Data_Memory(
    .clk_i          (clk_i),
    .addr_i         (alu_result),
    .MemWrite_i     (memwrite_selector),
    .data_i         (reg_data_2),
    .data_o         (memory_data)
);

Adder PC4Adder(
    .a_i            (now_pc),
    .b_i            (32'b100),
    .o_o            (pc_select_0),
    .carry_o        ()
);

ImmGen ImmGen(
    .inst_i         (instruction),
    .o_o            (imm)
);

ShiftLeft1 ShiftLeft1(
    .i_i            (imm),
    .o_o            (pc_adder_b)
);

Adder NextPCAdder(
    .a_i            (now_pc),
    .b_i            (pc_adder_b),
    .o_o            (pc_select_1),
    .carry_o        ()
);

MUX32 PCSrcMUX(
    .a_i            (pc_select_0),
    .b_i            (pc_select_1),
    .ctrl_i         (next_pc_selector),
    .o_o            (next_pc)
);

MUX32 ALUSrcMUX(
    .a_i            (reg_data_2),
    .b_i            (imm),
    .ctrl_i         (alusrc_selector),
    .o_o            (alu_b)
);

ALU ALU(
    .a_i            (reg_data_1),
    .b_i            (alu_b),
    .ctrl_i         (alu_ctrl),
    .zero_o         (alu_zero),
    .res_o          (alu_result)
);

MUX32 MemToRegMUX(
    .a_i            (alu_result),
    .b_i            (memory_data),
    .ctrl_i         (memtoreg_selector),
    .o_o            (reg_write_data)
);

Control Control(
    .op_i           (instruction[6:0]),
    .branch_o       (is_branch),
    .memread_o      (memread_selector),
    .memwrite_o     (memwrite_selector),
    .memtoreg_o     (memtoreg_selector),
    .alusrc_o       (alusrc_selector),
    .aluop_o        (alu_op),
    .regwrite_o     (regwrite_selector)
);

ALUControl ALUControl(
    .aluop_i        (alu_op),
    .inst_i         ({instruction[30], instruction[25], instruction[14:12]}),
    .aluctrl_o      (alu_ctrl)
);

endmodule

