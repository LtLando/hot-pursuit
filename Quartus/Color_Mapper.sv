module  color_mapper ( input logic  [10:0] CarX, CarY, DrawX, DrawY, Car_width, Car_height, CopX, CopY, Cop_width, Cop_height,
												ObjX [8], ObjY [8], Obj_width [8], Obj_height [8],
												StripeX [60], StripeY [60], Stripe_width, Stripe_height,
												StarX, StarY, Star_width, Star_height,
							  input logic Clk, Reset, blank, starLive, nosLoadedIn, nosActive,
							  input logic [7:0] keycode,
                       output logic [7:0]  Red, Green, Blue,
							  output logic [7:0] trshdObjs,
							  output logic replay, menuLive, collect, nosLoadedOut, noShift
							  );
    
    logic car_on, col_on, lane_on, explode, exp_on, lost, lose_on, won, win_on, hp_on, star_on, starbar_on, nosbar_on, jet_on, 
			track_on, cop_on, siren, inv, invbar_on, car, switch, Clk1;
	 logic [1:0] stars;
	 logic [7:0] obj_on;
	 logic [2:0] damage;
	 logic [9:0] track_addr;
	 logic unsigned [31:0] oilCount, sirenCount, invCount;
	 logic [8:0] jet_offset, jet_addr;
	 logic [15:0] car_offset, car_addr;
	 logic [13:0] obj_addr [8];
	 logic [11:0] exp_addr;
	 logic [16:0] lose_addr, lose_offset;
	 logic [12:0] star_bar_addr, star_bar_offset;
	 logic [14:0] hp_offset, hp_addr, win_addr, cop_addr, cop_offset;
	 logic [23:0] car_data, obj_data [8], exp_data, lose_data, win_data, hp_data, star_data, star_bar_data, nos_bar_data, jet_data,
						track_data, cop_data, invbar_data, car1_data, car2_data;
	 logic [10:0] carLeft, carRight, carTop, carBottom, objLeft [8], objRight [8], objTop [8], objBottom [8],
						ExpX, ExpY, Exp_width, Exp_height, logCarX, logCarY, loseX, loseY, Menu_width, Menu_height,
						hpX, hpY, Hp_width, Hp_height, star_addr, starLeft, starRight, starTop, starBottom, StarbarX, StarbarY,
						Starbar_width, Starbar_height, Nosbar_width, Nosbar_height, nos_bar_addr, nos_bar_offset, NosbarX, NosbarY,
						winX, winY, jetX, jetY, Jet_width, Jet_height, trackX1, trackX2, trackY, Track_width, Track_height, invbar_addr,
						invbar_offset, InvbarX, InvbarY, Invbar_width, Invbar_height;
	 int unsigned carDistX, carDistY, objDistX [8], objDistY [8], expDistX, expDistY, carXchange, carYchange,
						stripeDistX [60], stripeDistY [60], loseDistX, loseDistY, hpDistX, hpDistY, starDistX, starDistY,
						starbarDistX, starbarDistY, nosbarDistX, nosbarDistY, winDistX, winDistY, jetDistX, jetDistY,
						trackDistX1, trackDistX2, trackDistY, copDistX, copDistY, invbarDistX, invbarDistY;
						
	 assign menuLive = lost || won;
	 
	 rom_car1 rom0 (.read_address (car_addr),
								.Clk (Clk),
								.data_out (car1_data)
								);
	
	 rom_car2 rom1 (.read_address (car_addr),
								.Clk (Clk),
								.data_out (car2_data)
								);
	
	 rom_rock rom3 (.read_address (obj_addr[0]),
								.Clk (Clk),
								.data_out (obj_data[0])
						);
						
	 rom_tree rom4 (.read_address (obj_addr[1]),
								.Clk (Clk),
								.data_out (obj_data[1])
						);
						
	 rom_barrel rom5 (.read_address (obj_addr[2]),
								.Clk (Clk),
								.data_out (obj_data[2])
							);
								
	 rom_exp rom6 (.read_address (exp_addr),
									.Clk (Clk),
									.data_out (exp_data)
								);
								
	 rom_lose rom7 (.read_address (lose_addr),
									.Clk (Clk),
									.data_out(lose_data)
								);
								
	 rom_win rom8 (.read_address (win_addr),
									.Clk (Clk),
									.data_out(win_data)
								);
								
	 rom_hp rom9 (.read_address (hp_addr),
									.Clk (Clk),
									.data_out(hp_data)
								);
								
	 rom_star rom10 (.read_address (star_addr),
								.Clk (Clk),
								.data_out (star_data)
								);
								
	 rom_star_bar rom11 (.read_address (star_bar_addr),
								.Clk (Clk),
								.data_out (star_bar_data)
								);
								
	 rom_nos_bar rom12 (.read_address (nos_bar_addr),
								.Clk (Clk),
								.data_out (nos_bar_data)
								);
								
	 rom_nos rom13 (.read_address (obj_addr[3]),
						 .Clk (Clk),
						 .data_out (obj_data[3])
						 );
	
	 rom_life rom14 (.read_address (obj_addr[4]),
						 .Clk (Clk),
						 .data_out (obj_data[4])
						 );
						 
	 rom_jet rom15 (.read_address (jet_addr),
						.Clk (Clk),
						.data_out (jet_data)
						);
						
	 rom_cone rom16 (.read_address (obj_addr[5]),
						.Clk (Clk),
						.data_out (obj_data[5])
						);
						
	 rom_oil rom17 (.read_address (obj_addr[6]),
						.Clk (Clk),
						.data_out (obj_data[6])
						);
						
	 rom_track rom18 (.read_address (track_addr),
						.Clk (Clk),
						.data_out (track_data)
						);
						
	 rom_cop rom19 (.read_address (cop_addr),
						.Clk (Clk),
						.data_out (cop_data)
						);
						
	 rom_shield rom20 (.read_address (obj_addr[7]),
						.Clk (Clk),
						.data_out (obj_data[7])
						);
						
	 rom_inv_bar rom21 (.read_address (invbar_addr),
						.Clk (Clk),
						.data_out (invbar_data)
						);
	  
    always_ff @ (posedge Reset or posedge Clk)
    begin:stuff_on_proc	

		if (Reset)
		begin
			col_on <= 1'b0;
			damage <= 3'b000;
			trshdObjs <= 8'b00000000;
			exp_addr <= 11'b0;
			replay <= 1'b0;
			lose_addr <= 17'b0;
			lost <= 1'b0;
			win_addr <= 15'b0;
			won <= 1'b0;
			stars <= 2'b00;
			collect <= 1'b0;
			explode <= 1'b0;
			nosLoadedOut <= 1'b0;
			oilCount <= 32'd100000000;
			sirenCount <= 32'd10000000;
			invCount <= 32'd400000000;
			noShift <= 1'b0;
			siren <= 1'b0;
			inv <= 1'b0;
			car <= 1'b0;
			switch <= 1'b0;
		end
		else
		begin
			carLeft <= CarX;  //car
			carRight <= CarX + Car_width;
			carTop <= CarY;
			carBottom = CarY + Car_height;
						
			carDistX <= DrawX - CarX;
			carDistY <= DrawY - CarY;
	 
			car_on <= 1'b0;
			car_offset <= 16'b0;
			car_addr <= 16'b0;
			
			copDistX <= DrawX - CopX; //cop
			copDistY <= DrawY - CopY;
			cop_on <= 1'b0;
			cop_offset <= 15'b0;
			cop_addr <= 15'b0;
			
			for (int i = 0; i < 8; i++) //objects
			begin
			objLeft[i] <= ObjX[i];
		   objRight[i] <= ObjX[i] + Obj_width[i];
			objTop[i] = ObjY[i];
			objBottom[i] = ObjY[i] + Obj_height[i];
			
			objDistX[i] <= DrawX - ObjX[i];
			objDistY[i] <= DrawY - ObjY[i];
			
			obj_on[i] <= 1'b0;		
		   obj_addr[i] <= 0;	
			end
			
			expDistX <= DrawX - ExpX; //explosion
			expDistY <= DrawY - ExpY; 
			Exp_width = 64;
			Exp_height = 64;
			carXchange = CarX - logCarX;
			carYchange = CarY - logCarY;
			exp_on <= 1'b0;
			
			for (int i = 0; i < 60; i++) //lane stripes
			begin
			stripeDistX[i] <= DrawX - StripeX[i];
			stripeDistY[i] <= DrawY - StripeY[i];
			
			lane_on <= 1'b0;
			end
			
			loseDistX <= DrawX - loseX; //lose menu
			loseDistY <= DrawY - loseY;
			Menu_width <= 150;
			Menu_height <= 169;
			loseX <= 320 - (Menu_width>>1); // /2
			loseY <= 240 - (Menu_height>>1); // /2
			lose_on <= 1'b0;
			
			winDistX <= DrawX - winX; //win menu
			winDistY <= DrawY - winY;
			winX <= 320 - (Menu_width>>1);
			winY <= 240 - (Menu_height>>1);
			win_on <= 1'b0;
			
			hpDistX <= DrawX - hpX; //hp bar
			hpDistY <= DrawY - hpY;
			Hp_width <= 128;
			Hp_height <= 24;
			hpX <= 0;
			hpY <= 0;
			hp_on <= 1'b0;
			hp_offset <= 15'b0;
			hp_addr <= 15'b0;
			
			starDistX <= DrawX - StarX; //star
			starDistY <= DrawY - StarY;
			star_on <= 1'b0;
			starLeft <= StarX;
		   starRight <= StarX + Star_width;
			starTop <= StarY;
			starBottom <= StarY + Star_height;
			
			starbarDistX <= DrawX - StarbarX; //star bar
			starbarDistY <= DrawY - StarbarY;
			starbar_on <= 0;
			Starbar_width <= 64;
			Starbar_height <= 24;
			StarbarX <= Hp_width;
			StarbarY <= 0;
			star_bar_offset <= 15'b0;
			star_bar_addr <= 15'b0;
			
			nosbarDistX <= DrawX - NosbarX; //nos bar
			nosbarDistY <= DrawY - NosbarY;
			nosbar_on <= 0;
			Nosbar_width <= 25;
			Nosbar_height <= 24;
			NosbarX <= Hp_width + Starbar_width;
			NosbarY <= 0;
			nos_bar_offset <= 11'b0;
			nos_bar_addr <= 11'b0;
			
			invbarDistX <= DrawX - InvbarX; //invincibility status bar
			invbarDistY <= DrawY - InvbarY;
			invbar_on <= 0;
			Invbar_width <= 25;
			Invbar_height <= 24;
			InvbarX <= NosbarX + Invbar_width;
			InvbarY <= 0;
			invbar_offset <= 10'b0;
			invbar_addr <= 10'b0;
			
			jetX <= carLeft + 10; //nos jet
			jetY <= carBottom - 10;
			jetDistX <= DrawX - jetX;
			jetDistY <= DrawY - jetY;
			jet_on <= 0;
			Jet_width <= 16;
			Jet_height <= 30;
			jet_addr <= 9'b0;
			
			trackX1 <= carLeft + 10; //tire tracks
			trackX2 <= carRight - 10 - Track_width;
			trackY <= carBottom - 5;
			trackDistX1 <= DrawX - trackX1;
			trackDistX2 <= DrawX - trackX2;
			trackDistY <= DrawY - trackY;
			track_on <= 0;
			Track_width <= 14;
			Track_height <= 47;
			track_addr <= 10'b0;
			
			
			if (~nosLoadedIn) //clear nos if used
			begin
				nosLoadedOut <= 1'b0;
			end
	 
			//collision detection
				if(carRight>=objLeft[0] && carLeft<=objRight[0] && carBottom>=objTop[0] && carTop<=objBottom[0])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
						col_on <= 1'b1;
						trshdObjs <= 8'b00000001;
						if (damage >= 3'b100) //OUT OF LIVES -> GAME OVER
							lost <= 1'b1;
						else if (~inv)
							damage <= damage + 3'b001;
						end
					end
				else if (carRight>=objLeft[1] && carLeft<=objRight[1] && carBottom>=objTop[1] && carTop<=objBottom[1])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
						col_on <= 1'b1;
						trshdObjs <= 8'b00000010;
						if (damage >= 3'b100) //OUT OF LIVES -> GAME OVER
							lost <= 1'b1;
						else if (~inv)
							damage <= damage + 3'b001;
						end
					end
				else if (carRight>=objLeft[2] && carLeft<=objRight[2] && carBottom>=objTop[2] && carTop<=objBottom[2])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
						col_on <= 1'b1;
						explode <= 1'b1;
						logCarX <= CarX;
						logCarY <= CarY;
						ExpX <= objLeft[2] - (Exp_width>>1) + (Obj_width[2]>>1);  // /2
						ExpY <= objTop[2] - (Exp_height>>1) + (Obj_height[2]>>1); // /2
						trshdObjs <= 8'b00000100;
						if (damage >= 3'b011) //OUT OF LIVES -> GAME OVER
							lost <= 1'b1;
						else if (~inv)
							damage <= damage + 3'b010; //barrel explosions do double damage
						end
					end
				else if (carRight>=objLeft[3] && carLeft<=objRight[3] && carBottom>=objTop[3] && carTop<=objBottom[3])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
						col_on <= 1'b1;
						trshdObjs <= 8'b00001000;
						if (~nosLoadedOut) //load nos if empty
							nosLoadedOut <= 1'b1;
						end
					end
				else if (carRight>=objLeft[4] && carLeft<=objRight[4] && carBottom>=objTop[4] && carTop<=objBottom[4])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
						col_on <= 1'b1;
						trshdObjs <= 8'b00010000;
						if (damage > 3'b000)
							damage <= damage - 1'b1; //gain a life
						end
					end
				else if (carRight>=objLeft[5] && carLeft<=objRight[5] && carBottom>=objTop[5] && carTop<=objBottom[5])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
						col_on <= 1'b1;
						trshdObjs <= 8'b00100000;
						if (damage >= 3'b100) //OUT OF LIVES -> GAME OVER
							lost <= 1'b1;
						else if (~inv)
							damage <= damage + 3'b001;
						end
					end
				else if (carRight>=objLeft[6] && carLeft<=objRight[6] && carBottom>=objTop[6] && carTop<=objBottom[6])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
							col_on <= 1'b1;
							trshdObjs <= 8'b01000000;
							noShift <= 1'b1;
						end
					end
				else if (carRight>=objLeft[7] && carLeft<=objRight[7] && carBottom>=objTop[7] && carTop<=objBottom[7])
					begin
						if (~col_on && trshdObjs==8'b00000000 && ~menuLive)
						begin
							col_on <= 1'b1;
							trshdObjs <= 8'b10000000;
							inv <= 1'b1;
						end
					end
				else if (carRight>=starLeft && carLeft<=starRight && carBottom>=starTop && carTop<=starBottom && starLive && ~menuLive)
					begin
						if (~collect && ~menuLive)
						begin
						collect <= 1'b1;
						stars <= stars + 1'b1;
						end
					end
				else
					begin
					collect <= 1'b0;
					col_on <= 1'b0;
					trshdObjs <= 8'b00000000;
					end
					
		  if (explode && (carXchange>=48 || carYchange>=48)) //let fire burn out
		  begin
				explode <= 1'b0;
		  end
		  
		  	if (noShift) //let oil effect wear off
			begin
				if (oilCount > 0)
				begin
					noShift <= 1'b1;
					oilCount <= oilCount - 1'b1;
				end
				else
				begin
					noShift <= 1'b0;
					oilCount <= 32'd100000000;
					end
				end
		  
		  if (sirenCount > 0) //animate siren lights	
				sirenCount <= sirenCount - 1'b1;
		  else
		  begin
				siren <= ~siren;
				sirenCount <= 32'd10000000;
		  end
		  
		  if (invCount > 0) //let invincibility wear off
				invCount <= invCount - 1'b1;
		  else
		  begin
				inv <= 1'b0;
				invCount <= 32'd400000000;
		  end
			
		  if (stars >= 2'b11) //win
			won <= 1'b1;
			
		  if (expDistX <= Exp_width && expDistY <= Exp_height) //explosion
		  begin
				exp_on <= 1'b1;
				exp_addr <= (expDistY*Exp_width) + expDistX;
		  end
			
		  if (loseDistX <= Menu_width && loseDistY <= Menu_height) //lose menu
		  begin
				lose_on <= 1'b1;
				lose_offset <= (loseDistY*Menu_width) + loseDistX;
				lose_addr <= stars*17'd25350 + lose_offset;
		  end
		  
		  if (winDistX <= Menu_width && winDistY <= Menu_height) //win menu
		  begin
				win_on <= 1'b1;
				win_addr <= (winDistY*Menu_width) + winDistX;
		  end
		  
		  if (jetDistX <= Jet_width && jetDistY <= Jet_height) //nos jet
		  begin
				jet_on <= 1'b1;
				jet_addr <= (jetDistY*Jet_width) + jetDistX;
		  end
			
		  if (trackDistX1 <= Track_width && trackDistY <= Track_height) //tire tracks
		  begin
				track_on <= 1'b1;
				track_addr <= (trackDistY*Track_width) + trackDistX1;
		  end
		  else if (trackDistX2 <= Track_width && trackDistY <= Track_height)
		  begin
				track_on <= 1'b1;
				track_addr <= (trackDistY*Track_width) + trackDistX2;
		  end
			
		  if (hpDistX <= Hp_width && hpDistY <= Hp_height) //hp bar
		  begin
				hp_on <= 1'b1;
				hp_offset <= (hpDistY*Hp_width) + hpDistX;
				if (menuLive)
					hp_addr <= 5*15'd3072 + hp_offset;
				else
					hp_addr <= damage*15'd3072 + hp_offset;
		  end
		  else if (starbarDistX <= Starbar_width && starbarDistY <= Starbar_height) //star bar
		  begin
			  starbar_on <= 1'b1;
			  star_bar_offset <= (starbarDistY*Starbar_width) + starbarDistX;
			  star_bar_addr <= stars*13'd1536 + star_bar_offset;
		  end
		  else if (nosbarDistX <= Nosbar_width && nosbarDistY <= Nosbar_height) //nos bar
		  begin
			  nosbar_on <= 1'b1;
			  nos_bar_offset <= (nosbarDistY*Nosbar_width) + nosbarDistX;
			  nos_bar_addr <= nosLoadedOut*11'd600 + nos_bar_offset;
		  end
		  else if (invbarDistX <= Invbar_width && invbarDistY <= Invbar_height) //invincibility status bar
		  begin
			  invbar_on <= 1'b1;
			  invbar_offset <= (invbarDistY*Invbar_width) + invbarDistX;
			  invbar_addr <= inv*10'd600 + invbar_offset;
		  end
		  else if (starDistX <= Star_width && starDistY <= Star_height && starLive && ~menuLive) //star
		  begin
				star_on <= 1'b1;
				star_addr <= (starDistY*Star_width) + starDistX;
		  end
        else if (carDistX <= Car_width && carDistY <= Car_height) //car
		  begin 
            car_on <= 1'b1;
				car_offset <= (carDistY*Car_width) + carDistX;
				car_addr <= damage*16'd8320 + car_offset;
		  end
		  else if (copDistX <= Cop_width && copDistY <= Cop_height) //cop
		  begin
				cop_on <= 1'b1;
				cop_offset <= (copDistY*Cop_width) + copDistX;
				cop_addr <= siren*15'd8704 + cop_offset;
		  end
		  else if (objDistX[0] <= Obj_width[0] && objDistY[0] <= Obj_height[0]) //rock
		  begin
				obj_on[0] <= 1'b1;
				obj_addr[0] <= (objDistY[0]*Obj_width[0]) + objDistX[0];
		  end		  
		  else if (objDistX[1] <= Obj_width[1] && objDistY[1] <= Obj_height[1]) //tree
		  begin
				obj_on[1] <= 1'b1;
				obj_addr[1] <= (objDistY[1]*Obj_width[1]) + objDistX[1];
		  end
		  else if (objDistX[2] <= Obj_width[2] && objDistY[2] <= Obj_height[2]) //barrel
		  begin
				obj_on[2] <= 1'b1;
				obj_addr[2] <= (objDistY[2]*Obj_width[2]) + objDistX[2];
		  end
		  else if (objDistX[3] <= Obj_width[3] && objDistY[3] <= Obj_height[3]) //nos
		  begin
				obj_on[3] <= 1'b1;
				obj_addr[3] <= (objDistY[3]*Obj_width[3]) + objDistX[3];
		  end
		  else if (objDistX[4] <= Obj_width[4] && objDistY[4] <= Obj_height[4]) //life
		  begin
				obj_on[4] <= 1'b1;
				obj_addr[4] <= (objDistY[4]*Obj_width[4]) + objDistX[4];
		  end
		  else if (objDistX[5] <= Obj_width[5] && objDistY[5] <= Obj_height[5]) //cone
		  begin
				obj_on[5] <= 1'b1;
				obj_addr[5] <= (objDistY[5]*Obj_width[5]) + objDistX[5];
		  end
		  else if (objDistX[6] <= Obj_width[6] && objDistY[6] <= Obj_height[6]) //oil
		  begin
				obj_on[6] <= 1'b1;
				obj_addr[6] <= (objDistY[6]*Obj_width[6]) + objDistX[6];
		  end
		  else if (objDistX[7] <= Obj_width[7] && objDistY[7] <= Obj_height[7]) //shield
		  begin
				obj_on[7] <= 1'b1;
				obj_addr[7] <= (objDistY[7]*Obj_width[7]) + objDistX[7];
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
		  
		  if (keycode==8'd21 && menuLive) //R
			   replay <= 1'b1;
		  else if (keycode==8'd57) //caps lock
		  begin
			if (~switch)
			begin
				car <= ~car; //switch car
				switch <= 1'b1;
			end
		  end
		  else
				switch <= 1'b0;
				
		  if (car)
			car_data <= car2_data; //yellow car
		  else
			car_data <= car1_data; //red car
		end
     end 
       
    always_comb
    begin:RGB_Display
		  if (~blank) //blank signal
		  begin
				Red = 0;
				Green = 0;
				Blue = 0;
		  end
		  else if (hp_on) //hp bar
		  begin
				Red = hp_data[23:16];
				Green = hp_data[15:8];
				Blue = hp_data[7:0];
		  end
		  else if (starbar_on) //star bar
		  begin
				Red = star_bar_data[23:16];
				Green = star_bar_data[15:8];
				Blue = star_bar_data[7:0];
		  end
		  else if (nosbar_on) //nos bar
		  begin
				Red = nos_bar_data[23:16];
				Green = nos_bar_data[15:8];
				Blue = nos_bar_data[7:0];
		  end
		  else if (invbar_on) //invincibility status bar
		  begin
				Red = invbar_data[23:16];
				Green = invbar_data[15:8];
				Blue = invbar_data[7:0];
		  end
		  else if (lost && lose_on && lose_data!=24'hffffff) //lose menu
		  begin
				Red = lose_data[23:16];
				Green = lose_data[15:8];
				Blue = lose_data[7:0];
		  end
		  else if (won && win_on && win_data!=24'hffffff) //win menu
		  begin
				Red = win_data[23:16];
				Green = win_data[15:8];
				Blue = win_data[7:0];
		  end
		  else if (explode && exp_on && exp_data!=24'hffffff) //explosion
		  begin
		      Red = exp_data[23:16];
            Green = exp_data[15:8];
            Blue = exp_data[7:0];
		  end
        else if ((car_on) && (car_data != 24'hffffff)) //car
        begin 
            Red = car_data[23:16];
            Green = car_data[15:8];
            Blue = car_data[7:0];
        end
		  else if (cop_on && cop_data!=24'h00ff00) //cop
		  begin
			   Red = cop_data[23:16];
            Green = cop_data[15:8];
            Blue = cop_data[7:0];
		  end
		  else if (nosActive && jet_on && jet_data != 24'hffffff) //nos jet
        begin 
            Red = jet_data[23:16];
            Green = jet_data[15:8];
            Blue = jet_data[7:0];
        end
		  else if (star_on && star_data!=24'hffffff) //star
		  begin
			   Red = star_data[23:16];
            Green = star_data[15:8];
            Blue = star_data[7:0];
		  end
		  else if ((obj_on[0]) && (obj_data[0] != 24'hffffff)) //rock
		  begin
            Red = obj_data[0][23:16];
            Green = obj_data[0][15:8];
            Blue = obj_data[0][7:0];
		  end
		  else if ((obj_on[1]) && (obj_data[1] != 24'hffffff)) //tree
		  begin
            Red = obj_data[1][23:16];
            Green = obj_data[1][15:8];
            Blue = obj_data[1][7:0];
		  end
		  else if ((obj_on[2]) && (obj_data[2] != 24'hffffff)) //barrel
		  begin
            Red = obj_data[2][23:16];
            Green = obj_data[2][15:8];
            Blue = obj_data[2][7:0];
		  end
		  else if ((obj_on[3]) && (obj_data[3] != 24'hff0000)) //nos
		  begin
				Red = obj_data[3][23:16];
            Green = obj_data[3][15:8];
            Blue = obj_data[3][7:0];
		  end
		  else if (noShift && track_on && track_data != 24'hffffff) //tire tracks
		  begin
				Red = track_data[23:16];
            Green = track_data[15:8];
            Blue = track_data[7:0];
		  end
		  else if ((obj_on[4]) && (obj_data[4] != 24'hffffff)) //life
		  begin
				Red = obj_data[4][23:16];
            Green = obj_data[4][15:8];
            Blue = obj_data[4][7:0];
		  end
		  else if ((obj_on[5]) && (obj_data[5] != 24'h00ff00)) //cone
		  begin
				Red = obj_data[5][23:16];
            Green = obj_data[5][15:8];
            Blue = obj_data[5][7:0];
		  end
		  else if ((obj_on[6]) && (obj_data[6] != 24'hffffff)) //oil
		  begin
				Red = obj_data[6][23:16];
            Green = obj_data[6][15:8];
            Blue = obj_data[6][7:0];
		  end
		  else if ((obj_on[7]) && (obj_data[7] != 24'hffffff)) //shield
		  begin
				Red = obj_data[7][23:16];
            Green = obj_data[7][15:8];
            Blue = obj_data[7][7:0];
		  end
		  else if (lane_on) //lane stripes
		  begin
				Red = 8'hff;
				Green = 8'he9;
				Blue = 8'h33;
		  end
        else //road
        begin
            Red = 8'h40; 
            Green = 8'h40;
            Blue = 8'h40;
        end
    end 
    
endmodule
