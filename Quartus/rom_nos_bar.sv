/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_nos_bar
(
		input [10:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 3 bits and a total of 1200 addresses
logic [3:0] mem [0:1199], data;
//0-599:    no nos loaded
//600-1199: nos loaded

initial
begin
	 $readmemh("rom_nos_bar_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hb57e41;
		4'd1: data_out <= 24'he7ceb7;
		4'd2: data_out <= 24'h75542b;
		4'd3: data_out <= 24'hbab2a9;
		4'd4: data_out <= 24'h9a9a9a;
		4'd5: data_out <= 24'h33251d;
		4'd6: data_out <= 24'hbc6a37;
		4'd7: data_out <= 24'hffffff;
		4'd8: data_out <= 24'h1761bf;
	endcase
end

endmodule
