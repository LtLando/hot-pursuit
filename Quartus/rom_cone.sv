/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_cone
(
		input [11:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 2160 addresses
logic [3:0] mem [0:2159], data;

initial
begin
	 $readmemh("rom_cone_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'h00ff00;
		4'd1: data_out <= 24'hff512f;
		4'd2: data_out <= 24'hfd7461;
		4'd3: data_out <= 24'hffffff;
	endcase
end

endmodule
