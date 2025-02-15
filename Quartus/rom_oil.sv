/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_oil
(
		input [11:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 1728 addresses
logic [3:0] mem [0:1727], data;

initial
begin
	 $readmemh("rom_oil_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h000000;
		4'd2: data_out <= 24'h1b1b1b;
		4'd3: data_out <= 24'h262627;
		4'd4: data_out <= 24'h2b2b2b;
		4'd5: data_out <= 24'h474747;
		4'd6: data_out <= 24'h606162;
	endcase
end

endmodule
