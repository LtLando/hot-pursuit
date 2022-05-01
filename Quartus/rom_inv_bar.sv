/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_inv_bar
(
		input [10:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 1200 addresses
logic [3:0] mem [0:1199], data;

initial
begin
	 $readmemh("rom_invbar_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hc28d57;
		4'd1: data_out <= 24'he7ceb7;
		4'd2: data_out <= 24'h75552c;
		4'd3: data_out <= 24'h6f6b66;
		4'd4: data_out <= 24'h4751a3;
	endcase
end

endmodule
