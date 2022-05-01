/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_car1
(
		input [15:0] read_address,
		input Clk,

		output logic [23:0] data_out
);


logic [3:0] data;

// mem has width of 4 bits and a total of 42600 addresses
(* ram_init_file = "rom_car1_mif.mif" *) reg [3:0] mem[0:41599];
//0-8319: 	   5 lives
//8320-16639:  4 lives
//16640-24959: 3 lives
//24960-33279: 2 lives
//33280-41599: 1 life

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'he24a44;
		4'd2: data_out <= 24'h4a455e;
		4'd3: data_out <= 24'h732d29;
		4'd4: data_out <= 24'hdfe2d1;
		4'd5: data_out <= 24'h98a2cf;
		4'd6: data_out <= 24'he3dea7;
		4'd7: data_out <= 24'h000000;
	endcase
end

endmodule
