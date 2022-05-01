/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_tree
(
		input [13:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 3 bits and a total of 3648 addresses
logic [3:0] mem [0:3647], data;

initial
begin
	 $readmemh("rom_tree_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'hffffff;
		4'd1: data_out <= 24'h184110;
		4'd2: data_out <= 24'h60a639;
		4'd3: data_out <= 24'h97c93d;
		4'd4: data_out <= 24'h8fc33c;
		4'd5: data_out <= 24'h49007e;
		4'd6: data_out <= 24'hcda02b;
		4'd7: data_out <= 24'h7e5125;
	endcase
end

endmodule
