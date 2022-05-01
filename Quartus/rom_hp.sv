/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_hp
(
		input [14:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 18432 addresses
logic [3:0] mem [0:18431], data;
//0-3071:      5 lives
//3072-6143:   4 lives
//6144-9215:   3 lives
//9216-12287:  2 lives
//12288-15359: 1 life
//15360-18432: 0 lives

initial
begin
	 $readmemh("rom_hp_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hb37c3e;
		4'd1: data_out <= 24'h70512a;
		4'd2: data_out <= 24'he8cfb9;
		4'd3: data_out <= 24'hde1e4d;
		4'd4: data_out <= 24'he693a1;
		4'd5: data_out <= 24'ha49f99;
		4'd6: data_out <= 24'h34322b;
		4'd7: data_out <= 24'h8e1811;
		4'd8: data_out <= 24'h39311f;
		4'd9: data_out <= 24'h4c493f;
	endcase
end

endmodule
