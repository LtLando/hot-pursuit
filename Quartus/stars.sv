module stars ( input logic Reset, frame_clk, collect,
               output logic [10:0] StarX, StarY, StarW, StarH,
					output logic starLive);
    
    logic signed [10:0] Star_X_Pos, Star_Y_Pos, Star_X_Motion, Star_Y_Motion, Star_Width, Star_Height,
								New_X_Pos, New_Y_Pos, New_X_Motion, New_Y_Motion;
	 logic spawn;
	 logic [9:0] count;
	 
	 assign Star_Width = 40;
	 assign Star_Height = 38;
	 
    parameter [10:0] Star_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Star_X_Max=639;     // Rightmost point on the X axis
    parameter [10:0] Star_Y_Min=0;       // Topmost point on the Y axis
    parameter [10:0] Star_Y_Max=479;     // Bottommost point on the Y axis
	 
	 spawnStar spawnStar0 (.Clk(frame_clk),
							 .en(spawn),
							 .X_Pos(New_X_Pos),
							 .Y_Pos(New_Y_Pos),
							 .X_Motion(New_X_Motion),
							 .Y_Motion(New_Y_Motion)
							);
							
	 logic expired;
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Object
        if (Reset)  // Asynchronous Reset
        begin 
			   starLive <= 1'b0;
				spawn <= 1'b1; 	
				Star_X_Pos <= New_X_Pos;
				Star_Y_Pos <= New_Y_Pos;
				Star_X_Motion <= New_X_Motion;
				Star_Y_Motion <= New_Y_Motion;
			end
			
			else if (collect || expired)
			begin
				if (count < 10'd1000)    //delay release of new stars
				begin
					count <= count + 1'b1;
					starLive <= 1'b0;
					Star_X_Pos <= -100; //off screen
					Star_Y_Pos <= -100;
					Star_X_Motion <= 0;
					Star_Y_Motion <= 0;
				end
				else
				begin
					starLive <= 1'b1;
					expired <= 1'b0;
					spawn <= 1'b1;
					count <= 10'b0;
					Star_X_Pos <= New_X_Pos;
				   Star_Y_Pos <= New_Y_Pos;
				   Star_X_Motion <= New_X_Motion;
				   Star_Y_Motion <= New_Y_Motion;
				end
			end
			
		  else
        begin 
			 spawn <= 1'b0;
			 if ( (Star_Y_Pos) > Star_Y_Max )  // Star is beyond the bottom edge, EXPIRED!
				  expired <= 1'b1;
				  
			 else if ( (Star_Y_Pos) < Star_Y_Min )  // Star is beyond the top edge, EXPIRED!
				  expired <= 1'b1;
				  
			  else if ( (Star_X_Pos) > Star_X_Max )  // Star is beyond the Right edge, EXPIRED!
				  expired <= 1'b1;
				 
			 else if ( (Star_X_Pos) < Star_X_Min )  // Star is beyond the Left edge, EXPIRED!
				  expired <= 1'b1;
			  else
				  expired <= 1'b0;
	  
			 Star_X_Pos <= Star_X_Pos + Star_X_Motion; //Update star's position
			 Star_Y_Pos <= Star_Y_Pos + Star_Y_Motion;
		  end			
    end
       
    assign StarX = Star_X_Pos;
   
    assign StarY = Star_Y_Pos;
	 
	 assign StarW = Star_Width;
	 
	 assign StarH = Star_Height;
    

endmodule