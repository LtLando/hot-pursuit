/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_start
(
		input [16:0] read_address,
		input Clk,

		output logic [23:0] data_out
);


logic [3:0] data;

// mem has width of 4 bits and a total of 73728 addresses
(* ram_init_file = "rom_start_mif.mif" *) reg [3:0] mem[0:73727];

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h000000;
		4'd2: data_out <= 24'hb28558;
		4'd3: data_out <= 24'hdcc3ac;
		4'd4: data_out <= 24'h69441a;
		4'd5: data_out <= 24'ha0a0a0;
		4'd6: data_out <= 24'h908f8d;
		4'd7: data_out <= 24'h413f39;
		4'd8: data_out <= 24'h303232;
	endcase
end

endmodule
