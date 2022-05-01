module finalproject (

      //////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk, replay, menuLive, collect, starLive, nosLoadedOut, nosLoadedIn, nosActive, noShift, start,
		startKey0, startKey1;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [10:0] drawxsig, drawysig, carxsig, carysig, carwidth, carheight, stripewidth, stripeheight, starwidth, starheight, diff;
	logic [10:0] objx [8], objy [8], objwidth [8], objheight [8], stripex [60], stripey [60], starx, stary, copx, copy, copwidth, copheight;
	logic [7:0] RedC, BlueC, GreenC, RedS, BlueS, GreenS;
	logic [7:0] keycode;
	logic [7:0] trshdObjs;
	
//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]) || replay;
	
	always_ff @ (negedge MAX10_CLK1_50) //make sure clock is in sync
	begin
		if (start)
			startKey0 <= 1'b1;
		else
			startKey0 <= 1'b0;
	end	
	
   always_ff @ (negedge MAX10_CLK1_50)
	begin
		if (start)
			startKey1 <= 1'b1;
		else
			startKey1 <= 1'b0;
	end	
	
	always_comb
	begin
	//Our A/D converter is only 12 bit
	if (start)
		begin
	   VGA_R = RedC[7:4];
	   VGA_B = BlueC[7:4];
	   VGA_G = GreenC[7:4];
		end
	else
		begin
		VGA_R = RedS[7:4];
	   VGA_B = BlueS[7:4];
	   VGA_G = GreenS[7:4];
		end
	end
	
	
	finalprojectsoc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		//.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs, HEX, SW
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		.sw_export(SW)		
	 );


	vga_controller vga0 (.Clk(MAX10_CLK1_50),
								.Reset(Reset_h),
								.hs(VGA_HS),
								.vs(VGA_VS),
								.pixel_clk(VGA_Clk),
								.blank(blank),
								.sync(sync),
								.DrawX(drawxsig),
								.DrawY(drawysig)
								);
								
	car car0 (.Reset(Reset_h),
					.frame_clk(VGA_VS&&startKey0),
					.menuLive(menuLive),
					.nosLoadedOut(nosLoadedOut),
					.noShift(noShift),
					.keycode(keycode),
					.CarX(carxsig),
					.CarY(carysig),
					.CarW(carwidth),
					.CarH(carheight),
					.CopX(copx),
					.CopY(copy),
					.CopW(copwidth),
					.CopH(copheight),
					.nosLoadedIn(nosLoadedIn),
					.nosActive(nosActive)
					);
					
	objects obj0 (.Reset(Reset_h),
					  .frame_clk(VGA_VS&&startKey0),
					  .diff(diff),
					  .trshdObjs(trshdObjs),
					  .ObjX(objx),
					  .ObjY(objy),
					  .ObjW(objwidth),
					  .ObjH(objheight)
						);
	
	lanes lanes0 (.Reset(Reset_h),
					  .frame_clk(VGA_VS),
					  .diff(diff),
					  .StripeX(stripex),
					  .StripeY(stripey),
					  .StripeW(stripewidth),
					  .StripeH(stripeheight)
					  );
					  
	stars stars0 (.Reset(Reset_h),
					  .frame_clk(VGA_VS&&startKey0),
					  .collect(collect),
					  .StarX(starx),
					  .StarY(stary),
					  .StarW(starwidth),
					  .StarH(starheight),
					  .starLive(starLive)
					 );
					 
   start start0 (.Clk(MAX10_CLK1_50),
						.Reset(Reset_h&&~replay),
						.blank(blank),
						.menuLive(menuLive),
						.keycode(keycode),
						.DrawX(drawxsig),
						.DrawY(drawysig),
						.StripeX(stripex),
						.StripeY(stripey),
						.Stripe_width(stripewidth),
						.Stripe_height(stripeheight),
						.Red(RedS),
						.Green(GreenS),
						.Blue(BlueS),
						.start(start),
						.difficulty(diff)						
						);

					
	color_mapper cmap0 (.CarX(carxsig),
							  .CarY(carysig),
							  .DrawX(drawxsig),
							  .DrawY(drawysig),
							  .Car_width(carwidth),
							  .Car_height(carheight),
							  .CopX(copx),
							  .CopY(copy),
							  .Cop_width(copwidth),
							  .Cop_height(copheight),
							  .ObjX(objx),
							  .ObjY(objy),
							  .Obj_width(objwidth),
							  .Obj_height(objheight),
							  .StripeX(stripex),
							  .StripeY(stripey),
							  .Stripe_width(stripewidth),
							  .Stripe_height(stripeheight),
							  .StarX(starx),
							  .StarY(stary),
							  .Star_width(starwidth),
							  .Star_height(starheight),
							  .Clk(MAX10_CLK1_50&&startKey1),
							  .Reset(Reset_h),
							  .blank(blank),
							  .starLive(starLive),
							  .nosLoadedIn(nosLoadedIn),
							  .nosActive(nosActive),
							  .keycode(keycode),
							  .Red(RedC),
							  .Blue(BlueC),
							  .Green(GreenC),
							  .trshdObjs(trshdObjs),
							  .replay(replay),
							  .menuLive(menuLive),
							  .collect(collect),
							  .nosLoadedOut(nosLoadedOut),
							  .noShift(noShift)
							  );
							  
endmodule
