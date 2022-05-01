/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_track
(
		input [9:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 658 addresses
logic [3:0] mem [0:657], data;

initial
begin
	 $readmemh("rom_track_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h000000;
	endcase
end

endmodule
