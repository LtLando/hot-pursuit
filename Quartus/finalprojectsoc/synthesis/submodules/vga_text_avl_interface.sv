/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
//`define NUM_REGS 601 //80*30 characters / 4 characters per register
//`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
logic [31:0] palette [8]; //8 32-bit registers for color palette
//put other local variables here
logic [10:0] sprite_addr;			//sprite address
logic [7:0] sprite_data;			//sprite data
logic [9:0] DrawX;
logic [9:0] DrawY;
logic [11:0] corner;			//top left corner of glyph
//logic [11:0] targetReg;
logic charInReg;
logic [3:0] romRow;		//used as select bits for mux
logic [2:0] romCol;
logic char;
logic blank; //blank signal
logic sync; //not used
logic VGA_Clk; //not used
logic [6:0] charX;
logic [4:0] charY;
logic invert; //inversion bit
logic [3:0] fgd_idx;
logic [3:0] bkg_idx;
logic colorInReg;
logic [2:0] colorReg;
logic [31:0] ram_readdata_a;
logic [31:0] ram_readdata_b;
logic [11:0] ram_addr;

//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller vga0 (.Clk (CLK),			//VGA controller
							.Reset (RESET),
							.hs (hs),
							.vs (vs),
							.pixel_clk(VGA_clk),
							.blank(blank),
							.sync(sync),
							.DrawX(DrawX),
							.DrawY(DrawY)
							);
							
font_rom rom0 (.addr (sprite_addr),		//font rom
					.data (sprite_data)
					);
					
ram ram0 (.address_a (AVL_ADDR),			//on-chip memory (megafunction)
			 .address_b (ram_addr),
			 .byteena_a (AVL_BYTE_EN),
			 .clock (CLK),
			 .data_a (AVL_WRITEDATA),
			 .data_b (),					//leave blank since 2 reads but only 1 write
			 .rden_a (AVL_READ & ~AVL_ADDR[11]),
			 .rden_b (1'b1),				//always reading and will take when it needs
			 .wren_a (AVL_WRITE & ~AVL_ADDR[11]),
			 .wren_b (1'b0),
			 .q_a (ram_readdata_a),
			 .q_b (ram_readdata_b)
			 );
			 
			 
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin

	if (RESET) begin											//reset registers
		for (int i = 0; i < 8; i++)
			palette[i] <= 32'b0;
	end
	else if (AVL_WRITE && AVL_CS) begin		//write to registers
		if (AVL_ADDR[11]) begin
			if (AVL_BYTE_EN[0])
				palette[AVL_ADDR[10:0]][7:0] <= AVL_WRITEDATA[7:0];
			if (AVL_BYTE_EN[1])
				palette[AVL_ADDR[10:0]][15:8] <= AVL_WRITEDATA[15:8];
			if (AVL_BYTE_EN[2])
				palette[AVL_ADDR[10:0]][23:16] <= AVL_WRITEDATA[23:16];
			if (AVL_BYTE_EN[3])
				palette[AVL_ADDR[10:0]][31:24] <= AVL_WRITEDATA[31:24];	
		end
	end
	else if (AVL_READ && AVL_CS) begin		//read from registers (irrespective of byte enable)
		if (AVL_ADDR[11]) begin
			AVL_READDATA[7:0] <= palette[AVL_ADDR[10:0]][7:0];
			AVL_READDATA[15:8] <= palette[AVL_ADDR[10:0]][15:8];
			AVL_READDATA[23:16] <= palette[AVL_ADDR[10:0]][23:16];
			AVL_READDATA[31:24] <= palette[AVL_ADDR[10:0]][31:24];
		end
		else begin
			AVL_READDATA <= ram_readdata_a;
		end
	end
end


//handle drawing (may either be combinational or sequential - or both).
always_comb
begin 
	charX = DrawX>>3; // /8      bitwise ops instead of division and modulo
	charY = DrawY>>4; // /16
	corner = (charX + (80*charY)); //row major order
	ram_addr = corner>>1; //   /2
	charInReg = corner[0]; //   %2
	romRow = DrawY[3:0]; //     %16
	unique case (charInReg)
		1'b0: begin 
					sprite_addr = {ram_readdata_b[14:8], romRow}; //MSB of VRAM slice used for inversion bit
					invert = ram_readdata_b[15];
					fgd_idx = ram_readdata_b[7:4];
					bkg_idx = ram_readdata_b[3:0];
				end
		1'b1: begin 
					sprite_addr = {ram_readdata_b[30:24], romRow}; 
					invert = ram_readdata_b[31]; 
					fgd_idx = ram_readdata_b[23:20];
					bkg_idx = ram_readdata_b[19:16];
				end
	endcase
	
	romCol = DrawX[2:0]; // %8
	unique case (romCol)
		3'b000: char = sprite_data[7]; //inverted outputs
		3'b001: char = sprite_data[6];
		3'b010: char = sprite_data[5];
		3'b011: char = sprite_data[4];
		3'b100: char = sprite_data[3];
		3'b101: char = sprite_data[2];
		3'b110: char = sprite_data[1];
		3'b111: char = sprite_data[0];
		default: char = 1'b0;
	endcase
	
	if (invert) //inversion
		char = ~char;
	
	if (char) //RGB display
	begin //use fgd_idx
		colorReg = fgd_idx>>1;   // /2
		colorInReg = fgd_idx[0]; // %2
	end
	else
	begin //use bkg_idx
		colorReg = bkg_idx>>1;   // /2
		colorInReg = bkg_idx[0]; // %2
	end
	
	if (~colorInReg) begin //assign colors
		blue = palette[colorReg][4:1];
		green = palette[colorReg][8:5];
		red = palette[colorReg][12:9];
	end
	else begin
		blue = palette[colorReg][16:13];
		green = palette[colorReg][20:17];
		red = palette[colorReg][24:21];
	end
	
	if (~blank) //active low blank signal
	begin
		blue = 4'h0;
		red = 4'h0;
		green = 4'h0;
	end
end

endmodule
