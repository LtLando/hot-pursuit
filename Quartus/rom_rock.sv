/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_rock
(
		input [13:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 2 bits and a total of 608 addresses
logic [3:0] mem [0:607], data;	   

initial
begin
	 $readmemh("rom_rock_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h685a43;
		4'd2: data_out <= 24'h7c6e58;
		4'd3: data_out <= 24'he2d4bb;
	endcase
end

endmodule
