module spawnStar (input logic Clk, en,
					output logic signed [10:0] X_Pos, Y_Pos, X_Motion, Y_Motion
					);
					
logic [2:0] code;

LFSR LFSR1 (.i_Clk(Clk),
				.i_Enable(en),
				.o_LFSR_Data(code)
				 );
					 
always_comb
begin
	unique case (code)
		3'b001: begin
						X_Pos <= 0;
						Y_Pos <= 0;
						X_Motion <= 3;
						Y_Motion <= 2;
				  end
		3'b011: begin
						X_Pos <= 599;
						Y_Pos <= 0;
						X_Motion <= -3;
						Y_Motion <= 2;
				  end
		3'b101: begin
						X_Pos <= 0;
						Y_Pos <= 441;
						X_Motion <= 3;
						Y_Motion <= -2;
				  end
		3'b110: begin
						X_Pos <= 599;
						Y_Pos <= 441;
						X_Motion <= -3;
						Y_Motion <= -2;
				  end
	endcase
end
endmodule