/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_lose
(
		input [16:0] read_address,
		input Clk,

		output logic [23:0] data_out
);



logic [3:0] data;
// mem has width of 4 bits and a total of 76050 addresses
(* ram_init_file = "rom_lose_mif.mif" *) reg [3:0] mem[0:76049];

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h262828;
		4'd2: data_out <= 24'hbd874e;
		4'd3: data_out <= 24'h69441a;
		4'd4: data_out <= 24'hbfbfbf;
		4'd5: data_out <= 24'h9a9b9d;
		4'd6: data_out <= 24'he9cfb8;
		4'd7: data_out <= 24'h322d24;
		4'd8: data_out <= 24'hfcd36b;
		4'd9: data_out <= 24'hf47e21;
	endcase
end

endmodule
