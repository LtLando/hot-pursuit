/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_shield
(
		input [11:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 2080 addresses
logic [3:0] mem [0:2079], data;

initial
begin
	 $readmemh("rom_shield_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h6c194e;
		4'd2: data_out <= 24'h47163b;
		4'd3: data_out <= 24'h290c28;
		4'd4: data_out <= 24'h0d0512;
		4'd5: data_out <= 24'h5a4651;
		4'd6: data_out <= 24'heae49e;
		4'd7: data_out <= 24'h765165;
		4'd8: data_out <= 24'ha26d27;
		4'd9: data_out <= 24'h975b79;
	endcase
end

endmodule
