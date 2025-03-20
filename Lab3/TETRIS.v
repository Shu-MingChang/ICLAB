/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TETRIS
// FILE NAME: TETRIS.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TETRIS
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module TETRIS (
	//INPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//OUTPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[2:0]	tetrominoes;
input		[2:0]	position;
output reg			tetris_valid, score_valid, fail;
output reg	[3:0]	score;
output reg 	[71:0]	tetris;


//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [5:0] temp_tetris [26:0];
reg [5:0] tero_current [15:0];
reg [2:0] cs, ns;
reg [4:0] counter;
reg [1:0] cout, nout;
reg [5:0] lowest_row;
reg [5:0] first_allone;
reg [2:0] tet_one, pos_one;
reg [3:0] score_reg;

reg [2:0] shift_stage;

localparam IDEAL = 3'b000;
localparam WAIT = 3'b001;
localparam FIND_Low_row = 3'b010;
localparam PUT_TETRIS = 3'b011;
localparam FIND_ALLONE = 3'b100;
localparam SHIFT = 3'b101;
localparam EE = 3'b110;
localparam OUT = 3'b111;
integer i;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        tet_one <= 0;
    end
	else if (in_valid == 1)begin
		tet_one <= tetrominoes;
	end
 	else tet_one <= tet_one;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        pos_one <= 0;
    end
	else if (in_valid == 1)begin
		case (position)
			3'd0: pos_one <= 3'd5;
			3'd1: pos_one <= 3'd4;
			3'd2: pos_one <= 3'd3;
			3'd3: pos_one <= 3'd2;
			3'd4: pos_one <= 3'd1;
			3'd5: pos_one <= 3'd0;
		endcase

	end
 	else pos_one <= pos_one;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) counter <= 0;
	else if (cs == FIND_Low_row) counter <= counter+1;
	else if ((cs == OUT && (temp_tetris[12] != 0 || temp_tetris[13] != 0 || temp_tetris[14] != 0 || temp_tetris[15] != 0 || counter == 16))) counter <= 0;
    else  counter <= counter;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        cs <= IDEAL;
    end
	else if (in_valid == 1) begin
		cs <= FIND_Low_row;
	end
    else begin
        cs <= ns;
    end
end


