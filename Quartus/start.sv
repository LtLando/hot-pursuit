module start (  input logic Clk, Reset, blank, menuLive,
					 input logic [7:0] keycode,
					 input logic [10:0] DrawX, DrawY, StripeX [60], StripeY [60], Stripe_width, Stripe_height,
                output logic [7:0]  Red, Green, Blue,
					 output logic start,
					 output logic [10:0] difficulty
					);
					
	logic [16:0] start_addr;
	logic [23:0] start_data;
	logic start_on, lane_on;
	int unsigned startDistX, startDistY, Start_width, Start_height, stripeDistX [60], stripeDistY [60];
	logic [10:0] StartX, StartY;
					
	rom_start rom22 (.read_address (start_addr),
						.Clk (Clk),
						.data_out (start_data)
						);
	  
					
	always_ff @ (posedge Reset or posedge Clk)
    begin:stuff_on_proc	

		if (Reset)
		begin
			start <= 1'b0;
			start_addr <= 17'b0;
			difficulty <= 11'd0;
		end
		else
		begin
			startDistX <= DrawX - StartX; //start menu
			startDistY <= DrawY - StartY;
			start_on <= 1'b0;
			Start_width <= 256;
			Start_height <= 288;
			StartX <= 320 - (Start_width>>1);
			StartY <= 240 - (Start_height>>1);
			
			for (int i = 0; i < 60; i++) //lane stripes
			begin
				stripeDistX[i] <= DrawX - StripeX[i];
				stripeDistY[i] <= DrawY - StripeY[i];
			end
			lane_on <= 1'b0;
			
			if (startDistX <= Start_width && startDistY <= Start_height) //start menu
		  begin
				start_on <= 1'b1;
				start_addr <= (startDistY*Start_width) + startDistX;
		  end
		  
		  for (int i = 0; i < 60; i++) //lane stripes
		  begin
			if (i<10 || i>=50)
			begin
				if (stripeDistX[i] <= (Stripe_width/2) && stripeDistY[i]<=Stripe_height)
					lane_on <= 1'b1;
			end
			else
			begin
				if (stripeDistX[i] <= (Stripe_width) && stripeDistY[i]<=Stripe_height)
					lane_on <= 1'b1;
			end
	     end
		  
		  if (keycode==8'd30 && (~start || menuLive)) //1
			begin
			start <= 1'b1;
			difficulty <= 11'd1;
			end
		  else if (keycode==8'd31 && (~start || menuLive)) //2
			begin
			start <= 1'b1;
			difficulty <= 11'd2;
		   end
		  else if (keycode==8'd32 && (~start || menuLive)) //3
			begin
			start <= 1'b1;
			difficulty <= 11'd3;
			end
		  else
			begin
			start <= start;
			difficulty <= difficulty;
		   end
		end
	end
	
	always_comb
	begin:RGB_display		  
		  if(~blank) //blank signal
		  begin
				Red = 0;
				Green = 0;
				Blue = 0;
		  end
		  else if ((start_on) && (start_data != 24'hffffff)) //start menu
		  begin
				Red = start_data[23:16];
            Green = start_data[15:8];
            Blue = start_data[7:0];
		  end
		  else if (lane_on) //lane stripes
		  begin
				Red = 8'hff;
				Green = 8'he9;
				Blue = 8'h33;
		  end
		  else //black background
		  begin
				Red = 8'h40;
				Green = 8'h40;
				Blue = 8'h40;
		  end
	end
endmodule
	