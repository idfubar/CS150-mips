module maindec(	input [5:0] 	Op,
		input [5:0] 	Funct,
		output		JALValM, JALDstM, 
		output [1:0]	PCBranchAddrE,
		output		RegWriteM, 
		output		SignOrZeroE,
		output		RegDstE, RegValE,
		output [1:0]	ALUSrcE, 
		output		MemWriteM,
		output		MemToRegM,
		output [1:0]	ALUOp,
		output [1:0]	MaskOp);

reg [8:0] controls;

//assume SignOrZeroE == 0 is zero-extend

assign {JumpM, JALValM, JALDstM, RegWriteM, 
	SignOrZeroE, RegDstE, ALUSrcE, 
	RegValE, PCBranchAddrE, MemToRegM, 
	ALUop, MaskOp} = controls;

always @ (*)
	case(op)
		6'b000001: controls <= 16'b1XXX1X00X010 ??00; //BLTZ,BGEZ
		6'b000010: controls <= 16'b1XXXXXXXX11X 00; //J
		6'b000011: controls <= 16'b111XXXXXX11X 00; //JAL
		6'b000100: controls <= 16'b1XXX1X00X010 00; //BEQ
		6'b000101: controls <= 16'b1XXX1X00X010 00; //BNE
		6'b000110: controls <= 16'b1XXX1X00X010 00; //BLEZ
		6'b000111: controls <= 16'b1XXX1X00X010 00; //BGTZ
		6'b001001: controls <= 16'b000110010XX0 00; //ADDIU
		6'b001010: controls <= 16'b000110010XX0 00; //SLTI
		6'b001011: controls <= 16'b000110010XX0 00; //SLTIU
		6'b001100: controls <= 16'b000100010XX0 00; //ANDI
		6'b001101: controls <= 16'b000100010XX0 00; //ORI
		6'b001110: controls <= 16'b000100010XX0 00; //XORI
		6'b001111: controls <= 16'b0001X0100XX0 00; //LUI
		6'b100000: controls <= 16'b00011X01XXX1 ??01; //LB
		6'b100001: controls <= 16'b00011X01XXX1 10; //LH
		6'b100011: controls <= 16'b00011X01XXX1 ??; //LW
		6'b100100: controls <= 16'b00011X01XXX1 01; //LBU
		6'b100101: controls <= 16'b00011X01XXX1 10; //LHU
		6'b101000: controls <= 16'b00000X01XXX0 ??01; //SB
		6'b101001: controls <= 16'b00000X01XXX0 10; //SH
		6'b101011: controls <= 16'b00000X01XXX0 ??; //SW
		default:   case(Funct) 
			6'b000000: controls <= 16'b0001 1111 0XX0 ??00; //SLL
			6'b000010: controls <= 16'b0001 1111 0XX0 ??00; //SRL
			6'b000011: controls <= 16'b0001 1111 0XX0 ??00; //SRA
			6'b001000: controls <= 16'b1XXXXXXXX00X 00; //JR
			6'b001001: controls <= 16'b110XXXXX100X 00; //JALR
			default:   controls <= 16'b0001 1100 0XX0 ??00; //All Other R-type
		endcase
	endcase
endmodule





//assign { JumpM, JALValM, JALDstM, RegWriteM, SignOrZeroE, RegDstE, ALUSrcE, ComparatorSrcE, RegValE, PCBranchAddrE, MemWriteM, MemToRegM, ALUop, ComparatorOp} = controls;

//assign { regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

//6'b000000: controls <= 9'b110000010; //R-type
//6'b100011: controls <= 9'b101001000; //LW
//6'b101011: controls <= 9'b001010000; //SW
//6'b000100: controls <= 9'b000100001; //BEQ
//6'b001000: controls <= 9'b101000000; //ADDI
//6'b001011: controls <= 9'b101000011; //SLTI
//6'b000010: controls <= 9'b000000100; //J
//default:   controls <= 9'bxxxxxxxxx; //???