always @(*) begin
	case (cs)
		3'd0: begin
			ns = WAIT;
		end
		3'd1: begin
			ns = cs;
		end
		3'd2: begin
			ns = PUT_TETRIS;
		end
		3'd3: begin
			ns = FIND_ALLONE;
		end
		3'd4: begin
			ns = SHIFT;
		end
		3'd5: begin
			ns = EE;
		end
		3'd6: begin
			ns = OUT;
		end
		3'd7: begin
			ns = WAIT;
		end
		default:ns = IDEAL;

	endcase
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		lowest_row <= 0;
	end
	else if (cs == FIND_Low_row) begin
		case (tet_one)
			3'd0: 
    			begin
    	    		if (temp_tetris[11][pos_one] == 1 || temp_tetris[11][pos_one - 1] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one] == 1 || temp_tetris[10][pos_one - 1] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one] == 1 || temp_tetris[9][pos_one - 1] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one] == 1 || temp_tetris[8][pos_one - 1] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one] == 1 || temp_tetris[7][pos_one - 1] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one] == 1 || temp_tetris[6][pos_one - 1] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one] == 1 || temp_tetris[5][pos_one - 1] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one] == 1 || temp_tetris[4][pos_one - 1] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one] == 1 || temp_tetris[3][pos_one - 1] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one] == 1 || temp_tetris[2][pos_one - 1] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one] == 1 || temp_tetris[1][pos_one - 1] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one] == 1 || temp_tetris[0][pos_one - 1] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
			3'd1: 
    			begin
    	    		if (temp_tetris[11][pos_one] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
			3'd2: 
    			begin					
    	    		if (temp_tetris[11][pos_one] == 1 || temp_tetris[11][pos_one - 1] == 1 || temp_tetris[11][pos_one - 2] == 1 || temp_tetris[11][pos_one - 3] == 1) lowest_row <= 12;
					else if (temp_tetris[10][pos_one] == 1 || temp_tetris[10][pos_one - 1] == 1 || temp_tetris[10][pos_one - 2] == 1 || temp_tetris[10][pos_one - 3] == 1) lowest_row <= 11;
					else if (temp_tetris[9][pos_one] == 1 || temp_tetris[9][pos_one - 1] == 1 || temp_tetris[9][pos_one - 2] == 1 || temp_tetris[9][pos_one - 3] == 1) lowest_row <= 10;
					else if (temp_tetris[8][pos_one] == 1 || temp_tetris[8][pos_one - 1] == 1 || temp_tetris[8][pos_one - 2] == 1 || temp_tetris[8][pos_one - 3] == 1) lowest_row <= 9;
					else if (temp_tetris[7][pos_one] == 1 || temp_tetris[7][pos_one - 1] == 1 || temp_tetris[7][pos_one - 2] == 1 || temp_tetris[7][pos_one - 3] == 1) lowest_row <= 8;
					else if (temp_tetris[6][pos_one] == 1 || temp_tetris[6][pos_one - 1] == 1 || temp_tetris[6][pos_one - 2] == 1 || temp_tetris[6][pos_one - 3] == 1) lowest_row <= 7;
					else if (temp_tetris[5][pos_one] == 1 || temp_tetris[5][pos_one - 1] == 1 || temp_tetris[5][pos_one - 2] == 1 || temp_tetris[5][pos_one - 3] == 1) lowest_row <= 6;
					else if (temp_tetris[4][pos_one] == 1 || temp_tetris[4][pos_one - 1] == 1 || temp_tetris[4][pos_one - 2] == 1 || temp_tetris[4][pos_one - 3] == 1) lowest_row <= 5;
					else if (temp_tetris[3][pos_one] == 1 || temp_tetris[3][pos_one - 1] == 1 || temp_tetris[3][pos_one - 2] == 1 || temp_tetris[3][pos_one - 3] == 1) lowest_row <= 4;
					else if (temp_tetris[2][pos_one] == 1 || temp_tetris[2][pos_one - 1] == 1 || temp_tetris[2][pos_one - 2] == 1 || temp_tetris[2][pos_one - 3] == 1) lowest_row <= 3;
					else if (temp_tetris[1][pos_one] == 1 || temp_tetris[1][pos_one - 1] == 1 || temp_tetris[1][pos_one - 2] == 1 || temp_tetris[1][pos_one - 3] == 1) lowest_row <= 2;
					else if (temp_tetris[0][pos_one] == 1 || temp_tetris[0][pos_one - 1] == 1 || temp_tetris[0][pos_one - 2] == 1 || temp_tetris[0][pos_one - 3] == 1) lowest_row <= 1;
					else lowest_row <= 0;
    			end
			3'd3: 
    			begin
    	    		if (temp_tetris[11][pos_one - 1] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one - 1] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one - 1] == 1 || temp_tetris[11][pos_one] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one - 1] == 1 || temp_tetris[10][pos_one] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one - 1] == 1 || temp_tetris[9][pos_one] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one - 1] == 1 || temp_tetris[8][pos_one] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one - 1] == 1 || temp_tetris[7][pos_one] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one - 1] == 1 || temp_tetris[6][pos_one] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one - 1] == 1 || temp_tetris[5][pos_one] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one - 1] == 1 || temp_tetris[4][pos_one] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one - 1] == 1 || temp_tetris[3][pos_one] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one - 1] == 1 || temp_tetris[2][pos_one] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
			3'd4: 
    			begin
    	    		if (temp_tetris[11][pos_one] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one] == 1 || temp_tetris[11][pos_one - 1] == 1 || temp_tetris[11][pos_one - 2] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one] == 1 || temp_tetris[10][pos_one - 1] == 1 || temp_tetris[10][pos_one - 2] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one] == 1 || temp_tetris[9][pos_one - 1] == 1 || temp_tetris[9][pos_one - 2] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one] == 1 || temp_tetris[8][pos_one - 1] == 1 || temp_tetris[8][pos_one - 2] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one] == 1 || temp_tetris[7][pos_one - 1] == 1 || temp_tetris[7][pos_one - 2] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one] == 1 || temp_tetris[6][pos_one - 1] == 1 || temp_tetris[6][pos_one - 2] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one] == 1 || temp_tetris[5][pos_one - 1] == 1 || temp_tetris[5][pos_one - 2] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one] == 1 || temp_tetris[4][pos_one - 1] == 1 || temp_tetris[4][pos_one - 2] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one] == 1 || temp_tetris[3][pos_one - 1] == 1 || temp_tetris[3][pos_one - 2] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one] == 1 || temp_tetris[2][pos_one - 1] == 1 || temp_tetris[2][pos_one - 2] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one] == 1 || temp_tetris[1][pos_one - 1] == 1 || temp_tetris[1][pos_one - 2] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
			3'd5: 
    			begin
    	    		if (temp_tetris[11][pos_one] == 1 || temp_tetris[11][pos_one - 1] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one] == 1 || temp_tetris[10][pos_one - 1] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one] == 1 || temp_tetris[9][pos_one - 1] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one] == 1 || temp_tetris[8][pos_one - 1] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one] == 1 || temp_tetris[7][pos_one - 1] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one] == 1 || temp_tetris[6][pos_one - 1] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one] == 1 || temp_tetris[5][pos_one - 1] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one] == 1 || temp_tetris[4][pos_one - 1] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one] == 1 || temp_tetris[3][pos_one - 1] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one] == 1 || temp_tetris[2][pos_one - 1] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one] == 1 || temp_tetris[1][pos_one - 1] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one] == 1 || temp_tetris[0][pos_one - 1] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
			3'd6: 
    			begin
    	    		if (temp_tetris[11][pos_one - 1] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one - 1] == 1 || temp_tetris[11][pos_one] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one - 1] == 1 || temp_tetris[10][pos_one] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one - 1] == 1 || temp_tetris[9][pos_one] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one - 1] == 1 || temp_tetris[8][pos_one] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one - 1] == 1 || temp_tetris[7][pos_one] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one - 1] == 1 || temp_tetris[6][pos_one] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one - 1] == 1 || temp_tetris[5][pos_one] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one - 1] == 1 || temp_tetris[4][pos_one] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one - 1] == 1 || temp_tetris[3][pos_one] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one - 1] == 1 || temp_tetris[2][pos_one] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one - 1] == 1 || temp_tetris[1][pos_one] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
			3'd7: 
    			begin
    	    		if (temp_tetris[11][pos_one] == 1 || temp_tetris[11][pos_one - 1] == 1) lowest_row <= 12;
        			else if (temp_tetris[10][pos_one] == 1 || temp_tetris[10][pos_one - 1] == 1 || temp_tetris[11][pos_one - 2] == 1) lowest_row <= 11;
	        		else if (temp_tetris[9][pos_one] == 1 || temp_tetris[9][pos_one - 1] == 1 || temp_tetris[10][pos_one - 2] == 1) lowest_row <= 10;
    	    		else if (temp_tetris[8][pos_one] == 1 || temp_tetris[8][pos_one - 1] == 1 || temp_tetris[9][pos_one - 2] == 1) lowest_row <= 9;
        			else if (temp_tetris[7][pos_one] == 1 || temp_tetris[7][pos_one - 1] == 1 || temp_tetris[8][pos_one - 2] == 1) lowest_row <= 8;
	        		else if (temp_tetris[6][pos_one] == 1 || temp_tetris[6][pos_one - 1] == 1 || temp_tetris[7][pos_one - 2] == 1) lowest_row <= 7;
    	    		else if (temp_tetris[5][pos_one] == 1 || temp_tetris[5][pos_one - 1] == 1 || temp_tetris[6][pos_one - 2] == 1) lowest_row <= 6;
	        		else if (temp_tetris[4][pos_one] == 1 || temp_tetris[4][pos_one - 1] == 1 || temp_tetris[5][pos_one - 2] == 1) lowest_row <= 5;
    				else if (temp_tetris[3][pos_one] == 1 || temp_tetris[3][pos_one - 1] == 1 || temp_tetris[4][pos_one - 2] == 1) lowest_row <= 4;
    				else if (temp_tetris[2][pos_one] == 1 || temp_tetris[2][pos_one - 1] == 1 || temp_tetris[3][pos_one - 2] == 1) lowest_row <= 3;
	    			else if (temp_tetris[1][pos_one] == 1 || temp_tetris[1][pos_one - 1] == 1 || temp_tetris[2][pos_one - 2] == 1) lowest_row <= 2;
    				else if (temp_tetris[0][pos_one] == 1 || temp_tetris[0][pos_one - 1] == 1 || temp_tetris[1][pos_one - 2] == 1) lowest_row <= 1;
    				else lowest_row <= 0; 
    			end
		endcase
	end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		temp_tetris[0] <= 6'b0;
		temp_tetris[1] <= 6'b0;
		temp_tetris[2] <= 6'b0;
		temp_tetris[3] <= 6'b0;
		temp_tetris[4] <= 6'b0;
		temp_tetris[5] <= 6'b0;
		temp_tetris[6] <= 6'b0;
		temp_tetris[7] <= 6'b0;
		temp_tetris[8] <= 6'b0;
		temp_tetris[9] <= 6'b0;
		temp_tetris[10] <= 6'b0;
		temp_tetris[11] <= 6'b0;
		temp_tetris[12] <= 6'b0;
		temp_tetris[13] <= 6'b0;
		temp_tetris[14] <= 6'b0;
		temp_tetris[15] <= 6'b0;
		temp_tetris[16] <= 6'b0;
		temp_tetris[17] <= 6'b0;
		temp_tetris[18] <= 6'b0;
		temp_tetris[19] <= 6'b0;
		temp_tetris[20] <= 6'b0;
		temp_tetris[21] <= 6'b0;
		temp_tetris[22] <= 6'b0;
		temp_tetris[23] <= 6'b0;
		temp_tetris[24] <= 6'b0;
		temp_tetris[25] <= 6'b0;
		temp_tetris[26] <= 6'b0;
    end
	
	else if (cs == PUT_TETRIS) begin
	case (tet_one)
		3'd0: begin
			temp_tetris[lowest_row + 1][pos_one - 1] <= 1;
			temp_tetris[lowest_row + 1][pos_one] <= 1;
			temp_tetris[lowest_row][pos_one - 1] <= 1;
			temp_tetris[lowest_row][pos_one] <= 1;
		end
		3'd1: begin
			temp_tetris[lowest_row + 3][pos_one] <= 1;
			temp_tetris[lowest_row + 2][pos_one] <= 1;
			temp_tetris[lowest_row + 1][pos_one] <= 1;
			temp_tetris[lowest_row][pos_one] <= 1;
		end
		3'd2: begin
			temp_tetris[lowest_row][pos_one - 3] <= 1;
			temp_tetris[lowest_row][pos_one - 2] <= 1;
			temp_tetris[lowest_row][pos_one - 1] <= 1;
			temp_tetris[lowest_row][pos_one] <= 1;
		end
		3'd3: begin
			temp_tetris[lowest_row + 2][pos_one] <= 1;
			temp_tetris[lowest_row + 2][pos_one - 1] <= 1;
			temp_tetris[lowest_row + 1][pos_one - 1] <= 1;
			temp_tetris[lowest_row][pos_one - 1] <= 1;
		end
		3'd4: begin
			temp_tetris[lowest_row + 1][pos_one - 2] <= 1;
			temp_tetris[lowest_row + 1][pos_one - 1] <= 1;
			temp_tetris[lowest_row + 1][pos_one] <= 1;
			temp_tetris[lowest_row][pos_one] <= 1;
		end
		3'd5: begin
			temp_tetris[lowest_row][pos_one - 1] <= 1;
			temp_tetris[lowest_row + 2][pos_one] <= 1;
			temp_tetris[lowest_row + 1][pos_one] <= 1;
			temp_tetris[lowest_row][pos_one] <= 1;
		end
		3'd6: begin
			temp_tetris[lowest_row + 2][pos_one] <= 1;
			temp_tetris[lowest_row + 1][pos_one] <= 1;
			temp_tetris[lowest_row + 1][pos_one - 1] <= 1;
			temp_tetris[lowest_row][pos_one - 1] <= 1;
		end
		3'd7: begin
			temp_tetris[lowest_row + 1][pos_one - 2] <= 1;
			temp_tetris[lowest_row + 1][pos_one - 1] <= 1;
			temp_tetris[lowest_row][pos_one - 1] <= 1;
			temp_tetris[lowest_row][pos_one] <= 1;
		end
	endcase
    end
	
	else if (cs == EE && first_allone != 12) begin
		case (shift_stage)
    3'b001: begin
        for (i = 0; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 4];
        end
    end

    3'b010: begin
        temp_tetris[first_allone] <= temp_tetris[first_allone + 1];
        for (i = 1; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 3];
        end
    end

    3'b011: begin
        temp_tetris[first_allone] <= temp_tetris[first_allone + 2];
        for (i = 1; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 3];
        end
    end

    3'b100: begin
        temp_tetris[first_allone] <= temp_tetris[first_allone + 3];
        for (i = 1; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 3];
        end
    end

    3'b101: begin
        temp_tetris[first_allone] <= temp_tetris[first_allone + 1];
        temp_tetris[first_allone + 1] <= temp_tetris[first_allone + 2];
        for (i = 2; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 2];
        end
    end

    3'b110: begin
        temp_tetris[first_allone] <= temp_tetris[first_allone + 1];
        for (i = 1; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 2];
        end
    end

    3'b111: begin
        for (i = 0; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 2];
        end
    end

    default: begin
        for (i = 0; i < 12; i = i + 1) begin
            temp_tetris[first_allone + i] <= temp_tetris[first_allone + i + 1];
        end
    end
