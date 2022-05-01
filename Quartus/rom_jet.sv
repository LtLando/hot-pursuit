/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_jet
(
		input [8:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 480 addresses
logic [3:0] mem [0:479], data;

initial
begin
	 $readmemh("rom_jet_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h3c72b8;
		4'd2: data_out <= 24'h71addc;
		4'd3: data_out <= 24'ha9d8f3;
		4'd4: data_out <= 24'hc0e4f7;
		4'd5: data_out <= 24'h90abd6;
		4'd6: data_out <= 24'h7ba0cf;
	endcase
end

endmodule
