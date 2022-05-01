module car ( input Reset, frame_clk, menuLive, nosLoadedOut, noShift,
					input [7:0] keycode,
               output [10:0]  CarX, CarY, CarW, CarH, CopX, CopY, CopW, CopH,
					output logic nosLoadedIn, nosActive);
    
    logic signed [10:0] Car_X_Pos, Car_X_Motion, Car_Y_Pos, Car_Y_Motion, Car_Width, Car_Height, New_Lane, Cop_Width, Cop_Height;
	 logic [7:0] nosCount;
	 logic [1:0] nosMult;
	 logic shifting;
	 
    parameter [10:0] Car_X_Start=288;  // Start position on the X axis
    parameter [10:0] Car_Y_Start=419;  // Start position on the Y axis
    parameter [10:0] Car_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Car_X_Max=639;     // Rightmost point on the X axis
    parameter [10:0] Car_Y_Min=0;       // Topmost point on the Y axis
    parameter [10:0] Car_Y_Max=479;     // Bottommost point on the Y axis
    parameter [10:0] Car_X_Step=1;      // Step size on the X axis
    parameter [10:0] Car_Y_Step=1;      // Step size on the Y axis
	 parameter [10:0] Lane_Shift=128;		// Lane shift size on X axis
	 
    assign Car_Width = 64;  
	 assign Car_Height = 130;
    assign Cop_Width = 64;
	 assign Cop_Height = 130;
	
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Car
        if (Reset)  // Asynchronous Reset
        begin 
            Car_Y_Motion <= 11'd0;
				Car_X_Motion <= 11'd0;
				Car_Y_Pos <= Car_Y_Start;
				Car_X_Pos <= Car_X_Start;
				New_Lane <= Car_X_Start;
				shifting <= 0;
				nosCount <= 8'd200;
				nosActive <= 1'b0;
				nosLoadedIn <= 1'b1;
				nosMult <= 2'd1;
        end

        else if (~menuLive)
        begin
				 if ( (Car_Y_Pos + Car_Height) >= Car_Y_Max )  // Car is at the bottom edge, STOP!
					  Car_Y_Motion <= (~ (Car_Y_Step) + 1'b1);  // 2's complement.
					  
				 else if ( Car_Y_Pos[10] )  // Car is at the top edge, STOP!
					  Car_Y_Motion <= Car_Y_Step;
					  
				  else if ( Car_X_Pos >= Car_X_Max )  // Car is at the Right edge, PASS THROUGH!
					  Car_X_Pos <= Car_X_Min;
					  
				 else if ( Car_X_Pos <= Car_X_Min )  // Ball is at the Left edge, PASS THROUGH!
					  Car_X_Pos <= Car_X_Max;
		  
				 else
				 begin
					  Car_Y_Motion <= Car_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  
				 
				 case (keycode)
					8'd80 : if (~shifting && ~noShift) begin //left arrow, do nothing if shifting or oiled
								if (((Car_X_Pos - (Car_Width>>1)) % Lane_Shift) == 0) //only assign new lane if in center of lane
									begin
									shifting <= 1;
									if (Car_X_Pos > 32)
									begin
										New_Lane <= Car_X_Pos - Lane_Shift; //any other lane
										Car_X_Motion <= -4*nosMult;
									end
									else
									begin
										New_Lane <= Car_X_Pos + (4*Lane_Shift); //far left lane
										Car_X_Motion <= -32*nosMult;
									end
									end
							  end
					        
					8'd79 : if (~shifting && ~noShift) begin //right arrow, do nothing if shifting or oiled
								if (((Car_X_Pos - (Car_Width>>1)) % Lane_Shift) == 0)  //only assign new lane if in center of lane
									begin
									shifting <= 1;
									if (Car_X_Pos < 544)
									begin
										New_Lane <= Car_X_Pos + Lane_Shift; //any other lane
										Car_X_Motion <= 4*nosMult;
									end
									else
									begin
										New_Lane <= Car_X_Pos - (4*Lane_Shift); //far right lane
										Car_X_Motion <= 32*nosMult;
									end
									end
							  end
							  
					8'd81 : Car_Y_Motion <= 2*nosMult;//down arrow
							  
					8'd82 : Car_Y_Motion <= -2*nosMult;//up arrow
					
					8'd44 : if (nosLoadedOut) //space
							  begin
								nosActive <= 1'b1;
								nosLoadedIn <= 1'b0;
							  end

					default: Car_Y_Motion <= 0;
			   endcase
				end
				
				if (nosActive)
				begin
					if (nosCount > 0)
					begin
						nosMult <= 2'd2;
						nosCount <= nosCount - 1'b1;
					end
					else
					begin
						nosMult <= 2'd1;
						nosActive <= 1'b0;
						nosCount <= 8'd200;
						nosLoadedIn <= 1'b1;
					end
				end
				
				if (Car_X_Motion > 0) //moving right
				begin
					if (Car_X_Pos >= New_Lane - Car_X_Motion && Car_X_Pos < 544) //subtract to solve timing issue
					begin
						Car_X_Motion <= 0;
						shifting <= 0;
					end
				end
				else if (Car_X_Motion < 0) //moving left
				begin
					if (Car_X_Pos <= New_Lane - Car_X_Motion && Car_X_Pos > 32)
					begin
						Car_X_Motion <= 0;
						shifting <= 0;
					end
				end
				
				 CopX <= Car_X_Pos; //cop follows
				 CopY <= Car_Y_Pos + Car_Height + 50;
				 Car_Y_Pos <= (Car_Y_Pos + Car_Y_Motion);  // Update car position
				 Car_X_Pos <= (Car_X_Pos + Car_X_Motion);    
		end  
    end
       
    assign CarX = Car_X_Pos;
   
    assign CarY = Car_Y_Pos;
	 
	 assign CarW = Car_Width;
	 
	 assign CarH = Car_Height;
	 
	 assign CopW = Cop_Width;
	 
	 assign CopH = Cop_Height;
    

endmodule
