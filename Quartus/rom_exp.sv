/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_exp
(
		input [11:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 3 bits and a total of 4096 addresses
logic [3:0] mem [0:4095], data;

initial
begin
	 $readmemh("rom_explosion_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h9a3a06;
		4'd2: data_out <= 24'hffff15;
		4'd3: data_out <= 24'h6b260e;
		4'd4: data_out <= 24'hffc113;
		4'd5: data_out <= 24'hfd7b0f;
		4'd6: data_out <= 24'he9580f;
		4'd7: data_out <= 24'hffc510;
	endcase
end

endmodule
