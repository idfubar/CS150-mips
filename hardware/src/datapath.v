module datapath(	input		clk, reset,
			input		JALValE, JALDstE, 
			input [1:0]	PCBranchAddrE,
			input		RegWriteE, 
			input		SignOrZeroE,
			input		RegDstE,
			input [1:0]	ALUSrcE, 
			input		MemToRegE,
			input [3:0]	ALUControlE,
			input [1:0]	MaskControlE,
			input [1:0]	LBLHEnableE,
			output [31:0] 	PCI,
			input  [31:0] 	InstrI,
			output [31:0] InstrEOut,
			output [3:0] 	MaskM,
			output [31:0] 	ALUOutMOut, WriteDataM,
			input  [31:0] 	ReadDataM,
			input		ForwardAE,
			input		ForwardBE,
			output 		RsE,
			output		RtE,
			output		WriteRegMOut);

//outputs ALUOutM, WriteDataM

  wire [4:0]  WriteRegM; //wire connecting FF output to module output
  assign WriteRegMOut = WriteRegM;

  wire ALUOutM; //wire connecting FF output to module output
  assign ALUOutMOut = ALUOutM;

  wire [31:0] PCNextI, PCPlus4I, PCBranchE, PCBranchM;
  wire [31:0] SignImmE, SignImmSh;
  wire [31:0] PCIOut; 

  wire [31:0] PCBranchCompE, WD3, RSValE, RTValE, SrcBMuxE, MaskE, ImmSh;
  wire [4:0] A3;
  wire JumpE;
  wire [27:0] JumpSh;
  wire  [4:0]	WriteRegE;
  wire [31:0] SrcA, SrcB, ALUOutE;
  wire [31:0] InstrE;

	assign InstrEOut = InstrE;

 	assign RsE = InstrI[25:21];
 	assign RtE = InstrI[20:16];

  // next PC logic
  assign PCI = PCIOut;
  flopr #(32) pcreg(clk, reset, PCNextI, PCIOut);
  adder       pcadd1(PCI, 32'b0100, PCPlus4I);
	//PC Branch Datapath (Lowest Path)
  		//PCBranch mux: 01
  	signext     	se(InstrE[15:0], SignOrZeroE, SignImmE);
  	sl2         	immsh(SignImmE, SignImmSh);
  	adder       	pcadd2(PCPlus4E, SignImmSh, PCBranchCompE);
		//PCBranch mux: 11
  	sl2		jsh(InstrE[25:0], JumpSh);
  	mux4 		pcbrmux(RSValE, PCBranchCompE, PCPlus4E, {InstrE[31:28], JumpSh, 2'b00}, PCBranchAddrE, PCBranchE);
		//PCNextI mux
  	mux2 		pcmux(PCPlus4I, PCBranchM, JumpM, PCNextI);

//How to implement pipeline register?
//pflopr(input: InstrI, PCPlus4I; output: InstrE, PCPlus4E)

  // register file logic
  regfile     rf(clk, RegWriteM, InstrE[25:21], InstrE[20:16], A3, WD3, RSValE, RTValE);
	//Register File Datapath (Middle Path)
		//Left Mux
	mux2 #(5)   wrmux(InstrE[20:16], InstrE[15:11], RegDstE, WriteRegE);
		//Far-Right Mux
	mux2    resmux(ALUOutM, MaskDataM, MemToRegM, ResultM);
		//A3 Input Mux
	mux2 #(5) a3mux(WriteRegM, 5'b11111, JALDstM, A3);
		//WD3 Input Mux
	mux2    wd3mux(ResultM, PCPlus4E, JALValM, WD3);
  // ALU logic
	//ALUSrc mux: 10
	sl16	luish(InstrE[15:0], ImmSh);
	//ALUSrcE mux
	mux4	srcbmux(RTValE, SignImmE, ImmSh, {27'b0, InstrE[10:6]}, ALUSrcE, SrcBMuxE);
	//SrcA mux 
	mux2	srcahazmux(RSValE, ResultM, ForwardAE, SrcA);
	//SrcB mux
	mux2	srcbhazmux(SrcBMuxE, ResultM, ForwardBE, SrcB);
	//ALU
	alu	alu(SrcA, SrcB, ALUControlE, ZeroE, ALUOutE);

	assign JumpE = ALUControlE[3] & ZeroE;

  // Mask logic
	//writemask
	writeMaskE writemask(MaskControlE, ALUOutE, RTValE, MaskE, WriteDataE);
	//maskapply
	maskapply maskapply(ReadDataM, LBLHEnableM, MaskDataM);

//pipeline register
	flopr #(15) XMsave(clk, 
							reset,
							{MaskE, ALUOutE, WriteDataE, 
								WriteRegE, PCBranchE, RegWriteE, 
								MemToRegE, LBLHEnableE, JALValE, JALDstE, JumpE},
							{MaskM, ALUOutM, WriteDataM, 
								WriteRegM, PCBranchM, RegWriteM, 
								MemToRegM, LBLHEnableM, JALValM, JALDstM, JumpM});

	flopr #(2) IXsave(clk, 
							reset,
							{InstrI, PCPlus4I},
							{InstrE, PCPlus4E});

endmodule
