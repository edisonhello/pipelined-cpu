
module Control(op_i, branch_o, memread_o, memwrite_o, memtoreg_o, alusrc_o, aluop_o, regwrite_o);

input [6:0] op_i;
output branch_o, memread_o, memwrite_o, memtoreg_o, alusrc_o, regwrite_o;
output [1:0] aluop_o;

reg r_branch_o, r_memread_o, r_memwrite_o, r_memtoreg_o, r_alusrc_o, r_regwrite_o;
reg [1:0] r_aluop_o;

always @ (op_i) begin
	if (op_i[6:0] == 7'b0110011) begin // r type
		r_branch_o   = 0;
		r_memread_o  = 0;
		r_memwrite_o = 0;
		r_memtoreg_o = 0;
		r_alusrc_o   = 0;
		r_aluop_o    = 2'b10;
		r_regwrite_o = 1;
	end else if (op_i[6:0] == 7'b0000011) begin // load
		r_branch_o   = 0;
		r_memread_o  = 1;
		r_memwrite_o = 0;
		r_memtoreg_o = 1;
		r_alusrc_o   = 1;
		r_aluop_o    = 2'b00;
		r_regwrite_o = 1;
	end else if (op_i[6:0] == 7'b0100011) begin // store
		r_branch_o   = 0;
		r_memread_o  = 0;
		r_memwrite_o = 1;
		// r_memtoreg_o = x; 
		r_alusrc_o   = 1;
		r_aluop_o    = 2'b00;
		r_regwrite_o = 0;
	end else if (op_i[6:0] == 7'b1100011) begin // beq
		r_branch_o   = 1;
		r_memread_o  = 0;
		r_memwrite_o = 0;
		// r_memtoreg_o = x; 
		r_alusrc_o   = 0;
		r_aluop_o    = 2'b01;
		r_regwrite_o = 0;
	end else if (op_i[6:0] == 7'b0010011) begin // addi
        r_branch_o   = 0;
        r_memread_o  = 0;
        r_memwrite_o = 0;
        r_memtoreg_o = 0;
        r_alusrc_o   = 1;
        r_aluop_o    = 2'b11;
        r_regwrite_o = 1;
    end
end

assign branch_o   = r_branch_o;
assign memread_o  = r_memread_o;
assign memwrite_o = r_memwrite_o;
assign memtoreg_o = r_memtoreg_o;
assign alusrc_o   = r_alusrc_o;
assign aluop_o    = r_aluop_o;
assign regwrite_o = r_regwrite_o;

endmodule
