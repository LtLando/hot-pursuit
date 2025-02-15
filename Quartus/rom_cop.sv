/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module rom_cop
(
		input [14:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

// mem has width of 4 bits and a total of 17408 addresses
logic [3:0] mem [0:17407], data;

initial
begin
	 $readmemh("rom_cop_txt.txt", mem);
end

always_ff @ (posedge Clk) begin
	data <= mem[read_address];
end

always_comb begin
	unique case (data)
		4'd0: data_out <= 24'h00ff00;
		4'd1: data_out <= 24'h000000;
		4'd2: data_out <= 24'hffffff;
		4'd3: data_out <= 24'h41465d;
		4'd4: data_out <= 24'h9f9b9d;
		4'd5: data_out <= 24'h32292f;
		4'd6: data_out <= 24'he04a47;
		4'd7: data_out <= 24'h8b110d;
		4'd8: data_out <= 24'h4257a6;
		4'd9: data_out <= 24'h2e2d88;
	endcase
end

endmodule
