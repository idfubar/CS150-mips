module alu(input [31:0] a, b,
		input [3:0] alucontrol,
		output [31:0] y);

//0000:and
//0001:or
//0010:addu
//0011:xor
//0100:pass B
//0101:nor
//0110:subu
//0111:slt
//1000:sltu
//1001:sll
//1010:srl
//1011:sra

always@(*)
	case(alucontrol)
		4'b0000: y <= a & b;
		4'b0001: y <= a | b;
		4'b0010: y <= $unsigned(a) + $unsigned(b);
		4'b0011: y <= a ^ b;
		4'b0100: y <= b;
		4'b0101: y <= !(a | b);
		4'b0110: y <= $unsigned(a) - $unsigned(b);
		4'b0111: y <= ( a < b ? 32'b1 : 32'b0 );
		4'b1000: y <= ( $unsigned(a) < $unsigned(b) ? 32'b1 : 32'b0);
		4'b1001: y <= a << b;
		4'b1010: y <= a >> b;
		4'b1011: y <= a >>> b;
	endcase
endmodule
