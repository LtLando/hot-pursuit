/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_star
(
		input [10:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 3 bits and a total of 1520 addresses
logic [3:0] mem [0:1519], data;

initial
begin
	 $readmemh("rom_star_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		3'd0: data_out <= 24'hffffff;
		3'd1: data_out <= 24'hfcd36b;
		3'd2: data_out <= 24'hf47e21;
		3'd3: data_out <= 24'hfeef21;
		3'd4: data_out <= 24'he9ef94;
		3'd5: data_out <= 24'hfbc582;
		3'd6: data_out <= 24'hfde26b;
		3'd7: data_out <= 24'hf79d21;
	endcase
end

endmodule
