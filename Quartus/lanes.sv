module lanes ( input Reset, frame_clk,
					input logic [10:0] diff,
               output [10:0] StripeX [60], StripeY [60], StripeW, StripeH);
    
    logic signed [10:0] Stripe_X_Pos [60], Stripe_Y_Pos [60], Stripe_Y_Motion [60], Stripe_Width, Stripe_Height, y_idx [60];
	 
    parameter [10:0] Stripe_X_1=0;  // Start positions on the X axis
	 parameter [10:0] Stripe_X_2=125;
	 parameter [10:0] Stripe_X_3=253;
	 parameter [10:0] Stripe_X_4=381;
	 parameter [10:0] Stripe_X_5=509;
	 parameter [10:0] Stripe_X_6=637;
    parameter [10:0] Stripe_Y_Min=0;       // Topmost point on the Y axis
    parameter [10:0] Stripe_Y_Max=479;     // Bottommost point on the Y axis
	 
    assign Stripe_Width = 6;  
	 assign Stripe_Height = 38;
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_lanes
        if (Reset)  // Asynchronous Reset
        begin 
				for (int i = 0; i < 60; i++)
				begin
					if (i < 10)
					begin
						Stripe_X_Pos[i] <= Stripe_X_1;
						y_idx[i] <= i;
					end
					else if (i < 20)
					begin
						Stripe_X_Pos[i] <= Stripe_X_2;
						y_idx[i] <= i - 10;
					end
					else if (i < 30)
					begin
						Stripe_X_Pos[i] <= Stripe_X_3;
						y_idx[i] <= i - 20;
					end
					else if (i < 40)
					begin
						Stripe_X_Pos[i] <= Stripe_X_4;
						y_idx[i] <= i - 30;
					end
					else if (i < 50)
					begin
						Stripe_X_Pos[i] <= Stripe_X_5;
						y_idx[i] <= i - 40;
					end
					else
					begin
						Stripe_X_Pos[i] <= Stripe_X_6;
						y_idx[i] <= i - 50;
					end
					
					Stripe_Y_Pos[i] <= y_idx[i] * 48;
					
					Stripe_Y_Motion[i] <= diff;
				end
        end

        else
        begin 
		    for (int i = 0; i < 60; i++)
			 begin
				 Stripe_Y_Motion[i] <= diff;
				
				 if (Stripe_Y_Pos[i] >= Stripe_Y_Max)  // Stripe is at the bottom edge, PASS THROUGH!
				 begin
					  Stripe_Y_Pos[i] <= Stripe_Y_Min;
					  if (diff == 11'd1)
							Stripe_Y_Motion[i] <= 11'd33;
					  else if (diff == 11'd2)
							Stripe_Y_Motion[i] <= 11'd46;
					  else if (diff == 11'd3)
							Stripe_Y_Motion[i] <= 11'd61;
				 end
				 else if (Stripe_Y_Pos[i] + Stripe_Height >= Stripe_Y_Min) //Stripe is at top edge, slow down from pass through
				 begin
					Stripe_Y_Motion[i] <= diff;
				 end
				
				 Stripe_Y_Pos[i] <= (Stripe_Y_Pos[i] + Stripe_Y_Motion[i]);  // Update stripes' positions
			 end
		end  
    end
       
    assign StripeX = Stripe_X_Pos;
   
    assign StripeY = Stripe_Y_Pos;
	 
	 assign StripeW = Stripe_Width;
	 
	 assign StripeH = Stripe_Height;
    

endmodule
