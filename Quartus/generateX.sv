module generateX (input logic Clk, en,
					output logic [10:0] out
					);
					
logic [2:0] code;

LFSR LFSR0 (.i_Clk(Clk),
				.i_Enable(en),
				.o_LFSR_Data(code)
				 );
					 
always_comb
begin
	case (code)
		3'b000: out = 10'd64;
		3'b001: out = 10'd192;
		3'b010: out = 10'd320;
		3'b011: out = 10'd448;
		3'b100: out = 10'd576;
		3'b101: out = 10'd64;
		3'b110: out = 10'd320;
		3'b111: out = 10'd576;
	endcase
end
endmodule