endcase

	end

	else if (cs == OUT && (temp_tetris[12] != 0 || temp_tetris[13] != 0 || temp_tetris[14] != 0 || temp_tetris[15] != 0 || counter == 16)) begin
		temp_tetris[0] <= 6'b0;
		temp_tetris[1] <= 6'b0;
		temp_tetris[2] <= 6'b0;
		temp_tetris[3] <= 6'b0;
		temp_tetris[4] <= 6'b0;
		temp_tetris[5] <= 6'b0;
		temp_tetris[6] <= 6'b0;
		temp_tetris[7] <= 6'b0;
		temp_tetris[8] <= 6'b0;
		temp_tetris[9] <= 6'b0;
		temp_tetris[10] <= 6'b0;
		temp_tetris[11] <= 6'b0;
		temp_tetris[12] <= 6'b0;
		temp_tetris[13] <= 6'b0;
		temp_tetris[14] <= 6'b0;
		temp_tetris[15] <= 6'b0;
		temp_tetris[16] <= 6'b0;
		temp_tetris[17] <= 6'b0;
		temp_tetris[18] <= 6'b0;
		temp_tetris[19] <= 6'b0;
		temp_tetris[20] <= 6'b0;
		temp_tetris[21] <= 6'b0;
		temp_tetris[22] <= 6'b0;
		temp_tetris[23] <= 6'b0;
		temp_tetris[24] <= 6'b0;
		temp_tetris[25] <= 6'b0;
		temp_tetris[26] <= 6'b0;

	end	
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		score_reg <= 0;
	end
	else if (cs == SHIFT && first_allone != 12) begin
		if (temp_tetris[first_allone + 1] == 6'b111111 && temp_tetris[first_allone + 2] == 6'b111111 && temp_tetris[first_allone + 3] == 6'b111111 )begin
			score_reg <= score_reg + 4;
		end
		else if (temp_tetris[first_allone + 2] == 6'b111111 && temp_tetris[first_allone + 3] == 6'b111111 ) begin
			score_reg <=  score_reg + 3;
		end
		else if (temp_tetris[first_allone + 1] == 6'b111111 && temp_tetris[first_allone + 3] == 6'b111111 ) begin
			score_reg <=  score_reg + 3;
		end
		else if (temp_tetris[first_allone + 1] == 6'b111111 && temp_tetris[first_allone + 2] == 6'b111111 ) begin
			score_reg <=  score_reg + 3;
		end
		else if (temp_tetris[first_allone + 3] == 6'b111111) begin
			score_reg <=  score_reg + 2;
		end
		else if (temp_tetris[first_allone + 2] == 6'b111111) begin
			score_reg <=  score_reg + 2;
		end
		else if (temp_tetris[first_allone + 1] == 6'b111111) begin
			score_reg <=  score_reg + 2;
		end
		else begin
			score_reg <=  score_reg + 1;
		end
	end
	else if(cs == OUT && (temp_tetris[12] != 0 || temp_tetris[13] != 0 || temp_tetris[14] != 0 || temp_tetris[15] != 0 || counter == 16)) begin
		score_reg <= 0;
	end
	else begin
		score_reg <=  score_reg;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		shift_stage <= 0;
	end
	else if (cs == SHIFT && first_allone != 12) begin
		if (temp_tetris[first_allone + 1] == 6'b111111 && temp_tetris[first_allone + 2] == 6'b111111 && temp_tetris[first_allone + 3] == 6'b111111 )begin
			shift_stage <= 3'b001;
		end
		else if (temp_tetris[first_allone + 2] == 6'b111111 && temp_tetris[first_allone + 3] == 6'b111111 ) begin
			shift_stage <= 3'b010;
		end
		else if (temp_tetris[first_allone + 1] == 6'b111111 && temp_tetris[first_allone + 3] == 6'b111111 ) begin
			shift_stage <= 3'b011;
		end
		else if (temp_tetris[first_allone + 1] == 6'b111111 && temp_tetris[first_allone + 2] == 6'b111111 ) begin
			shift_stage <= 3'b100;
		end
		else if (temp_tetris[first_allone + 3] == 6'b111111) begin
			shift_stage <= 3'b101;
		end
		else if (temp_tetris[first_allone + 2] == 6'b111111) begin
			shift_stage <= 3'b110;
		end
		else if (temp_tetris[first_allone + 1] == 6'b111111) begin
			shift_stage <= 3'b111;
		end
		else begin
			shift_stage <= 3'b000;
		end
	end

end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		first_allone <= 0;
	end
	else if (cs == FIND_ALLONE) begin
		if (temp_tetris[lowest_row] == 6'b111111) first_allone <= lowest_row;
		else if (temp_tetris[lowest_row + 1] == 6'b111111) first_allone <= lowest_row + 1;
		else if (temp_tetris[lowest_row + 2] == 6'b111111) first_allone <= lowest_row + 2;
		else if (temp_tetris[lowest_row + 3] == 6'b111111) first_allone <= lowest_row + 3;
		else first_allone <= 12;
	end
end

//////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        tetris_valid <= 0;
    end
	else if(cs == OUT && (temp_tetris[12] != 0 || temp_tetris[13] != 0 || temp_tetris[14] != 0 || temp_tetris[15] != 0 || counter == 16)) begin
		tetris_valid <= 1;
	end
    else begin
        tetris_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        score_valid <= 0;
    end
	else if(cs == OUT) begin
		score_valid <= 1;
	end
    else begin
        score_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fail <= 0;
    end
	else if (cs == OUT && (temp_tetris[12] != 0 || temp_tetris[13] != 0 || temp_tetris[14] != 0 || temp_tetris[15] != 0 )) begin
		fail <= 1;
	end
    else begin
        fail <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        score <= 0;
    end
	else if(cs == OUT) begin
		score <= score_reg;
	end
    else begin
        score <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tetris <= 0;
    end
	else if(cs == OUT && (temp_tetris[12] != 0 || temp_tetris[13] != 0 || temp_tetris[14] != 0 || temp_tetris[15] != 0 || counter == 16)) begin
		tetris[0] <= temp_tetris[0][5];
		tetris[1] <= temp_tetris[0][4];
		tetris[2] <= temp_tetris[0][3];
		tetris[3] <= temp_tetris[0][2];
		tetris[4] <= temp_tetris[0][1];
		tetris[5] <= temp_tetris[0][0];
		
		tetris[6] <= temp_tetris[1][5];
		tetris[7] <= temp_tetris[1][4];
		tetris[8] <= temp_tetris[1][3];
		tetris[9] <= temp_tetris[1][2];
		tetris[10] <= temp_tetris[1][1];
		tetris[11] <= temp_tetris[1][0];
		
		tetris[12] <= temp_tetris[2][5];
		tetris[13] <= temp_tetris[2][4];
		tetris[14] <= temp_tetris[2][3];
		tetris[15] <= temp_tetris[2][2];
		tetris[16] <= temp_tetris[2][1];
		tetris[17] <= temp_tetris[2][0];

		tetris[18] <= temp_tetris[3][5];
		tetris[19] <= temp_tetris[3][4];
		tetris[20] <= temp_tetris[3][3];
		tetris[21] <= temp_tetris[3][2];
		tetris[22] <= temp_tetris[3][1];
		tetris[23] <= temp_tetris[3][0];
		
		tetris[24] <= temp_tetris[4][5];
		tetris[25] <= temp_tetris[4][4];
		tetris[26] <= temp_tetris[4][3];
		tetris[27] <= temp_tetris[4][2];
		tetris[28] <= temp_tetris[4][1];
		tetris[29] <= temp_tetris[4][0];

		tetris[30] <= temp_tetris[5][5];
		tetris[31] <= temp_tetris[5][4];
		tetris[32] <= temp_tetris[5][3];
		tetris[33] <= temp_tetris[5][2];
		tetris[34] <= temp_tetris[5][1];
		tetris[35] <= temp_tetris[5][0];

		tetris[36] <= temp_tetris[6][5];
		tetris[37] <= temp_tetris[6][4];
		tetris[38] <= temp_tetris[6][3];
		tetris[39] <= temp_tetris[6][2];
		tetris[40] <= temp_tetris[6][1];
		tetris[41] <= temp_tetris[6][0];

		tetris[42] <= temp_tetris[7][5];
		tetris[43] <= temp_tetris[7][4];
		tetris[44] <= temp_tetris[7][3];
		tetris[45] <= temp_tetris[7][2];
		tetris[46] <= temp_tetris[7][1];
		tetris[47] <= temp_tetris[7][0];

		tetris[48] <= temp_tetris[8][5];
		tetris[49] <= temp_tetris[8][4];
		tetris[50] <= temp_tetris[8][3];
		tetris[51] <= temp_tetris[8][2];
		tetris[52] <= temp_tetris[8][1];
		tetris[53] <= temp_tetris[8][0];

		tetris[54] <= temp_tetris[9][5];
		tetris[55] <= temp_tetris[9][4];
		tetris[56] <= temp_tetris[9][3];
		tetris[57] <= temp_tetris[9][2];
		tetris[58] <= temp_tetris[9][1];
		tetris[59] <= temp_tetris[9][0];

		tetris[60] <= temp_tetris[10][5];
		tetris[61] <= temp_tetris[10][4];
		tetris[62] <= temp_tetris[10][3];
		tetris[63] <= temp_tetris[10][2];
		tetris[64] <= temp_tetris[10][1];
		tetris[65] <= temp_tetris[10][0];

		tetris[66] <= temp_tetris[11][5];
		tetris[67] <= temp_tetris[11][4];
		tetris[68] <= temp_tetris[11][3];
		tetris[69] <= temp_tetris[11][2];
		tetris[70] <= temp_tetris[11][1];
		tetris[71] <= temp_tetris[11][0];


	end
    else begin
        tetris <= 0;
    end
end

endmodule





/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		lowest_row <= 0;
	end
	else if (cs == 0) begin
		case (pos_one)
			3'd0: begin

			end
			3'd2: begin
				case (tet_one)
					3'd1: 
    				begin
    	    			if (temp_tetris[11][pos_one] == 1 || temp_tetris[11][pos_one + 1] == 1) lowest_row <= 12;
        				else if (temp_tetris[10][pos_one] == 1 || temp_tetris[10][pos_one + 1] == 1) lowest_row <= 11;
	        			else if (temp_tetris[9][pos_one] == 1 || temp_tetris[9][pos_one + 1] == 1) lowest_row <= 10;
    	    			else if (temp_tetris[8][pos_one] == 1 || temp_tetris[8][pos_one + 1] == 1) lowest_row <= 9;
        				else if (temp_tetris[7][pos_one] == 1 || temp_tetris[7][pos_one + 1] == 1) lowest_row <= 8;
	        			else if (temp_tetris[6][pos_one] == 1 || temp_tetris[6][pos_one + 1] == 1) lowest_row <= 7;
    	    			else if (temp_tetris[5][pos_one] == 1 || temp_tetris[5][pos_one + 1] == 1) lowest_row <= 6;
	        			else if (temp_tetris[4][pos_one] == 1 || temp_tetris[4][pos_one + 1] == 1) lowest_row <= 5;
    	    			else if (temp_tetris[3][pos_one] == 1 || temp_tetris[3][pos_one + 1] == 1) lowest_row <= 4;
        				else if (temp_tetris[2][pos_one] == 1 || temp_tetris[2][pos_one + 1] == 1) lowest_row <= 3;
    	    			else if (temp_tetris[1][pos_one] == 1 || temp_tetris[1][pos_one + 1] == 1) lowest_row <= 2;
        				else if (temp_tetris[0][pos_one] == 1 || temp_tetris[0][pos_one + 1] == 1) lowest_row <= 1;
        				else lowest_row = 0; 
    				end
				endcase
			end
		endcase
	end
end
*/