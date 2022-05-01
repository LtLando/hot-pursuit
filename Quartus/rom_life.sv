/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_life
(
		input [10:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 1560 addresses
logic [3:0] mem [0:1559], data;

initial
begin
	 $readmemh("rom_life_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'heb8b7d;
		4'd2: data_out <= 24'hdf5b48;
		4'd3: data_out <= 24'haa0f00;
		4'd4: data_out <= 24'he60000;
		4'd5: data_out <= 24'h77bb3e;
		4'd6: data_out <= 24'hddbd18;
		4'd7: data_out <= 24'hbbbc25;
		4'd8: data_out <= 24'hce2813;
	endcase
end

endmodule
