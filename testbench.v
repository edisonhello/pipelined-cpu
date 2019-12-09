`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
integer            i, outfile, counter;
integer            stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .start_i(Start)
);
  
initial begin
	$dumpfile("a.vcd");
	$dumpvars;

    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 8'b0;
    end    
        
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end

	CPU.PC.pc_o = 0;

    // TODO: initialize pipeline registers
	CPU.IFIDReg.nowpc = 32'b0;
	CPU.IFIDReg.instruction = 32'b0;

	CPU.IDEXReg.r1 = 32'b0;
	CPU.IDEXReg.r2 = 32'b0;
	CPU.IDEXReg.r3 = 32'b0;
	CPU.IDEXReg.r4 = 32'b0;
	CPU.IDEXReg.r5 = 5'b0;
	CPU.IDEXReg.r6 = 5'b0;
	CPU.IDEXReg.r7 = 8'b0;
	CPU.IDEXReg.r8 = 5'b0;
	CPU.IDEXReg.r9 = 5'b0;

	CPU.EXMEMReg.r1 = 32'b0;
	CPU.EXMEMReg.r2 = 32'b0;
	CPU.EXMEMReg.r3 = 5'b0;
	CPU.EXMEMReg.r4 = 5'b0;
	CPU.EXMEMReg.r5 = 1'b0;
    
	CPU.MEMWBReg.r1 = 32'b0;
	CPU.MEMWBReg.r2 = 32'b0;
	CPU.MEMWBReg.r3 = 5'b0;
	CPU.MEMWBReg.r4 = 2'b0;

    // Load instructions into instruction memory
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("output.txt") | 1;
    
    // Set Input n into data memory at 0x00
    CPU.Data_Memory.memory[0] = 8'h5;       // n = 5 for example
    
    Clk = 1;
    // Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    // Reset = 1;
    Start = 1;
        
    
end
  
always@(posedge Clk) begin
    // TODO: change # of cycles as you need
    if(counter == 30)    // stop after 15 cycles
        $finish;

    // TODO: put in your own signal to count stall and flush
    // if(CPU.HazardDetection.Stall_o == 1 && CPU.Control.Branch_o == 0)stall = stall + 1;
    // if(CPU.HazardDetection.Flush_o == 1)flush = flush + 1;  
   

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %d, Stall = %d, Flush = %d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
    
    // print Registers
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0 = %d, x8  = %d, x16 = %d, x24 = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "x1 = %d, x9  = %d, x17 = %d, x25 = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "x2 = %d, x10 = %d, x18 = %d, x26 = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "x3 = %d, x11 = %d, x19 = %d, x27 = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "x4 = %d, x12 = %d, x20 = %d, x28 = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "x5 = %d, x13 = %d, x21 = %d, x29 = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "x6 = %d, x14 = %d, x22 = %d, x30 = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "x7 = %d, x15 = %d, x23 = %d, x31 = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);
    $fdisplay(outfile, "IFIDReg : nowpc = %d, instruction = %d", CPU.IFIDReg.nowpc, CPU.IFIDReg.instruction);
    $fdisplay(outfile, "IDEXReg : r1 = %d, r2 = %d, r3 = %d, r4 = %d, r5 = %d, r6 = %d, r7 = %d", CPU.IDEXReg.r1, CPU.IDEXReg.r2, CPU.IDEXReg.r3, CPU.IDEXReg.r4, CPU.IDEXReg.r5, CPU.IDEXReg.r6, CPU.IDEXReg.r7);
    $fdisplay(outfile, "EXMEMReg: r1 = %d, r2 = %d, r3 = %d, r4 = %d, r5 = %d", CPU.EXMEMReg.r1, CPU.EXMEMReg.r2, CPU.EXMEMReg.r3, CPU.EXMEMReg.r4, CPU.EXMEMReg.r5);
    $fdisplay(outfile, "MEMWBReg: r1 = %d, r2 = %d, r3 = %d, r4 = %d", CPU.MEMWBReg.r1, CPU.MEMWBReg.r2, CPU.MEMWBReg.r3, CPU.MEMWBReg.r4);
    $fdisplay(outfile, "ALU: a_i = %d, b_i = %d", CPU.ALU.a_i, CPU.ALU.b_i);
    $fdisplay(outfile, "AND: a_i = %d, b_i = %d", CPU.BranchAND.a_i, CPU.BranchAND.b_i);
    $fdisplay(outfile, "Hazard: mem_rd_i = %d, rs1_i = %d, rs2_i = %d, rrd_i = %d, hazard_occur = %d", CPU.Hazard.mem_rd_i, CPU.Hazard.rs1_i, CPU.Hazard.rs2_i, CPU.Hazard.rrd_i, CPU.Hazard.hazard_occur);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %10d", {CPU.Data_Memory.memory[3] , CPU.Data_Memory.memory[2] , CPU.Data_Memory.memory[1] , CPU.Data_Memory.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %10d", {CPU.Data_Memory.memory[7] , CPU.Data_Memory.memory[6] , CPU.Data_Memory.memory[5] , CPU.Data_Memory.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %10d", {CPU.Data_Memory.memory[11], CPU.Data_Memory.memory[10], CPU.Data_Memory.memory[9] , CPU.Data_Memory.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %10d", {CPU.Data_Memory.memory[15], CPU.Data_Memory.memory[14], CPU.Data_Memory.memory[13], CPU.Data_Memory.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %10d", {CPU.Data_Memory.memory[19], CPU.Data_Memory.memory[18], CPU.Data_Memory.memory[17], CPU.Data_Memory.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %10d", {CPU.Data_Memory.memory[23], CPU.Data_Memory.memory[22], CPU.Data_Memory.memory[21], CPU.Data_Memory.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %10d", {CPU.Data_Memory.memory[27], CPU.Data_Memory.memory[26], CPU.Data_Memory.memory[25], CPU.Data_Memory.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %10d", {CPU.Data_Memory.memory[31], CPU.Data_Memory.memory[30], CPU.Data_Memory.memory[29], CPU.Data_Memory.memory[28]});
	
    $fdisplay(outfile, "\n");
    
    counter = counter + 1;
    
      
end

  
endmodule
