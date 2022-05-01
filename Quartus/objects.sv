module objects ( input Reset, frame_clk, 
					  input logic [10:0] diff,
					  input logic [7:0] trshdObjs,
               output [10:0]  ObjX [8], ObjY [8], ObjW [8], ObjH [8]);
    
    logic signed [10:0] Obj_X_Pos [8], New_X_Pos, Obj_Y_Pos [8], Obj_Y_Motion [8], Obj_Width [8], Obj_Height [8],
						objLeft [8], objTop [8], objRight [8], objBottom [8];
	 logic signed [7:0] exprdObjs;
	 logic genX;
	 
	 assign Obj_Width[0] = 32; //rock
	 assign Obj_Height[0] = 19;
	 
	 assign Obj_Width[1] = 64; //tree
	 assign Obj_Height[1] = 57;
	 
	 assign Obj_Width[2] = 40; //barrel
	 assign Obj_Height[2] = 42;
	 
	 assign Obj_Width[3] = 36; //nos
	 assign Obj_Height[3] = 60;
	 
	 assign Obj_Width[4] = 40; //life
	 assign Obj_Height[4] = 39;
	 
	 assign Obj_Width[5] = 40; //cone
	 assign Obj_Height[5] = 54;
	 
	 assign Obj_Width[6] = 64; //oil
	 assign Obj_Height[6] = 27;
	 
	 assign Obj_Width[7] = 40; //shield
	 assign Obj_Height[7] = 52;
	 
	 parameter [10:0] Obj_X_Start_0=64;  //Start positions on X axis
	 parameter [10:0] Obj_X_Start_1=192;
	 parameter [10:0] Obj_X_Start_2=320;
	 parameter [10:0] Obj_X_Start_3=448;
	 parameter [10:0] Obj_X_Start_4=576;
	 parameter [10:0] Obj_Y_Start_0=0;     // Start positions on Y axis
	 parameter [10:0] Obj_Y_Start_1=160;
    parameter [10:0] Obj_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Obj_X_Max=639;     // Rightmost point on the X axis
    parameter [10:0] Obj_Y_Min=0;       // Topmost point on the Y axis
    parameter [10:0] Obj_Y_Max=479;     // Bottommost point on the Y axis
	 
	 generateX generateX0 (.Clk(frame_clk),
							 .en(genX),
							 .out(New_X_Pos)
							);
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Object
        if (Reset)  // Asynchronous Reset
        begin 
				exprdObjs <= 8'b00000000;
				Obj_X_Pos[0] <= Obj_X_Start_0 - (Obj_Width[0]>>1);
				Obj_X_Pos[1] <= Obj_X_Start_1 - (Obj_Width[1]>>1) + 1; //adjust so you can't collide w/ 2 objs at same time
				Obj_X_Pos[2] <= Obj_X_Start_2 - (Obj_Width[2]>>1) + 1;
				Obj_X_Pos[3] <= Obj_X_Start_3 - (Obj_Width[3]>>1);
				Obj_X_Pos[4] <= Obj_X_Start_4 - (Obj_Width[4]>>1) - 1;
				Obj_X_Pos[5] <= Obj_X_Start_0 - (Obj_Width[5]>>1) + 2;
				Obj_X_Pos[6] <= Obj_X_Start_4 - (Obj_Width[6]>>1) - 1;
				Obj_X_Pos[7] <= Obj_X_Start_2 - (Obj_Width[7]>>1) - 2;
				for (int i = 0; i < 8; i++)
				begin
					if (i < 5)
						Obj_Y_Pos[i] <= Obj_Y_Start_0;
					else
						Obj_Y_Pos[i] <= Obj_Y_Start_1;
				end
			end
			
			else if ((trshdObjs || exprdObjs) != 8'b00000000)
			begin
				for (int i = 0; i < 8; i++)
				begin
					if (trshdObjs[i] || exprdObjs[i])
					begin
						genX <= 1'b1; //generate new x position
						if (i==1 || i==2) //adjust so you can't collide w/ 2 objs at same time
							Obj_X_Pos[i] <= New_X_Pos - (Obj_Width[i]>>1) + 1;
						else if (i==4 || i==6)
							Obj_X_Pos[i] <= New_X_Pos - (Obj_Width[i]>>1) - 1;
						else if (i==5)
							Obj_X_Pos[i] <= New_X_Pos - (Obj_Width[i]>>1) + 2;
						else if (i==7)
							Obj_X_Pos[i] <= New_X_Pos - (Obj_Width[i]>>1) - 2;
						else
							Obj_X_Pos[i] <= New_X_Pos - (Obj_Width[i]>>1);
						Obj_Y_Pos[i] <= Obj_Y_Start_0;
						Obj_Y_Motion[i] <= diff;
						exprdObjs[i] <= 1'b0;
					end
				end
			end
			
		  else
        begin 
		  genX <= 1'b0;
		  for (int i = 0; i < 8; i++)
		   begin
				 if ( (Obj_Y_Pos[i] + Obj_Height[i]) >= Obj_Y_Max )  // Object is at the bottom edge, TRASH IT!
					  exprdObjs[i] <= 1'b1;

				 Obj_Y_Motion[i] <= diff;
				 Obj_Y_Pos[i] <= (Obj_Y_Pos[i] + Obj_Y_Motion[i]);  // Update objects' positions	
			end
		  end			
    end
       
    assign ObjX = Obj_X_Pos;
   
    assign ObjY = Obj_Y_Pos;
	 
	 assign ObjW = Obj_Width;
	 
	 assign ObjH = Obj_Height;
    

endmodule