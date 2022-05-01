/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_barrel
(
		input [13:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 3 bits and a total of 1680 addresses
logic [3:0] mem [0:1679], data;

initial
begin
	 $readmemh("rom_barrel_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'hee3526;
		4'd2: data_out <= 24'hffeb45;
		4'd3: data_out <= 24'h000000;
		4'd4: data_out <= 24'hebb665;
		4'd5: data_out <= 24'h9b9d9e;
		4'd6: data_out <= 24'hb80a05;
		4'd7: data_out <= 24'h4c0604;
	endcase
end

endmodule
