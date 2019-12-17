`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, outfile, outfile2, counter;
integer            stall, flush;
reg                flag;
reg        [26:0]  address;
reg        [23:0]  tag;
reg        [4:0]   index;


wire    [256-1:0]  mem_cpu_data; 
wire               mem_cpu_ack;     
wire    [256-1:0]  cpu_mem_data; 
wire    [32-1:0]   cpu_mem_addr;     
wire               cpu_mem_enable; 
wire               cpu_mem_write; 

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .rst_i  (Reset),
    .start_i(Start),
    
    .mem_data_i(mem_cpu_data), 
    .mem_ack_i(mem_cpu_ack),     
    .mem_data_o(cpu_mem_data), 
    .mem_addr_o(cpu_mem_addr),     
    .mem_enable_o(cpu_mem_enable), 
    .mem_write_o(cpu_mem_write)
);
  
Data_Memory Data_Memory(
    .clk_i    (Clk),
    .rst_i    (Reset),
    .addr_i   (cpu_mem_addr),
    .data_i   (cpu_mem_data),
    .enable_i (cpu_mem_enable),
    .write_i  (cpu_mem_write),
    .ack_o    (mem_cpu_ack),
    .data_o   (mem_cpu_data)
);

initial begin
	$dumpfile("a.vcd");
	$dumpvars;

    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory (1KB)
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory (16KB)
    for(i=0; i<512; i=i+1) begin
        Data_Memory.memory[i] = 256'b0;
    end    
        
    // initialize cache memory    (1KB)
    for(i=0; i<32; i=i+1) begin
        CPU.dcache.dcache_tag_sram.memory[i] = 24'b0;
        CPU.dcache.dcache_data_sram.memory[i] = 256'b0;
    end

    // initialize Register File 
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end

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
    $readmemb("./instruction.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("./output.txt") | 1;
    outfile2 = $fopen("./cache.txt") | 1;
    
    // Set Input n into data memory at 0x00
    Data_Memory.memory[0] = 256'h5;       // n = 5 for example
    
    Clk = 1;
    Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 1;
    Start = 1;
end
  
always@(posedge Clk) begin
    if(counter == 150) begin    // store cache to memory
        $fdisplay(outfile, "Flush Cache! \n");
        for(i=0; i<32; i=i+1) begin
            tag = CPU.dcache.dcache_tag_sram.memory[i];
            index = i;
            address = {tag[21:0], index};
            Data_Memory.memory[address] = CPU.dcache.dcache_data_sram.memory[i];
        end 
    end
    if(counter > 150) begin    // stop 
        $finish;
    end

    // TODO: put in your own signal to count stall and flush
    if (CPU.Hazard.pc_write_o == 0 && CPU.BranchAND.a_i == 0) stall = stall + 1;
    if (CPU.BranchAND.o_o == 1) flush = flush + 1;
    // if(CPU.HazardDetection.Stall_o == 1 && CPU.Control.Branch_o == 0)stall = stall + 1;
    // if(CPU.HazardDetection.Flush_o == 1)flush = flush + 1;  
   

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %d, Stall = %0d, Flush = %0d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
    
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
    // $fdisplay(outfile, "IFIDReg : nowpc = %d, instruction = %d", CPU.IFIDReg.nowpc, CPU.IFIDReg.instruction);
    // $fdisplay(outfile, "IDEXReg : r1 = %d, r2 = %d, r3 = %d, r4 = %d, r5 = %d, r6 = %d, r7 = %d", CPU.IDEXReg.r1, CPU.IDEXReg.r2, CPU.IDEXReg.r3, CPU.IDEXReg.r4, CPU.IDEXReg.r5, CPU.IDEXReg.r6, CPU.IDEXReg.r7);
    // $fdisplay(outfile, "EXMEMReg: r1 = %d, r2 = %d, r3 = %d, r4 = %d, r5 = %d", CPU.EXMEMReg.r1, CPU.EXMEMReg.r2, CPU.EXMEMReg.r3, CPU.EXMEMReg.r4, CPU.EXMEMReg.r5);
    // $fdisplay(outfile, "MEMWBReg: r1 = %d, r2 = %d, r3 = %d, r4 = %d", CPU.MEMWBReg.r1, CPU.MEMWBReg.r2, CPU.MEMWBReg.r3, CPU.MEMWBReg.r4);
    // $fdisplay(outfile, "ALU: a_i = %d, b_i = %d", CPU.ALU.a_i, CPU.ALU.b_i);
    // $fdisplay(outfile, "AND: a_i = %d, b_i = %d", CPU.BranchAND.a_i, CPU.BranchAND.b_i);
    // $fdisplay(outfile, "Hazard: mem_rd_i = %d, rs1_i = %d, rs2_i = %d, rrd_i = %d, hazard_occur = %d", CPU.Hazard.mem_rd_i, CPU.Hazard.rs1_i, CPU.Hazard.rs2_i, CPU.Hazard.rrd_i, CPU.Hazard.hazard_occur);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x0000 = %h", Data_Memory.memory[0]);
    $fdisplay(outfile, "Data Memory: 0x0020 = %h", Data_Memory.memory[1]);
    $fdisplay(outfile, "Data Memory: 0x0040 = %h", Data_Memory.memory[2]);
    $fdisplay(outfile, "Data Memory: 0x0060 = %h", Data_Memory.memory[3]);
    $fdisplay(outfile, "Data Memory: 0x0080 = %h", Data_Memory.memory[4]);
    $fdisplay(outfile, "Data Memory: 0x00A0 = %h", Data_Memory.memory[5]);
    $fdisplay(outfile, "Data Memory: 0x00C0 = %h", Data_Memory.memory[6]);
    $fdisplay(outfile, "Data Memory: 0x00E0 = %h", Data_Memory.memory[7]);
    $fdisplay(outfile, "Data Memory: 0x0400 = %h", Data_Memory.memory[32]);
    
    $fdisplay(outfile, "\n");
    
    // print Data Cache Status
    if(CPU.dcache.p1_stall_o && CPU.dcache.state==0) begin
        if(CPU.dcache.sram_dirty) begin
            if(CPU.dcache.p1_MemWrite_i) 
                $fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h (Write Back!)", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
            else if(CPU.dcache.p1_MemRead_i) 
                $fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h (Write Back!)", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
        end
        else begin
            if(CPU.dcache.p1_MemWrite_i) 
                $fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
            else if(CPU.dcache.p1_MemRead_i) 
                $fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
        end
        flag = 1'b1;
    end
    else if(!CPU.dcache.p1_stall_o) begin
        if(!flag) begin
            if(CPU.dcache.p1_MemWrite_i) 
                $fdisplay(outfile2, "Cycle: %d, Write Hit , Address: %h, Write Data: %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
            else if(CPU.dcache.p1_MemRead_i) 
                $fdisplay(outfile2, "Cycle: %d, Read Hit  , Address: %h, Read Data : %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
        end
        flag = 1'b0;
    end
        
    counter = counter + 1;
end

  
endmodule
