module TMIP(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    
    image,
    template,
    image_size,
	action,
	
    // output signals
    out_valid,
    out_value
    );

input            clk, rst_n;
input            in_valid, in_valid2;

input      [7:0] image;
input      [7:0] template;
input      [1:0] image_size;
input      [2:0] action;

output reg       out_valid;
output reg       out_value;

//==================================================================
// parameter & integer
//==================================================================
parameter IDLE = 4'b0000;
parameter READ = 4'b0001;
parameter WAIT = 4'b0010;
parameter READ_A = 4'b0011;
parameter SOUT = 4'b0100;
parameter MAX_POOLING = 4'b0101;
parameter NEG = 4'b0110;
parameter HORI = 4'b0111;
parameter IMG_FILTER = 4'b1000;
parameter CONV = 4'b1001;
parameter OUT = 4'b1010;
//==================================================================
// reg & wire
//==================================================================
integer i;
reg [1:0] image_size_reg, image_size_real;
reg [7:0] temp_reg [0:2][0:2];
reg [9:0] counter_temp;

reg [2:0] action_num;
reg [2:0] action_reg [0:7];


reg [8:0] counter;
reg [4:0] counter_out_bit;
reg [4:0] counter_out_add;
reg [3:0] count_set;

reg [7:0] addr_img, addr_img_seq;
reg [3:0] cs, ns;
reg [7:0] rgb [0:2];

wire [7:0] grayscale0;
wire [7:0] grayscale0_sort1;
reg [7:0] grayscale0_seq;

reg [7:0] grayscale1;
reg [7:0] grayscale1_seq;

reg [7:0] grayscale2;
reg [7:0] grayscale2_seq;


reg [7:0] grayscale0_DO, grayscale1_DO, grayscale2_DO;
reg [7:0] grayscale_DO [0:2];


wire [7:0] m_1, m_2, max_poo;

reg [7:0] cal_reg [0:15][0:15];//////////////
reg [7:0] filter_map [0:1][0:15];/////////////////

reg [7:0] max_sort[0:1][0:1];

reg[19:0] con_ans;

reg web_img;
//==================================================================
// design
//==================================================================

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) counter_temp <= 0;
	else if (in_valid == 1 ) counter_temp <= counter_temp + 1;
    else  counter_temp <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        image_size_reg <= 0;
    end 
    else if (cs == IDLE && ns == READ)begin
        image_size_reg <= image_size;
    end
    else if (cs == OUT && ns == WAIT) begin
        image_size_reg <= image_size_real;
    end
    else if (cs == MAX_POOLING && image_size_reg == 1 && counter == 16) begin
        image_size_reg <= 0;
    end
    else if (cs == MAX_POOLING && image_size_reg == 2 && counter == 64) begin
        image_size_reg <= 1;
    end 
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        image_size_real <= 0;
    end 
    else if (cs == IDLE && ns == READ)begin
        image_size_real <= image_size;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            temp_reg[0][0] <= 0;
            temp_reg[0][1] <= 0;
            temp_reg[0][2] <= 0;
            temp_reg[1][0] <= 0;
            temp_reg[1][1] <= 0;
            temp_reg[1][2] <= 0;
            temp_reg[2][0] <= 0;
            temp_reg[2][1] <= 0;
            temp_reg[2][2] <= 0;
    end 
    else if (in_valid)begin
        case (counter_temp)
            0: temp_reg[0][0] <= template;
            1: temp_reg[0][1] <= template;
            2: temp_reg[0][2] <= template;

            3: temp_reg[1][0] <= template;
            4: temp_reg[1][1] <= template;
            5: temp_reg[1][2] <= template;

            6: temp_reg[2][0] <= template;
            7: temp_reg[2][1] <= template;
            8: temp_reg[2][2] <= template;
        endcase
    end
end

always @(posedge clk ) begin
if (in_valid2)begin
        action_num <= counter;
    end
    else begin
        action_num <= action_num;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

            action_reg[0] <= 0;
            action_reg[1] <= 0;
            action_reg[2] <= 0;
            action_reg[3] <= 0;
            action_reg[4] <= 0;
            action_reg[5] <= 0;
            action_reg[6] <= 0;
            action_reg[7] <= 0;

    end 
    else if (in_valid2)begin
        case   (counter)
            0: action_reg[0] <= action;
            1: action_reg[1] <= action;
            2: action_reg[2] <= action;
            3: action_reg[3] <= action;
            4: action_reg[4] <= action;
            5: action_reg[5] <= action;
            6: action_reg[6] <= action;
            7: action_reg[7] <= action;

        endcase
    end
    else if ((cs == MAX_POOLING || cs == NEG || cs == HORI || cs == IMG_FILTER) && counter == 0) begin
        action_reg[1] <= action_reg[2];
        action_reg[2] <= action_reg[3];
        action_reg[3] <= action_reg[4];
        action_reg[4] <= action_reg[5];
        action_reg[5] <= action_reg[6];
        action_reg[6] <= action_reg[7];
        action_reg[7] <= 0;
    end
    else begin

            action_reg[0] <= action_reg[0];
            action_reg[1] <= action_reg[1];
            action_reg[2] <= action_reg[2];
            action_reg[3] <= action_reg[3];
            action_reg[4] <= action_reg[4];
            action_reg[5] <= action_reg[5];
            action_reg[6] <= action_reg[6];
            action_reg[7] <= action_reg[7];

    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs <= IDLE;
    end else begin
        cs <= ns;
    end
end

always @(*) begin
	case (cs)
		IDLE: begin
			if (in_valid == 1'd1) begin
                ns = READ;
            end
            else begin
                ns = cs;
            end
		end
		READ: begin
			if (in_valid != 1  && addr_img == 0)  begin
                ns = WAIT;
            end
            else begin
                ns = cs;
            end
		end
		WAIT: begin
			if (in_valid2 == 1) begin
                ns = READ_A;
            end
            else begin
                ns = cs;
            end
		end
        READ_A: begin
			if (in_valid2 == 0) begin
                ns = SOUT;
            end
            else begin
                ns = cs;
            end
		end
        SOUT: begin
			if ((image_size_reg == 0 && counter == 17) ||
                (image_size_reg == 1 && counter == 65) ||
                (image_size_reg == 2 && counter == 257)) begin
                    case (action_reg[1])
                        3: ns = MAX_POOLING;
                        4: ns = NEG;
                        5: ns = HORI;
                        6: ns = IMG_FILTER;
                        7: ns = CONV;
                        default: ns = IDLE;
                    endcase
            end
            else begin
                ns = cs;
            end
		end
        MAX_POOLING: begin
			if ((image_size_reg == 0 && counter == 1) ||
                (image_size_reg == 1 && counter == 16) ||
                (image_size_reg == 2 && counter == 64)) begin
                    case (action_reg[1])
                        3: ns = MAX_POOLING;
                        4: ns = NEG;
                        5: ns = HORI;
                        6: ns = IMG_FILTER;
                        7: ns = CONV;
                        default: ns = IDLE;
                    endcase
            end
            else begin
                ns = cs;
            end
		end
        NEG: begin
			if (counter == 1) begin
                    case (action_reg[1])
                        3: ns = MAX_POOLING;
                        4: ns = NEG;
                        5: ns = HORI;
                        6: ns = IMG_FILTER;
                        7: ns = CONV;
                        default: ns = IDLE;
                    endcase
            end
            else begin
                ns = cs;
            end
		end
        HORI: begin
			if (counter == 1) begin
                    case (action_reg[1])
                        3: ns = MAX_POOLING;
                        4: ns = NEG;
                        5: ns = HORI;
                        6: ns = IMG_FILTER;
                        7: ns = CONV;
                        default: ns = IDLE;
                    endcase
            end
            else begin
                ns = cs;
            end
		end
        IMG_FILTER: begin
			if ((image_size_reg == 0 && counter == 18) ||
                (image_size_reg == 1 && counter == 66) ||
                (image_size_reg == 2 && counter == 258)) begin
                    case (action_reg[1])
                        3: ns = MAX_POOLING;
                        4: ns = NEG;
                        5: ns = HORI;
                        6: ns = IMG_FILTER;
                        7: ns = CONV;
                        default: ns = IDLE;
                    endcase
            end
            else begin
                ns = cs;
            end
		end

        CONV: begin
            if ((image_size_reg == 0 && counter == 18) ||
                (image_size_reg == 1 && counter == 66) ||
                (image_size_reg == 2 && counter == 258)) begin
                    ns = OUT;
            end

            else begin
                ns = cs;
            end
        end

        OUT: begin
            if ((image_size_reg == 0 && counter == 3 && counter_out_add == 3 && counter_out_bit ==19 && count_set != 8) ||
                (image_size_reg == 1 && counter == 7 && counter_out_add == 7 && counter_out_bit ==19 && count_set != 8) ||
                (image_size_reg == 2 && counter == 15 && counter_out_add == 15 && counter_out_bit ==19 && count_set != 8)) begin
                    ns = WAIT;
            end
            else if ((image_size_reg == 0 && counter == 3 && counter_out_add == 3 && counter_out_bit ==19 && count_set == 8) ||
                (image_size_reg == 1 && counter == 7 && counter_out_add == 7 && counter_out_bit ==19 && count_set == 8) ||
                (image_size_reg == 2 && counter == 15 && counter_out_add == 15 && counter_out_bit ==19 && count_set == 8)) begin
                    ns = IDLE;
            end
            else begin
                ns = cs;
            end
        end

		default:ns = IDLE;

	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) counter <= 0;
	else if (in_valid == 1 && counter != 2) counter <= counter + 1;
    else if (in_valid == 1 && counter == 2) counter <= 0;
    else if (in_valid2 == 1) counter <= counter + 1;
    else if (!in_valid2 && cs == READ_A) counter <= 0;

    else if ( cs == SOUT && image_size_reg == 0 && counter < 17) counter <= counter + 1;
    else if ( cs == SOUT && image_size_reg == 0 && counter == 17) counter <= 0;
    else if ( cs == SOUT && image_size_reg == 1 && counter < 65) counter <= counter + 1;
    else if ( cs == SOUT && image_size_reg == 1 && counter == 65) counter <= 0;
    else if ( cs == SOUT && image_size_reg == 2 && counter < 257) counter <= counter + 1;
    else if ( cs == SOUT && image_size_reg == 2 && counter == 257) counter <= 0;

    else if ( cs == IMG_FILTER && image_size_reg == 0 && counter < 18) counter <= counter + 1;
    else if ( cs == IMG_FILTER && image_size_reg == 0 && counter == 18) counter <= 0;
    else if ( cs == IMG_FILTER && image_size_reg == 1 && counter < 66) counter <= counter + 1;
    else if ( cs == IMG_FILTER && image_size_reg == 1 && counter == 66) counter <= 0;
    else if ( cs == IMG_FILTER && image_size_reg == 2 && counter < 258) counter <= counter + 1;
    else if ( cs == IMG_FILTER && image_size_reg == 2 && counter == 258) counter <= 0;

    else if ( cs == CONV && image_size_reg == 0 && counter < 18) counter <= counter + 1;
    else if ( cs == CONV && image_size_reg == 0 && counter == 18) counter <= 0;
    else if ( cs == CONV && image_size_reg == 1 && counter < 66) counter <= counter + 1;
    else if ( cs == CONV && image_size_reg == 1 && counter == 66) counter <= 0;
    else if ( cs == CONV && image_size_reg == 2 && counter < 258) counter <= counter + 1;
    else if ( cs == CONV && image_size_reg == 2 && counter == 258) counter <= 0;

    else if ( cs == MAX_POOLING && image_size_reg == 0 && counter < 1) counter <= counter + 1;
    else if ( cs == MAX_POOLING && image_size_reg == 0 && counter == 1) counter <= 0;
    else if ( cs == MAX_POOLING && image_size_reg == 1 && counter < 16) counter <= counter + 1;
    else if ( cs == MAX_POOLING && image_size_reg == 1 && counter == 16) counter <= 0;
    else if ( cs == MAX_POOLING && image_size_reg == 2 && counter < 64) counter <= counter + 1;
    else if ( cs == MAX_POOLING && image_size_reg == 2 && counter == 64) counter <= 0;

    else if ( cs == NEG && counter < 1) counter <= counter + 1;
    else if ( cs == NEG && counter == 1) counter <= 0;

    else if ( cs == HORI && counter < 1) counter <= counter + 1;
    else if ( cs == HORI && counter == 1) counter <= 0;

    else if ( cs == OUT && image_size_reg == 0 && counter_out_add == 3 && counter_out_bit == 19 && counter < 3) counter <= counter + 1;
    else if ( cs == OUT && image_size_reg == 0 && counter_out_add == 3 && counter_out_bit == 19 && counter == 3) counter <= 0;
    else if ( cs == OUT && image_size_reg == 1 && counter_out_add == 7 && counter_out_bit == 19 && counter < 7) counter <= counter + 1;
    else if ( cs == OUT && image_size_reg == 1 && counter_out_add == 7 && counter_out_bit == 19 && counter == 7) counter <= 0;
    else if ( cs == OUT && image_size_reg == 2 && counter_out_add == 15 && counter_out_bit == 19 && counter < 15) counter <= counter + 1;
    else if ( cs == OUT && image_size_reg == 2 && counter_out_add == 15 && counter_out_bit == 19 && counter == 15) counter <= 0;


    else  counter <= counter;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) counter_out_add <= 0;
    else if ( image_size_reg == 0 && counter_out_add < 3 && counter_out_bit == 19) begin
        counter_out_add <= counter_out_add + 1;
    end
    else if ( image_size_reg == 0 && counter_out_add == 3 && counter_out_bit == 19) begin
        counter_out_add <=0;
    end
    else if ( image_size_reg == 1 && counter_out_add < 7 && counter_out_bit == 19) begin
        counter_out_add <= counter_out_add + 1;
    end
    else if ( image_size_reg == 1 && counter_out_add == 7 && counter_out_bit == 19) begin
        counter_out_add <=0;
    end
    else if ( image_size_reg == 2 && counter_out_add < 15 && counter_out_bit == 19) begin
        counter_out_add <= counter_out_add + 1;
    end
    else if ( image_size_reg == 2 && counter_out_add == 15 && counter_out_bit == 19) begin
        counter_out_add <=0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) counter_out_bit <= 0;
    else if (cs == OUT && counter_out_bit < 19) begin
        counter_out_bit <= counter_out_bit + 1;
    end
    else if (cs == OUT && counter_out_bit == 19) begin
        counter_out_bit <= 0;
    end
    else if (cs != OUT) begin
        counter_out_bit <= 0;
    end

end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) addr_img <= 0;
	else if (in_valid == 1 && cs == READ && counter == 0) addr_img <= addr_img + 1;
    else if (in_valid == 1 && cs == READ && counter != 0) addr_img <= addr_img;
    else if (in_valid != 1 && cs == READ && counter == 0) addr_img <= 0;
    else if ( cs == SOUT && image_size_reg == 0 && counter < 15) addr_img <= addr_img + 1;
    else if ( cs == SOUT && image_size_reg == 1 && counter < 63) addr_img <= addr_img + 1;
    else if ( cs == SOUT && image_size_reg == 2 && counter < 255) addr_img <= addr_img + 1;
    else if (cs == OUT) addr_img <= 0;
    else  addr_img <= addr_img;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) addr_img_seq <= 0;
	else if (cs == READ ) addr_img_seq <= addr_img;
    else if (cs == WAIT ) addr_img_seq <= 0;
    else if (cs == READ_A ) addr_img_seq <= 0;
    else if (cs == SOUT ) addr_img_seq <= addr_img;
    else if (cs == OUT) addr_img_seq <= 0;
    else  addr_img_seq <= addr_img_seq;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) count_set <= 0;
    else if (cs == IDLE) count_set <= 0;
    else if (cs == READ_A && counter == 1) count_set <= count_set + 1;
end

always @(*)begin
	if(cs == IDLE) web_img = 1;
	else if (cs == READ) web_img = 0;
    else if (cs == WAIT) web_img = 1;
    else web_img = 1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rgb[0] <= 0;
        rgb[1] <= 0;
        rgb[2] <= 0;
    end 
    else if (in_valid)begin
        case (counter)
            0: rgb[0] <= image;
            1: rgb[1] <= image;
            2: rgb[2] <= image;
        endcase
    end
end

assign grayscale0_sort1 = (rgb[0] > rgb[1])? rgb[0] : rgb[1];
assign grayscale0 = (grayscale0_sort1 > rgb[2])? grayscale0_sort1 : rgb[2];

always @(*) begin
    grayscale1 = (rgb[0] + rgb[1] + rgb[2])/3; 
end

always @(*) begin
    grayscale2 = (rgb[0] >> 2) + (rgb[1] >> 1) + (rgb[2] >> 2);
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        grayscale0_seq <= 0;
    end
    else if (cs == READ && counter == 0) begin
        grayscale0_seq <= grayscale0;
    end
    else if (cs == READ && counter != 0) begin
        grayscale0_seq <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        grayscale1_seq <= 0;
    end
    else if (cs == READ && counter == 0) begin
        grayscale1_seq <= grayscale1;
    end
    else if (cs == READ && counter != 0) begin
        grayscale1_seq <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        grayscale2_seq <= 0;
    end
    else if (cs == READ && counter == 0) begin
        grayscale2_seq <= grayscale2;
    end
    else if (cs == READ && counter != 0) begin
        grayscale2_seq <= 0;
    end
end

MEM_256_8_int G0(.A(addr_img_seq), .DO(grayscale_DO[0]), .DI(grayscale0_seq), .CK(clk), .WEB(web_img), .OE(1'b1), .CS(1'b1));
MEM_256_8_int G1(.A(addr_img_seq), .DO(grayscale_DO[1]), .DI(grayscale1_seq), .CK(clk), .WEB(web_img), .OE(1'b1), .CS(1'b1));
MEM_256_8_int G2(.A(addr_img_seq), .DO(grayscale_DO[2]), .DI(grayscale2_seq), .CK(clk), .WEB(web_img), .OE(1'b1), .CS(1'b1));


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cal_reg[0][0] <= 0;
        cal_reg[0][1] <= 0;
        cal_reg[0][2] <= 0;
        cal_reg[0][3] <= 0;
        cal_reg[0][4] <= 0;
        cal_reg[0][5] <= 0;
        cal_reg[0][6] <= 0;
        cal_reg[0][7] <= 0;
        cal_reg[0][8] <= 0;
        cal_reg[0][9] <= 0;
        cal_reg[0][10] <= 0;
        cal_reg[0][11] <= 0;
        cal_reg[0][12] <= 0;
        cal_reg[0][13] <= 0;
        cal_reg[0][14] <= 0;
        cal_reg[0][15] <= 0;

        cal_reg[1][0] <= 0;
        cal_reg[1][1] <= 0;
        cal_reg[1][2] <= 0;
        cal_reg[1][3] <= 0;
        cal_reg[1][4] <= 0;
        cal_reg[1][5] <= 0;
        cal_reg[1][6] <= 0;
        cal_reg[1][7] <= 0;
        cal_reg[1][8] <= 0;
        cal_reg[1][9] <= 0;
        cal_reg[1][10] <= 0;
        cal_reg[1][11] <= 0;
        cal_reg[1][12] <= 0;
        cal_reg[1][13] <= 0;
        cal_reg[1][14] <= 0;
        cal_reg[1][15] <= 0;

        cal_reg[2][0] <= 0;
        cal_reg[2][1] <= 0;
        cal_reg[2][2] <= 0;
        cal_reg[2][3] <= 0;
        cal_reg[2][4] <= 0;
        cal_reg[2][5] <= 0;
        cal_reg[2][6] <= 0;
        cal_reg[2][7] <= 0;
        cal_reg[2][8] <= 0;
        cal_reg[2][9] <= 0;
        cal_reg[2][10] <= 0;
        cal_reg[2][11] <= 0;
        cal_reg[2][12] <= 0;
        cal_reg[2][13] <= 0;
        cal_reg[2][14] <= 0;
        cal_reg[2][15] <= 0;

        cal_reg[3][0] <= 0;
        cal_reg[3][1] <= 0;
        cal_reg[3][2] <= 0;
        cal_reg[3][3] <= 0;
        cal_reg[3][4] <= 0;
        cal_reg[3][5] <= 0;
        cal_reg[3][6] <= 0;
        cal_reg[3][7] <= 0;
        cal_reg[3][8] <= 0;
        cal_reg[3][9] <= 0;
        cal_reg[3][10] <= 0;
        cal_reg[3][11] <= 0;
        cal_reg[3][12] <= 0;
        cal_reg[3][13] <= 0;
        cal_reg[3][14] <= 0;
        cal_reg[3][15] <= 0;

        cal_reg[4][0] <= 0;
        cal_reg[4][1] <= 0;
        cal_reg[4][2] <= 0;
        cal_reg[4][3] <= 0;
        cal_reg[4][4] <= 0;
        cal_reg[4][5] <= 0;
        cal_reg[4][6] <= 0;
        cal_reg[4][7] <= 0;
        cal_reg[4][8] <= 0;
        cal_reg[4][9] <= 0;
        cal_reg[4][10] <= 0;
        cal_reg[4][11] <= 0;
        cal_reg[4][12] <= 0;
        cal_reg[4][13] <= 0;
        cal_reg[4][14] <= 0;
        cal_reg[4][15] <= 0;

        cal_reg[5][0] <= 0;
        cal_reg[5][1] <= 0;
        cal_reg[5][2] <= 0;
        cal_reg[5][3] <= 0;
        cal_reg[5][4] <= 0;
        cal_reg[5][5] <= 0;
        cal_reg[5][6] <= 0;
        cal_reg[5][7] <= 0;
        cal_reg[5][8] <= 0;
        cal_reg[5][9] <= 0;
        cal_reg[5][10] <= 0;
        cal_reg[5][11] <= 0;
        cal_reg[5][12] <= 0;
        cal_reg[5][13] <= 0;
        cal_reg[5][14] <= 0;
        cal_reg[5][15] <= 0;

        cal_reg[6][0] <= 0;
        cal_reg[6][1] <= 0;
        cal_reg[6][2] <= 0;
        cal_reg[6][3] <= 0;
        cal_reg[6][4] <= 0;
        cal_reg[6][5] <= 0;
        cal_reg[6][6] <= 0;
        cal_reg[6][7] <= 0;
        cal_reg[6][8] <= 0;
        cal_reg[6][9] <= 0;
        cal_reg[6][10] <= 0;
        cal_reg[6][11] <= 0;
        cal_reg[6][12] <= 0;
        cal_reg[6][13] <= 0;
        cal_reg[6][14] <= 0;
        cal_reg[6][15] <= 0;

        cal_reg[7][0] <= 0;
        cal_reg[7][1] <= 0;
        cal_reg[7][2] <= 0;
        cal_reg[7][3] <= 0;
        cal_reg[7][4] <= 0;
        cal_reg[7][5] <= 0;
        cal_reg[7][6] <= 0;
        cal_reg[7][7] <= 0;
        cal_reg[7][8] <= 0;
        cal_reg[7][9] <= 0;
        cal_reg[7][10] <= 0;
        cal_reg[7][11] <= 0;
        cal_reg[7][12] <= 0;
        cal_reg[7][13] <= 0;
        cal_reg[7][14] <= 0;
        cal_reg[7][15] <= 0;

        cal_reg[8][0] <= 0;
        cal_reg[8][1] <= 0;
        cal_reg[8][2] <= 0;
        cal_reg[8][3] <= 0;
        cal_reg[8][4] <= 0;
        cal_reg[8][5] <= 0;
        cal_reg[8][6] <= 0;
        cal_reg[8][7] <= 0;
        cal_reg[8][8] <= 0;
        cal_reg[8][9] <= 0;
        cal_reg[8][10] <= 0;
        cal_reg[8][11] <= 0;
        cal_reg[8][12] <= 0;
        cal_reg[8][13] <= 0;
        cal_reg[8][14] <= 0;
        cal_reg[8][15] <= 0;

        cal_reg[9][0] <= 0;
        cal_reg[9][1] <= 0;
        cal_reg[9][2] <= 0;
        cal_reg[9][3] <= 0;
        cal_reg[9][4] <= 0;
        cal_reg[9][5] <= 0;
        cal_reg[9][6] <= 0;
        cal_reg[9][7] <= 0;
        cal_reg[9][8] <= 0;
        cal_reg[9][9] <= 0;
        cal_reg[9][10] <= 0;
        cal_reg[9][11] <= 0;
        cal_reg[9][12] <= 0;
        cal_reg[9][13] <= 0;
        cal_reg[9][14] <= 0;
        cal_reg[9][15] <= 0;

        cal_reg[10][0] <= 0;
        cal_reg[10][1] <= 0;
        cal_reg[10][2] <= 0;
        cal_reg[10][3] <= 0;
        cal_reg[10][4] <= 0;
        cal_reg[10][5] <= 0;
        cal_reg[10][6] <= 0;
        cal_reg[10][7] <= 0;
        cal_reg[10][8] <= 0;
        cal_reg[10][9] <= 0;
        cal_reg[10][10] <= 0;
        cal_reg[10][11] <= 0;
        cal_reg[10][12] <= 0;
        cal_reg[10][13] <= 0;
        cal_reg[10][14] <= 0;
        cal_reg[10][15] <= 0;

        cal_reg[11][0] <= 0;
        cal_reg[11][1] <= 0;
        cal_reg[11][2] <= 0;
        cal_reg[11][3] <= 0;
        cal_reg[11][4] <= 0;
        cal_reg[11][5] <= 0;
        cal_reg[11][6] <= 0;
        cal_reg[11][7] <= 0;
        cal_reg[11][8] <= 0;
        cal_reg[11][9] <= 0;
        cal_reg[11][10] <= 0;
        cal_reg[11][11] <= 0;
        cal_reg[11][12] <= 0;
        cal_reg[11][13] <= 0;
        cal_reg[11][14] <= 0;
        cal_reg[11][15] <= 0;

        cal_reg[12][0] <= 0;
        cal_reg[12][1] <= 0;
        cal_reg[12][2] <= 0;
        cal_reg[12][3] <= 0;
        cal_reg[12][4] <= 0;
        cal_reg[12][5] <= 0;
        cal_reg[12][6] <= 0;
        cal_reg[12][7] <= 0;
        cal_reg[12][8] <= 0;
        cal_reg[12][9] <= 0;
        cal_reg[12][10] <= 0;
        cal_reg[12][11] <= 0;
        cal_reg[12][12] <= 0;
        cal_reg[12][13] <= 0;
        cal_reg[12][14] <= 0;
        cal_reg[12][15] <= 0;

        cal_reg[13][0] <= 0;
        cal_reg[13][1] <= 0;
        cal_reg[13][2] <= 0;
        cal_reg[13][3] <= 0;
        cal_reg[13][4] <= 0;
        cal_reg[13][5] <= 0;
        cal_reg[13][6] <= 0;
        cal_reg[13][7] <= 0;
        cal_reg[13][8] <= 0;
        cal_reg[13][9] <= 0;
        cal_reg[13][10] <= 0;
        cal_reg[13][11] <= 0;
        cal_reg[13][12] <= 0;
        cal_reg[13][13] <= 0;
        cal_reg[13][14] <= 0;
        cal_reg[13][15] <= 0;

        cal_reg[14][0] <= 0;
        cal_reg[14][1] <= 0;
        cal_reg[14][2] <= 0;
        cal_reg[14][3] <= 0;
        cal_reg[14][4] <= 0;
        cal_reg[14][5] <= 0;
        cal_reg[14][6] <= 0;
        cal_reg[14][7] <= 0;
        cal_reg[14][8] <= 0;
        cal_reg[14][9] <= 0;
        cal_reg[14][10] <= 0;
        cal_reg[14][11] <= 0;
        cal_reg[14][12] <= 0;
        cal_reg[14][13] <= 0;
        cal_reg[14][14] <= 0;
        cal_reg[14][15] <= 0;

        cal_reg[15][0] <= 0;
        cal_reg[15][1] <= 0;
        cal_reg[15][2] <= 0;
        cal_reg[15][3] <= 0;
        cal_reg[15][4] <= 0;
        cal_reg[15][5] <= 0;
        cal_reg[15][6] <= 0;
        cal_reg[15][7] <= 0;
        cal_reg[15][8] <= 0;
        cal_reg[15][9] <= 0;
        cal_reg[15][10] <= 0;
        cal_reg[15][11] <= 0;
        cal_reg[15][12] <= 0;
        cal_reg[15][13] <= 0;
        cal_reg[15][14] <= 0;
        cal_reg[15][15] <= 0;

    end
    else if (cs == SOUT) begin
        if (image_size_reg == 0) begin
            case (counter)
                2: cal_reg[0][0] <= grayscale_DO[action_reg[0]];
                3: cal_reg[0][1] <= grayscale_DO[action_reg[0]];
                4: cal_reg[0][2] <= grayscale_DO[action_reg[0]];
                5: cal_reg[0][3] <= grayscale_DO[action_reg[0]];

                6: cal_reg[1][0] <= grayscale_DO[action_reg[0]];
                7: cal_reg[1][1] <= grayscale_DO[action_reg[0]];
                8: cal_reg[1][2] <= grayscale_DO[action_reg[0]];
                9: cal_reg[1][3] <= grayscale_DO[action_reg[0]];

                10: cal_reg[2][0] <= grayscale_DO[action_reg[0]];
                11: cal_reg[2][1] <= grayscale_DO[action_reg[0]];
                12: cal_reg[2][2] <= grayscale_DO[action_reg[0]];
                13: cal_reg[2][3] <= grayscale_DO[action_reg[0]];

                14: cal_reg[3][0] <= grayscale_DO[action_reg[0]];
                15: cal_reg[3][1] <= grayscale_DO[action_reg[0]];
                16: cal_reg[3][2] <= grayscale_DO[action_reg[0]];
                17: cal_reg[3][3] <= grayscale_DO[action_reg[0]];
            endcase
        end
        else if (image_size_reg == 1) begin
            case (counter)
                2:  cal_reg[0][0] <= grayscale_DO[action_reg[0]];
                3:  cal_reg[0][1] <= grayscale_DO[action_reg[0]];
                4:  cal_reg[0][2] <= grayscale_DO[action_reg[0]];
                5:  cal_reg[0][3] <= grayscale_DO[action_reg[0]];
                6:  cal_reg[0][4] <= grayscale_DO[action_reg[0]];
                7:  cal_reg[0][5] <= grayscale_DO[action_reg[0]];
                8:  cal_reg[0][6] <= grayscale_DO[action_reg[0]];
                9:  cal_reg[0][7] <= grayscale_DO[action_reg[0]];

                10: cal_reg[1][0] <= grayscale_DO[action_reg[0]];
                11: cal_reg[1][1] <= grayscale_DO[action_reg[0]];
                12: cal_reg[1][2] <= grayscale_DO[action_reg[0]];
                13: cal_reg[1][3] <= grayscale_DO[action_reg[0]];
                14: cal_reg[1][4] <= grayscale_DO[action_reg[0]];
                15: cal_reg[1][5] <= grayscale_DO[action_reg[0]];
                16: cal_reg[1][6] <= grayscale_DO[action_reg[0]];
                17: cal_reg[1][7] <= grayscale_DO[action_reg[0]];

                18: cal_reg[2][0] <= grayscale_DO[action_reg[0]];
                19: cal_reg[2][1] <= grayscale_DO[action_reg[0]];
                20: cal_reg[2][2] <= grayscale_DO[action_reg[0]];
                21: cal_reg[2][3] <= grayscale_DO[action_reg[0]];
                22: cal_reg[2][4] <= grayscale_DO[action_reg[0]];
                23: cal_reg[2][5] <= grayscale_DO[action_reg[0]];
                24: cal_reg[2][6] <= grayscale_DO[action_reg[0]];
                25: cal_reg[2][7] <= grayscale_DO[action_reg[0]];

                26: cal_reg[3][0] <= grayscale_DO[action_reg[0]];
                27: cal_reg[3][1] <= grayscale_DO[action_reg[0]];
                28: cal_reg[3][2] <= grayscale_DO[action_reg[0]];
                29: cal_reg[3][3] <= grayscale_DO[action_reg[0]];
                30: cal_reg[3][4] <= grayscale_DO[action_reg[0]];
                31: cal_reg[3][5] <= grayscale_DO[action_reg[0]];
                32: cal_reg[3][6] <= grayscale_DO[action_reg[0]];
                33: cal_reg[3][7] <= grayscale_DO[action_reg[0]];

                34: cal_reg[4][0] <= grayscale_DO[action_reg[0]];
                35: cal_reg[4][1] <= grayscale_DO[action_reg[0]];
                36: cal_reg[4][2] <= grayscale_DO[action_reg[0]];
                37: cal_reg[4][3] <= grayscale_DO[action_reg[0]];
                38: cal_reg[4][4] <= grayscale_DO[action_reg[0]];
                39: cal_reg[4][5] <= grayscale_DO[action_reg[0]];
                40: cal_reg[4][6] <= grayscale_DO[action_reg[0]];
                41: cal_reg[4][7] <= grayscale_DO[action_reg[0]];

                42: cal_reg[5][0] <= grayscale_DO[action_reg[0]];
                43: cal_reg[5][1] <= grayscale_DO[action_reg[0]];
                44: cal_reg[5][2] <= grayscale_DO[action_reg[0]];
                45: cal_reg[5][3] <= grayscale_DO[action_reg[0]];
                46: cal_reg[5][4] <= grayscale_DO[action_reg[0]];
                47: cal_reg[5][5] <= grayscale_DO[action_reg[0]];
                48: cal_reg[5][6] <= grayscale_DO[action_reg[0]];
                49: cal_reg[5][7] <= grayscale_DO[action_reg[0]];

                50: cal_reg[6][0] <= grayscale_DO[action_reg[0]];
                51: cal_reg[6][1] <= grayscale_DO[action_reg[0]];
                52: cal_reg[6][2] <= grayscale_DO[action_reg[0]];
                53: cal_reg[6][3] <= grayscale_DO[action_reg[0]];
                54: cal_reg[6][4] <= grayscale_DO[action_reg[0]];
                55: cal_reg[6][5] <= grayscale_DO[action_reg[0]];
                56: cal_reg[6][6] <= grayscale_DO[action_reg[0]];
                57: cal_reg[6][7] <= grayscale_DO[action_reg[0]];

                58: cal_reg[7][0] <= grayscale_DO[action_reg[0]];
                59: cal_reg[7][1] <= grayscale_DO[action_reg[0]];
                60: cal_reg[7][2] <= grayscale_DO[action_reg[0]];
                61: cal_reg[7][3] <= grayscale_DO[action_reg[0]];
                62: cal_reg[7][4] <= grayscale_DO[action_reg[0]];
                63: cal_reg[7][5] <= grayscale_DO[action_reg[0]];
                64: cal_reg[7][6] <= grayscale_DO[action_reg[0]];
                65: cal_reg[7][7] <= grayscale_DO[action_reg[0]];
            endcase           
        end
        else if (image_size_reg == 2) begin
            case (counter)
                // Row 0
                2:  cal_reg[0][0] <= grayscale_DO[action_reg[0]];
                3:  cal_reg[0][1] <= grayscale_DO[action_reg[0]];
                4:  cal_reg[0][2] <= grayscale_DO[action_reg[0]];
                5:  cal_reg[0][3] <= grayscale_DO[action_reg[0]];
                6:  cal_reg[0][4] <= grayscale_DO[action_reg[0]];
                7:  cal_reg[0][5] <= grayscale_DO[action_reg[0]];
                8:  cal_reg[0][6] <= grayscale_DO[action_reg[0]];
                9:  cal_reg[0][7] <= grayscale_DO[action_reg[0]];
                10: cal_reg[0][8] <= grayscale_DO[action_reg[0]];
                11: cal_reg[0][9] <= grayscale_DO[action_reg[0]];
                12: cal_reg[0][10] <= grayscale_DO[action_reg[0]];
                13: cal_reg[0][11] <= grayscale_DO[action_reg[0]];
                14: cal_reg[0][12] <= grayscale_DO[action_reg[0]];
                15: cal_reg[0][13] <= grayscale_DO[action_reg[0]];
                16: cal_reg[0][14] <= grayscale_DO[action_reg[0]];
                17: cal_reg[0][15] <= grayscale_DO[action_reg[0]];

                // Row 1
                18: cal_reg[1][0] <= grayscale_DO[action_reg[0]];
                19: cal_reg[1][1] <= grayscale_DO[action_reg[0]];
                20: cal_reg[1][2] <= grayscale_DO[action_reg[0]];
                21: cal_reg[1][3] <= grayscale_DO[action_reg[0]];
                22: cal_reg[1][4] <= grayscale_DO[action_reg[0]];
                23: cal_reg[1][5] <= grayscale_DO[action_reg[0]];
                24: cal_reg[1][6] <= grayscale_DO[action_reg[0]];
                25: cal_reg[1][7] <= grayscale_DO[action_reg[0]];
                26: cal_reg[1][8] <= grayscale_DO[action_reg[0]];
                27: cal_reg[1][9] <= grayscale_DO[action_reg[0]];
                28: cal_reg[1][10] <= grayscale_DO[action_reg[0]];
                29: cal_reg[1][11] <= grayscale_DO[action_reg[0]];
                30: cal_reg[1][12] <= grayscale_DO[action_reg[0]];
                31: cal_reg[1][13] <= grayscale_DO[action_reg[0]];
                32: cal_reg[1][14] <= grayscale_DO[action_reg[0]];
                33: cal_reg[1][15] <= grayscale_DO[action_reg[0]];

                // Row 2
                34: cal_reg[2][0] <= grayscale_DO[action_reg[0]];
                35: cal_reg[2][1] <= grayscale_DO[action_reg[0]];
                36: cal_reg[2][2] <= grayscale_DO[action_reg[0]];
                37: cal_reg[2][3] <= grayscale_DO[action_reg[0]];
                38: cal_reg[2][4] <= grayscale_DO[action_reg[0]];
                39: cal_reg[2][5] <= grayscale_DO[action_reg[0]];
                40: cal_reg[2][6] <= grayscale_DO[action_reg[0]];
                41: cal_reg[2][7] <= grayscale_DO[action_reg[0]];
                42: cal_reg[2][8] <= grayscale_DO[action_reg[0]];
                43: cal_reg[2][9] <= grayscale_DO[action_reg[0]];
                44: cal_reg[2][10] <= grayscale_DO[action_reg[0]];
                45: cal_reg[2][11] <= grayscale_DO[action_reg[0]];
                46: cal_reg[2][12] <= grayscale_DO[action_reg[0]];
                47: cal_reg[2][13] <= grayscale_DO[action_reg[0]];
                48: cal_reg[2][14] <= grayscale_DO[action_reg[0]];
                49: cal_reg[2][15] <= grayscale_DO[action_reg[0]];

                // Row 3
                50: cal_reg[3][0] <= grayscale_DO[action_reg[0]];
                51: cal_reg[3][1] <= grayscale_DO[action_reg[0]];
                52: cal_reg[3][2] <= grayscale_DO[action_reg[0]];
                53: cal_reg[3][3] <= grayscale_DO[action_reg[0]];
                54: cal_reg[3][4] <= grayscale_DO[action_reg[0]];
                55: cal_reg[3][5] <= grayscale_DO[action_reg[0]];
                56: cal_reg[3][6] <= grayscale_DO[action_reg[0]];
                57: cal_reg[3][7] <= grayscale_DO[action_reg[0]];
                58: cal_reg[3][8] <= grayscale_DO[action_reg[0]];
                59: cal_reg[3][9] <= grayscale_DO[action_reg[0]];
                60: cal_reg[3][10] <= grayscale_DO[action_reg[0]];
                61: cal_reg[3][11] <= grayscale_DO[action_reg[0]];
                62: cal_reg[3][12] <= grayscale_DO[action_reg[0]];
                63: cal_reg[3][13] <= grayscale_DO[action_reg[0]];
                64: cal_reg[3][14] <= grayscale_DO[action_reg[0]];
                65: cal_reg[3][15] <= grayscale_DO[action_reg[0]];

                // Row 4
                66: cal_reg[4][0] <= grayscale_DO[action_reg[0]];
                67: cal_reg[4][1] <= grayscale_DO[action_reg[0]];
                68: cal_reg[4][2] <= grayscale_DO[action_reg[0]];
                69: cal_reg[4][3] <= grayscale_DO[action_reg[0]];
                70: cal_reg[4][4] <= grayscale_DO[action_reg[0]];
                71: cal_reg[4][5] <= grayscale_DO[action_reg[0]];
                72: cal_reg[4][6] <= grayscale_DO[action_reg[0]];
                73: cal_reg[4][7] <= grayscale_DO[action_reg[0]];
                74: cal_reg[4][8] <= grayscale_DO[action_reg[0]];
                75: cal_reg[4][9] <= grayscale_DO[action_reg[0]];
                76: cal_reg[4][10] <= grayscale_DO[action_reg[0]];
                77: cal_reg[4][11] <= grayscale_DO[action_reg[0]];
                78: cal_reg[4][12] <= grayscale_DO[action_reg[0]];
                79: cal_reg[4][13] <= grayscale_DO[action_reg[0]];
                80: cal_reg[4][14] <= grayscale_DO[action_reg[0]];
                81: cal_reg[4][15] <= grayscale_DO[action_reg[0]];

                // Row 5
                82: cal_reg[5][0] <= grayscale_DO[action_reg[0]];
                83: cal_reg[5][1] <= grayscale_DO[action_reg[0]];
                84: cal_reg[5][2] <= grayscale_DO[action_reg[0]];
                85: cal_reg[5][3] <= grayscale_DO[action_reg[0]];
                86: cal_reg[5][4] <= grayscale_DO[action_reg[0]];
                87: cal_reg[5][5] <= grayscale_DO[action_reg[0]];
                88: cal_reg[5][6] <= grayscale_DO[action_reg[0]];
                89: cal_reg[5][7] <= grayscale_DO[action_reg[0]];
                90: cal_reg[5][8] <= grayscale_DO[action_reg[0]];
                91: cal_reg[5][9] <= grayscale_DO[action_reg[0]];
                92: cal_reg[5][10] <= grayscale_DO[action_reg[0]];
                93: cal_reg[5][11] <= grayscale_DO[action_reg[0]];
                94: cal_reg[5][12] <= grayscale_DO[action_reg[0]];
                95: cal_reg[5][13] <= grayscale_DO[action_reg[0]];
                96: cal_reg[5][14] <= grayscale_DO[action_reg[0]];
                97: cal_reg[5][15] <= grayscale_DO[action_reg[0]];

                // Row 6
                98: cal_reg[6][0] <= grayscale_DO[action_reg[0]];
                99: cal_reg[6][1] <= grayscale_DO[action_reg[0]];
                100: cal_reg[6][2] <= grayscale_DO[action_reg[0]];
                101: cal_reg[6][3] <= grayscale_DO[action_reg[0]];
                102: cal_reg[6][4] <= grayscale_DO[action_reg[0]];
                103: cal_reg[6][5] <= grayscale_DO[action_reg[0]];
                104: cal_reg[6][6] <= grayscale_DO[action_reg[0]];
                105: cal_reg[6][7] <= grayscale_DO[action_reg[0]];
                106: cal_reg[6][8] <= grayscale_DO[action_reg[0]];
                107: cal_reg[6][9] <= grayscale_DO[action_reg[0]];
                108: cal_reg[6][10] <= grayscale_DO[action_reg[0]];
                109: cal_reg[6][11] <= grayscale_DO[action_reg[0]];
                110: cal_reg[6][12] <= grayscale_DO[action_reg[0]];
                111: cal_reg[6][13] <= grayscale_DO[action_reg[0]];
                112: cal_reg[6][14] <= grayscale_DO[action_reg[0]];
                113: cal_reg[6][15] <= grayscale_DO[action_reg[0]];

                // Row 7
                114: cal_reg[7][0] <= grayscale_DO[action_reg[0]];
                115: cal_reg[7][1] <= grayscale_DO[action_reg[0]];
                116: cal_reg[7][2] <= grayscale_DO[action_reg[0]];
                117: cal_reg[7][3] <= grayscale_DO[action_reg[0]];
                118: cal_reg[7][4] <= grayscale_DO[action_reg[0]];
                119: cal_reg[7][5] <= grayscale_DO[action_reg[0]];
                120: cal_reg[7][6] <= grayscale_DO[action_reg[0]];
                121: cal_reg[7][7] <= grayscale_DO[action_reg[0]];
                122: cal_reg[7][8] <= grayscale_DO[action_reg[0]];
                123: cal_reg[7][9] <= grayscale_DO[action_reg[0]];
                124: cal_reg[7][10] <= grayscale_DO[action_reg[0]];
                125: cal_reg[7][11] <= grayscale_DO[action_reg[0]];
                126: cal_reg[7][12] <= grayscale_DO[action_reg[0]];
                127: cal_reg[7][13] <= grayscale_DO[action_reg[0]];
                128: cal_reg[7][14] <= grayscale_DO[action_reg[0]];
                129: cal_reg[7][15] <= grayscale_DO[action_reg[0]];

                // Row 8
                130: cal_reg[8][0] <= grayscale_DO[action_reg[0]];
                131: cal_reg[8][1] <= grayscale_DO[action_reg[0]];
                132: cal_reg[8][2] <= grayscale_DO[action_reg[0]];
                133: cal_reg[8][3] <= grayscale_DO[action_reg[0]];
                134: cal_reg[8][4] <= grayscale_DO[action_reg[0]];
                135: cal_reg[8][5] <= grayscale_DO[action_reg[0]];
                136: cal_reg[8][6] <= grayscale_DO[action_reg[0]];
                137: cal_reg[8][7] <= grayscale_DO[action_reg[0]];
                138: cal_reg[8][8] <= grayscale_DO[action_reg[0]];
                139: cal_reg[8][9] <= grayscale_DO[action_reg[0]];
                140: cal_reg[8][10] <= grayscale_DO[action_reg[0]];
                141: cal_reg[8][11] <= grayscale_DO[action_reg[0]];
                142: cal_reg[8][12] <= grayscale_DO[action_reg[0]];
                143: cal_reg[8][13] <= grayscale_DO[action_reg[0]];
                144: cal_reg[8][14] <= grayscale_DO[action_reg[0]];
                145: cal_reg[8][15] <= grayscale_DO[action_reg[0]];

                // Row 9
                146: cal_reg[9][0] <= grayscale_DO[action_reg[0]];
                147: cal_reg[9][1] <= grayscale_DO[action_reg[0]];
                148: cal_reg[9][2] <= grayscale_DO[action_reg[0]];
                149: cal_reg[9][3] <= grayscale_DO[action_reg[0]];
                150: cal_reg[9][4] <= grayscale_DO[action_reg[0]];
                151: cal_reg[9][5] <= grayscale_DO[action_reg[0]];
                152: cal_reg[9][6] <= grayscale_DO[action_reg[0]];
                153: cal_reg[9][7] <= grayscale_DO[action_reg[0]];
                154: cal_reg[9][8] <= grayscale_DO[action_reg[0]];
                155: cal_reg[9][9] <= grayscale_DO[action_reg[0]];
                156: cal_reg[9][10] <= grayscale_DO[action_reg[0]];
                157: cal_reg[9][11] <= grayscale_DO[action_reg[0]];
                158: cal_reg[9][12] <= grayscale_DO[action_reg[0]];
                159: cal_reg[9][13] <= grayscale_DO[action_reg[0]];
                160: cal_reg[9][14] <= grayscale_DO[action_reg[0]];
                161: cal_reg[9][15] <= grayscale_DO[action_reg[0]];

                // Row 10
                162: cal_reg[10][0] <= grayscale_DO[action_reg[0]];
                163: cal_reg[10][1] <= grayscale_DO[action_reg[0]];
                164: cal_reg[10][2] <= grayscale_DO[action_reg[0]];
                165: cal_reg[10][3] <= grayscale_DO[action_reg[0]];
                166: cal_reg[10][4] <= grayscale_DO[action_reg[0]];
                167: cal_reg[10][5] <= grayscale_DO[action_reg[0]];
                168: cal_reg[10][6] <= grayscale_DO[action_reg[0]];
                169: cal_reg[10][7] <= grayscale_DO[action_reg[0]];
                170: cal_reg[10][8] <= grayscale_DO[action_reg[0]];
                171: cal_reg[10][9] <= grayscale_DO[action_reg[0]];
                172: cal_reg[10][10] <= grayscale_DO[action_reg[0]];
                173: cal_reg[10][11] <= grayscale_DO[action_reg[0]];
                174: cal_reg[10][12] <= grayscale_DO[action_reg[0]];
                175: cal_reg[10][13] <= grayscale_DO[action_reg[0]];
                176: cal_reg[10][14] <= grayscale_DO[action_reg[0]];
                177: cal_reg[10][15] <= grayscale_DO[action_reg[0]];

                // Row 11
                178: cal_reg[11][0] <= grayscale_DO[action_reg[0]];
                179: cal_reg[11][1] <= grayscale_DO[action_reg[0]];
                180: cal_reg[11][2] <= grayscale_DO[action_reg[0]];
                181: cal_reg[11][3] <= grayscale_DO[action_reg[0]];
                182: cal_reg[11][4] <= grayscale_DO[action_reg[0]];
                183: cal_reg[11][5] <= grayscale_DO[action_reg[0]];
                184: cal_reg[11][6] <= grayscale_DO[action_reg[0]];
                185: cal_reg[11][7] <= grayscale_DO[action_reg[0]];
                186: cal_reg[11][8] <= grayscale_DO[action_reg[0]];
                187: cal_reg[11][9] <= grayscale_DO[action_reg[0]];
                188: cal_reg[11][10] <= grayscale_DO[action_reg[0]];
                189: cal_reg[11][11] <= grayscale_DO[action_reg[0]];
                190: cal_reg[11][12] <= grayscale_DO[action_reg[0]];
                191: cal_reg[11][13] <= grayscale_DO[action_reg[0]];
                192: cal_reg[11][14] <= grayscale_DO[action_reg[0]];
                193: cal_reg[11][15] <= grayscale_DO[action_reg[0]];

                // Row 12
                194: cal_reg[12][0] <= grayscale_DO[action_reg[0]];
                195: cal_reg[12][1] <= grayscale_DO[action_reg[0]];
                196: cal_reg[12][2] <= grayscale_DO[action_reg[0]];
                197: cal_reg[12][3] <= grayscale_DO[action_reg[0]];
                198: cal_reg[12][4] <= grayscale_DO[action_reg[0]];
                199: cal_reg[12][5] <= grayscale_DO[action_reg[0]];
                200: cal_reg[12][6] <= grayscale_DO[action_reg[0]];
                201: cal_reg[12][7] <= grayscale_DO[action_reg[0]];
                202: cal_reg[12][8] <= grayscale_DO[action_reg[0]];
                203: cal_reg[12][9] <= grayscale_DO[action_reg[0]];
                204: cal_reg[12][10] <= grayscale_DO[action_reg[0]];
                205: cal_reg[12][11] <= grayscale_DO[action_reg[0]];
                206: cal_reg[12][12] <= grayscale_DO[action_reg[0]];
                207: cal_reg[12][13] <= grayscale_DO[action_reg[0]];
                208: cal_reg[12][14] <= grayscale_DO[action_reg[0]];
                209: cal_reg[12][15] <= grayscale_DO[action_reg[0]];

                // Row 13
                210: cal_reg[13][0] <= grayscale_DO[action_reg[0]];
                211: cal_reg[13][1] <= grayscale_DO[action_reg[0]];
                212: cal_reg[13][2] <= grayscale_DO[action_reg[0]];
                213: cal_reg[13][3] <= grayscale_DO[action_reg[0]];
                214: cal_reg[13][4] <= grayscale_DO[action_reg[0]];
                215: cal_reg[13][5] <= grayscale_DO[action_reg[0]];
                216: cal_reg[13][6] <= grayscale_DO[action_reg[0]];
                217: cal_reg[13][7] <= grayscale_DO[action_reg[0]];
                218: cal_reg[13][8] <= grayscale_DO[action_reg[0]];
                219: cal_reg[13][9] <= grayscale_DO[action_reg[0]];
                220: cal_reg[13][10] <= grayscale_DO[action_reg[0]];
                221: cal_reg[13][11] <= grayscale_DO[action_reg[0]];
                222: cal_reg[13][12] <= grayscale_DO[action_reg[0]];
                223: cal_reg[13][13] <= grayscale_DO[action_reg[0]];
                224: cal_reg[13][14] <= grayscale_DO[action_reg[0]];
                225: cal_reg[13][15] <= grayscale_DO[action_reg[0]];

                // Row 14
                226: cal_reg[14][0] <= grayscale_DO[action_reg[0]];
                227: cal_reg[14][1] <= grayscale_DO[action_reg[0]];
                228: cal_reg[14][2] <= grayscale_DO[action_reg[0]];
                229: cal_reg[14][3] <= grayscale_DO[action_reg[0]];
                230: cal_reg[14][4] <= grayscale_DO[action_reg[0]];
                231: cal_reg[14][5] <= grayscale_DO[action_reg[0]];
                232: cal_reg[14][6] <= grayscale_DO[action_reg[0]];
                233: cal_reg[14][7] <= grayscale_DO[action_reg[0]];
                234: cal_reg[14][8] <= grayscale_DO[action_reg[0]];
                235: cal_reg[14][9] <= grayscale_DO[action_reg[0]];
                236: cal_reg[14][10] <= grayscale_DO[action_reg[0]];
                237: cal_reg[14][11] <= grayscale_DO[action_reg[0]];
                238: cal_reg[14][12] <= grayscale_DO[action_reg[0]];
                239: cal_reg[14][13] <= grayscale_DO[action_reg[0]];
                240: cal_reg[14][14] <= grayscale_DO[action_reg[0]];
                241: cal_reg[14][15] <= grayscale_DO[action_reg[0]];

                // Row 15
                242: cal_reg[15][0] <= grayscale_DO[action_reg[0]];
                243: cal_reg[15][1] <= grayscale_DO[action_reg[0]];
                244: cal_reg[15][2] <= grayscale_DO[action_reg[0]];
                245: cal_reg[15][3] <= grayscale_DO[action_reg[0]];
                246: cal_reg[15][4] <= grayscale_DO[action_reg[0]];
                247: cal_reg[15][5] <= grayscale_DO[action_reg[0]];
                248: cal_reg[15][6] <= grayscale_DO[action_reg[0]];
                249: cal_reg[15][7] <= grayscale_DO[action_reg[0]];
                250: cal_reg[15][8] <= grayscale_DO[action_reg[0]];
                251: cal_reg[15][9] <= grayscale_DO[action_reg[0]];
                252: cal_reg[15][10] <= grayscale_DO[action_reg[0]];
                253: cal_reg[15][11] <= grayscale_DO[action_reg[0]];
                254: cal_reg[15][12] <= grayscale_DO[action_reg[0]];
                255: cal_reg[15][13] <= grayscale_DO[action_reg[0]];
                256: cal_reg[15][14] <= grayscale_DO[action_reg[0]];
                257: cal_reg[15][15] <= grayscale_DO[action_reg[0]];
            endcase
          
        end
    end
    else if (cs == IMG_FILTER ) begin
        if (image_size_reg == 0) begin
            case (counter)
                10: cal_reg[0] <= filter_map[0]; //8 
                14: cal_reg[1] <= filter_map[1]; //12 
                18: begin 
                    cal_reg[2] <= filter_map[0];
                    cal_reg[3] <= filter_map[1];
                end
            endcase
        end
        else if (image_size_reg == 1) begin
            case (counter)
                18: cal_reg[0] <= filter_map[0]; //16 
                26: cal_reg[1] <= filter_map[1]; //24 
                34: cal_reg[2] <= filter_map[0]; //32 
                42: cal_reg[3] <= filter_map[1];
                50: cal_reg[4] <= filter_map[0];
                58: cal_reg[5] <= filter_map[1];
                66: begin 
                    cal_reg[6] <= filter_map[0];
                    cal_reg[7] <= filter_map[1];
                end
            endcase
        end
        else if (image_size_reg == 2) begin
            case (counter)
                34: cal_reg[0] <= filter_map[0]; // 18 
                50: cal_reg[1] <= filter_map[1]; // 32 
                66: cal_reg[2] <= filter_map[0]; // 48 
                82: cal_reg[3] <= filter_map[1]; // 64 
                98: cal_reg[4] <= filter_map[0]; // 80 
                114: cal_reg[5] <= filter_map[1]; // 96 
                130: cal_reg[6] <= filter_map[0]; // 112 
                146: cal_reg[7] <= filter_map[1]; // 128 
                162: cal_reg[8] <= filter_map[0]; 
                178: cal_reg[9] <= filter_map[1]; 
                194: cal_reg[10] <= filter_map[0]; 
                210: cal_reg[11] <= filter_map[1]; 
                226: cal_reg[12] <= filter_map[0]; 
                242: cal_reg[13] <= filter_map[1]; 

                258: begin 
                    cal_reg[14] <= filter_map[0];
                    cal_reg[15] <= filter_map[1];
                end
            endcase
        end
    end
    
    else if (cs == MAX_POOLING) begin
        if (image_size_reg == 0) begin
            for (i = 0; i < 16; i = i + 1) begin
                cal_reg[i][0] <= cal_reg[i][0];
                cal_reg[i][1] <= cal_reg[i][1];
                cal_reg[i][2] <= cal_reg[i][2];
                cal_reg[i][3] <= cal_reg[i][3];

                cal_reg[i][4] <= cal_reg[i][4];
                cal_reg[i][5] <= cal_reg[i][5];
                cal_reg[i][6] <= cal_reg[i][6];
                cal_reg[i][7] <= cal_reg[i][7];

                cal_reg[i][8] <= cal_reg[i][8];
                cal_reg[i][9] <= cal_reg[i][9];
                cal_reg[i][10] <= cal_reg[i][10];
                cal_reg[i][11] <= cal_reg[i][11];

                cal_reg[i][12] <= cal_reg[i][12];
                cal_reg[i][13] <= cal_reg[i][13];
                cal_reg[i][14] <= cal_reg[i][14];
                cal_reg[i][15] <= cal_reg[i][15];
            end
        end
        else if (image_size_reg == 1) begin
            case (counter)
                1: cal_reg[0][0] <= max_poo;
                2: cal_reg[0][1] <= max_poo;
                3: cal_reg[0][2] <= max_poo;
                4: cal_reg[0][3] <= max_poo;

                5: cal_reg[1][0] <= max_poo;
                6: cal_reg[1][1] <= max_poo;
                7: cal_reg[1][2] <= max_poo;
                8: cal_reg[1][3] <= max_poo;

                9: cal_reg[2][0] <= max_poo;
                10: cal_reg[2][1] <= max_poo;
                11: cal_reg[2][2] <= max_poo;
                12: cal_reg[2][3] <= max_poo;

                13: cal_reg[3][0] <= max_poo;
                14: cal_reg[3][1] <= max_poo;
                15: cal_reg[3][2] <= max_poo;
                16: cal_reg[3][3] <= max_poo;
            endcase

        end
        else if (image_size_reg == 2) begin
            case (counter)
                1: cal_reg[0][0] <= max_poo;
                2: cal_reg[0][1] <= max_poo;
                3: cal_reg[0][2] <= max_poo;
                4: cal_reg[0][3] <= max_poo;
                5: cal_reg[0][4] <= max_poo;
                6: cal_reg[0][5] <= max_poo;
                7: cal_reg[0][6] <= max_poo;
                8: cal_reg[0][7] <= max_poo;

                9: cal_reg[1][0] <= max_poo;
                10: cal_reg[1][1] <= max_poo;
                11: cal_reg[1][2] <= max_poo;
                12: cal_reg[1][3] <= max_poo;
                13: cal_reg[1][4] <= max_poo;
                14: cal_reg[1][5] <= max_poo;
                15: cal_reg[1][6] <= max_poo;
                16: cal_reg[1][7] <= max_poo;

                // Add cases for the next rows
                17: cal_reg[2][0] <= max_poo;
                18: cal_reg[2][1] <= max_poo;
                19: cal_reg[2][2] <= max_poo;
                20: cal_reg[2][3] <= max_poo;
                21: cal_reg[2][4] <= max_poo;
                22: cal_reg[2][5] <= max_poo;
                23: cal_reg[2][6] <= max_poo;
                24: cal_reg[2][7] <= max_poo;

                25: cal_reg[3][0] <= max_poo;
                26: cal_reg[3][1] <= max_poo;
                27: cal_reg[3][2] <= max_poo;
                28: cal_reg[3][3] <= max_poo;
                29: cal_reg[3][4] <= max_poo;
                30: cal_reg[3][5] <= max_poo;
                31: cal_reg[3][6] <= max_poo;
                32: cal_reg[3][7] <= max_poo;

                33: cal_reg[4][0] <= max_poo;
                34: cal_reg[4][1] <= max_poo;
                35: cal_reg[4][2] <= max_poo;
                36: cal_reg[4][3] <= max_poo;
                37: cal_reg[4][4] <= max_poo;
                38: cal_reg[4][5] <= max_poo;
                39: cal_reg[4][6] <= max_poo;
                40: cal_reg[4][7] <= max_poo;

                41: cal_reg[5][0] <= max_poo;
                42: cal_reg[5][1] <= max_poo;
                43: cal_reg[5][2] <= max_poo;
                44: cal_reg[5][3] <= max_poo;
                45: cal_reg[5][4] <= max_poo;
                46: cal_reg[5][5] <= max_poo;
                47: cal_reg[5][6] <= max_poo;
                48: cal_reg[5][7] <= max_poo;

                49: cal_reg[6][0] <= max_poo;
                50: cal_reg[6][1] <= max_poo;
                51: cal_reg[6][2] <= max_poo;
                52: cal_reg[6][3] <= max_poo;
                53: cal_reg[6][4] <= max_poo;
                54: cal_reg[6][5] <= max_poo;
                55: cal_reg[6][6] <= max_poo;
                56: cal_reg[6][7] <= max_poo;

                57: cal_reg[7][0] <= max_poo;
                58: cal_reg[7][1] <= max_poo;
                59: cal_reg[7][2] <= max_poo;
                60: cal_reg[7][3] <= max_poo;
                61: cal_reg[7][4] <= max_poo;
                62: cal_reg[7][5] <= max_poo;
                63: cal_reg[7][6] <= max_poo;
                64: cal_reg[7][7] <= max_poo;

            endcase
        end
    end
    else if (cs == NEG && counter == 0) begin
        for (i = 0; i < 16; i = i + 1) begin
            cal_reg[i][0] <= 255 - cal_reg[i][0];
            cal_reg[i][1] <= 255 - cal_reg[i][1];
            cal_reg[i][2] <= 255 - cal_reg[i][2];
            cal_reg[i][3] <= 255 - cal_reg[i][3];

            cal_reg[i][4] <= 255 - cal_reg[i][4];
            cal_reg[i][5] <= 255 - cal_reg[i][5];
            cal_reg[i][6] <= 255 - cal_reg[i][6];
            cal_reg[i][7] <= 255 - cal_reg[i][7];

            cal_reg[i][8] <= 255 - cal_reg[i][8];
            cal_reg[i][9] <= 255 - cal_reg[i][9];
            cal_reg[i][10] <= 255 - cal_reg[i][10];
            cal_reg[i][11] <= 255 - cal_reg[i][11];

            cal_reg[i][12] <= 255 - cal_reg[i][12];
            cal_reg[i][13] <= 255 - cal_reg[i][13];
            cal_reg[i][14] <= 255 - cal_reg[i][14];
            cal_reg[i][15] <= 255 - cal_reg[i][15];
        end
    end
    else if (cs == HORI && counter == 0) begin
        if (image_size_reg == 0) begin
            for (i = 0; i < 4; i = i + 1) begin
                cal_reg[i][0] <= cal_reg[i][3];
                cal_reg[i][3] <= cal_reg[i][0];

                cal_reg[i][1] <= cal_reg[i][2];
                cal_reg[i][2] <= cal_reg[i][1];
            end
        end
        else if (image_size_reg == 1) begin
            for (i = 0; i < 8; i = i + 1) begin
                cal_reg[i][0] <= cal_reg[i][7];
                cal_reg[i][7] <= cal_reg[i][0];

                cal_reg[i][1] <= cal_reg[i][6];
                cal_reg[i][6] <= cal_reg[i][1];

                cal_reg[i][2] <= cal_reg[i][5];
                cal_reg[i][5] <= cal_reg[i][2];

                cal_reg[i][3] <= cal_reg[i][4];
                cal_reg[i][4] <= cal_reg[i][3];
            end
        end
        else if (image_size_reg == 2) begin
            for (i = 0; i < 16; i = i + 1) begin
                cal_reg[i][0] <= cal_reg[i][15];
                cal_reg[i][15] <= cal_reg[i][0];

                cal_reg[i][1] <= cal_reg[i][14];
                cal_reg[i][14] <= cal_reg[i][1];

                cal_reg[i][2] <= cal_reg[i][13];
                cal_reg[i][13] <= cal_reg[i][2];

                cal_reg[i][3] <= cal_reg[i][12];
                cal_reg[i][12] <= cal_reg[i][3];

                cal_reg[i][4] <= cal_reg[i][11];
                cal_reg[i][11] <= cal_reg[i][4];

                cal_reg[i][5] <= cal_reg[i][10];
                cal_reg[i][10] <= cal_reg[i][5];

                cal_reg[i][6] <= cal_reg[i][9];
                cal_reg[i][9] <= cal_reg[i][6];

                cal_reg[i][7] <= cal_reg[i][8];
                cal_reg[i][8] <= cal_reg[i][7];
            end
        end
    end
end
reg [7:0] sort[0:2][0:2];

always @(posedge clk ) begin ///////sort_in
if (cs == IMG_FILTER) begin
    if (image_size_reg == 0 && counter < 16) begin
        if (counter == 0) begin
           sort[0][0] <= cal_reg[0][0];
           sort[0][1] <= cal_reg[0][0];
           sort[0][2] <= cal_reg[0][1];

           sort[1][0] <= cal_reg[0][0];
           sort[1][1] <= cal_reg[0][0];
           sort[1][2] <= cal_reg[0][1];

           sort[2][0] <= cal_reg[1][0];
           sort[2][1] <= cal_reg[1][0];
           sort[2][2] <= cal_reg[1][1];  
        end
        else if  (counter == 3) begin
           sort[0][0] <= cal_reg[0][2];
           sort[0][1] <= cal_reg[0][3];
           sort[0][2] <= cal_reg[0][3];

           sort[1][0] <= cal_reg[0][2];
           sort[1][1] <= cal_reg[0][3];
           sort[1][2] <= cal_reg[0][3];

           sort[2][0] <= cal_reg[1][2];
           sort[2][1] <= cal_reg[1][3];
           sort[2][2] <= cal_reg[1][3];  
        end
        else if  (counter == 12) begin
           sort[0][0] <= cal_reg[2][0];
           sort[0][1] <= cal_reg[2][0];
           sort[0][2] <= cal_reg[2][1];

           sort[1][0] <= cal_reg[3][0];
           sort[1][1] <= cal_reg[3][0];
           sort[1][2] <= cal_reg[3][1];

           sort[2][0] <= cal_reg[3][0];
           sort[2][1] <= cal_reg[3][0];
           sort[2][2] <= cal_reg[3][1];  
        end
        else if  (counter == 15) begin
           sort[0][0] <= cal_reg[2][2];
           sort[0][1] <= cal_reg[2][3];
           sort[0][2] <= cal_reg[2][3];

           sort[1][0] <= cal_reg[3][2];
           sort[1][1] <= cal_reg[3][3];
           sort[1][2] <= cal_reg[3][3];

           sort[2][0] <= cal_reg[3][2];
           sort[2][1] <= cal_reg[3][3];
           sort[2][2] <= cal_reg[3][3];  
        end

        else if (counter / 4 == 0 ) begin
            sort[0][0] <= cal_reg[counter / 4 ][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 ][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 ][counter % 4 + 1];

            sort[1][0] <= cal_reg[counter / 4][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4 + 1];

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4 + 1];
        end

        else if (counter / 4 == 3 ) begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4 + 1];

            sort[1][0] <= cal_reg[counter / 4][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4 + 1];

            sort[2][0] <= cal_reg[counter / 4 ][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 ][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 ][counter % 4 + 1];
        end

        else if (counter % 4 == 0 ) begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4 + 1];

            sort[1][0] <= cal_reg[counter / 4][counter % 4];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4 + 1];

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4 + 1];
        end

        else if (counter % 4 == 3 ) begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4];

            sort[1][0] <= cal_reg[counter / 4][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4];

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4];
        end

        else begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4 + 1];

            sort[1][0] <= cal_reg[counter / 4 ][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4 ][counter % 4];
            sort[1][2] <= cal_reg[counter / 4 ][counter % 4 + 1];

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4 + 1]; 
        end
    end

    else if (image_size_reg == 1 && counter < 64) begin
        if (counter == 0) begin
           sort[0][0] <= cal_reg[0][0];
           sort[0][1] <= cal_reg[0][0];
           sort[0][2] <= cal_reg[0][1];

           sort[1][0] <= cal_reg[0][0];
           sort[1][1] <= cal_reg[0][0];
           sort[1][2] <= cal_reg[0][1];

           sort[2][0] <= cal_reg[1][0];
           sort[2][1] <= cal_reg[1][0];
           sort[2][2] <= cal_reg[1][1];  
        end
        else if  (counter == 7) begin
           sort[0][0] <= cal_reg[0][6];
           sort[0][1] <= cal_reg[0][7];
           sort[0][2] <= cal_reg[0][7];

           sort[1][0] <= cal_reg[0][6];
           sort[1][1] <= cal_reg[0][7];
           sort[1][2] <= cal_reg[0][7];

           sort[2][0] <= cal_reg[1][6];
           sort[2][1] <= cal_reg[1][7];
           sort[2][2] <= cal_reg[1][7];  
        end
        else if  (counter == 56) begin
           sort[0][0] <= cal_reg[6][0];
           sort[0][1] <= cal_reg[6][0];
           sort[0][2] <= cal_reg[6][1];

           sort[1][0] <= cal_reg[7][0];
           sort[1][1] <= cal_reg[7][0];
           sort[1][2] <= cal_reg[7][1];

           sort[2][0] <= cal_reg[7][0];
           sort[2][1] <= cal_reg[7][0];
           sort[2][2] <= cal_reg[7][1];  
        end
        else if  (counter == 63) begin
           sort[0][0] <= cal_reg[6][6];
           sort[0][1] <= cal_reg[6][7];
           sort[0][2] <= cal_reg[6][7];

           sort[1][0] <= cal_reg[7][6];
           sort[1][1] <= cal_reg[7][7];
           sort[1][2] <= cal_reg[7][7];

           sort[2][0] <= cal_reg[7][6];
           sort[2][1] <= cal_reg[7][7];
           sort[2][2] <= cal_reg[7][7];  
        end

        else if (counter / 8 == 0 ) begin
            sort[0][0] <= cal_reg[counter / 8 ][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 ][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 ][counter % 8 + 1];

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8 + 1];
        end

        else if (counter / 8 == 7 ) begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8 + 1];

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= cal_reg[counter / 8 ][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 ][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 ][counter % 8 + 1];
        end

        else if (counter % 8 == 0 ) begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8 + 1];

            sort[1][0] <= cal_reg[counter / 8][counter % 8];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8 + 1];
        end

        else if (counter % 8 == 7 ) begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8];

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8];

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8];
        end

        else begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8 + 1];

            sort[1][0] <= cal_reg[counter / 8 ][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8 ][counter % 8];
            sort[1][2] <= cal_reg[counter / 8 ][counter % 8 + 1];

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8 + 1]; 
        end
    end

    else if (image_size_reg == 2 && counter < 256) begin
        if (counter == 0) begin
           sort[0][0] <= cal_reg[0][0];
           sort[0][1] <= cal_reg[0][0];
           sort[0][2] <= cal_reg[0][1];

           sort[1][0] <= cal_reg[0][0];
           sort[1][1] <= cal_reg[0][0];
           sort[1][2] <= cal_reg[0][1];

           sort[2][0] <= cal_reg[1][0];
           sort[2][1] <= cal_reg[1][0];
           sort[2][2] <= cal_reg[1][1];  
        end
        else if  (counter == 15) begin
           sort[0][0] <= cal_reg[0][14];
           sort[0][1] <= cal_reg[0][15];
           sort[0][2] <= cal_reg[0][15];

           sort[1][0] <= cal_reg[0][14];
           sort[1][1] <= cal_reg[0][15];
           sort[1][2] <= cal_reg[0][15];

           sort[2][0] <= cal_reg[1][14];
           sort[2][1] <= cal_reg[1][15];
           sort[2][2] <= cal_reg[1][15];  
        end
        else if  (counter == 240) begin
           sort[0][0] <= cal_reg[14][0];
           sort[0][1] <= cal_reg[14][0];
           sort[0][2] <= cal_reg[14][1];

           sort[1][0] <= cal_reg[15][0];
           sort[1][1] <= cal_reg[15][0];
           sort[1][2] <= cal_reg[15][1];

           sort[2][0] <= cal_reg[15][0];
           sort[2][1] <= cal_reg[15][0];
           sort[2][2] <= cal_reg[15][1];  
        end
        else if  (counter == 255) begin
           sort[0][0] <= cal_reg[14][14];
           sort[0][1] <= cal_reg[14][15];
           sort[0][2] <= cal_reg[14][15];

           sort[1][0] <= cal_reg[15][14];
           sort[1][1] <= cal_reg[15][15];
           sort[1][2] <= cal_reg[15][15];

           sort[2][0] <= cal_reg[15][14];
           sort[2][1] <= cal_reg[15][15];
           sort[2][2] <= cal_reg[15][15];  
        end

        else if (counter / 16 == 0 ) begin
            sort[0][0] <= cal_reg[counter / 16 ][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 ][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 ][counter % 16 + 1];

            sort[1][0] <= cal_reg[counter / 16][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16 + 1];

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16 + 1];
        end

        else if (counter / 16 == 15 ) begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16 + 1];

            sort[1][0] <= cal_reg[counter / 16][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16 + 1];

            sort[2][0] <= cal_reg[counter / 16 ][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 ][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 ][counter % 16 + 1];
        end

        else if (counter % 16 == 0 ) begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16 + 1];

            sort[1][0] <= cal_reg[counter / 16][counter % 16];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16 + 1];

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16 + 1];
        end

        else if (counter % 16 == 15 ) begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16];

            sort[1][0] <= cal_reg[counter / 16][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16];

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16];
        end

        else begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16 + 1];

            sort[1][0] <= cal_reg[counter / 16 ][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16 ][counter % 16];
            sort[1][2] <= cal_reg[counter / 16 ][counter % 16 + 1];

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16 + 1]; 
        end
    end
end
////////////////////
else if (cs == CONV) begin
    if (image_size_reg == 0 && counter < 16) begin
        if (counter == 0) begin
           sort[0][0] <= 0;
           sort[0][1] <= 0;
           sort[0][2] <= 0;

           sort[1][0] <= 0;
           sort[1][1] <= cal_reg[0][0];
           sort[1][2] <= cal_reg[0][1];

           sort[2][0] <= 0;
           sort[2][1] <= cal_reg[1][0];
           sort[2][2] <= cal_reg[1][1];  
        end
        else if  (counter == 3) begin
           sort[0][0] <= 0;
           sort[0][1] <= 0;
           sort[0][2] <= 0;

           sort[1][0] <= cal_reg[0][2];
           sort[1][1] <= cal_reg[0][3];
           sort[1][2] <= 0;

           sort[2][0] <= cal_reg[1][2];
           sort[2][1] <= cal_reg[1][3];
           sort[2][2] <= 0;  
        end
        else if  (counter == 12) begin
           sort[0][0] <= 0;
           sort[0][1] <= cal_reg[2][0];
           sort[0][2] <= cal_reg[2][1];

           sort[1][0] <= 0;
           sort[1][1] <= cal_reg[3][0];
           sort[1][2] <= cal_reg[3][1];

           sort[2][0] <= 0;
           sort[2][1] <= 0;
           sort[2][2] <= 0;  
        end
        else if  (counter == 15) begin
           sort[0][0] <= cal_reg[2][2];
           sort[0][1] <= cal_reg[2][3];
           sort[0][2] <= 0;

           sort[1][0] <= cal_reg[3][2];
           sort[1][1] <= cal_reg[3][3];
           sort[1][2] <= 0;

           sort[2][0] <= 0;
           sort[2][1] <= 0;
           sort[2][2] <= 0;  
        end

        else if (counter / 4 == 0 ) begin
            sort[0][0] <= 0;
            sort[0][1] <= 0;
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[counter / 4][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4 + 1];

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4 + 1];
        end

        else if (counter / 4 == 3 ) begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4 + 1];

            sort[1][0] <= cal_reg[counter / 4][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4 + 1];

            sort[2][0] <= 0;
            sort[2][1] <= 0;
            sort[2][2] <= 0;
        end

        else if (counter % 4 == 0 ) begin
            sort[0][0] <= 0;
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4 + 1];

            sort[1][0] <= 0;
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= cal_reg[counter / 4][counter % 4 + 1];

            sort[2][0] <= 0;
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4 + 1];
        end

        else if (counter % 4 == 3 ) begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[counter / 4][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4][counter % 4];
            sort[1][2] <= 0;

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= 0;
        end

        else begin
            sort[0][0] <= cal_reg[counter / 4 - 1][counter % 4 - 1];
            sort[0][1] <= cal_reg[counter / 4 - 1][counter % 4];
            sort[0][2] <= cal_reg[counter / 4 - 1][counter % 4 + 1];

            sort[1][0] <= cal_reg[counter / 4 ][counter % 4 - 1];
            sort[1][1] <= cal_reg[counter / 4 ][counter % 4];
            sort[1][2] <= cal_reg[counter / 4 ][counter % 4 + 1];

            sort[2][0] <= cal_reg[counter / 4 + 1][counter % 4 - 1];
            sort[2][1] <= cal_reg[counter / 4 + 1][counter % 4];
            sort[2][2] <= cal_reg[counter / 4 + 1][counter % 4 + 1]; 
        end
    end
    else if (image_size_reg == 1 && counter < 64) begin
        if (counter == 0) begin
            sort[0][0] <= 0;
            sort[0][1] <= 0;
            sort[0][2] <= 0;

            sort[1][0] <= 0;
            sort[1][1] <= cal_reg[0][0];
            sort[1][2] <= cal_reg[0][1];

            sort[2][0] <= 0;
            sort[2][1] <= cal_reg[1][0];
            sort[2][2] <= cal_reg[1][1];  
            end
        else if (counter == 7) begin
            sort[0][0] <= 0;
            sort[0][1] <= 0;
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[0][6];
            sort[1][1] <= cal_reg[0][7];
            sort[1][2] <= 0;

            sort[2][0] <= cal_reg[1][6];
            sort[2][1] <= cal_reg[1][7];
            sort[2][2] <= 0;  
        end
        else if (counter == 56) begin
            sort[0][0] <= 0;
            sort[0][1] <= cal_reg[6][0];
            sort[0][2] <= cal_reg[6][1];

            sort[1][0] <= 0;
            sort[1][1] <= cal_reg[7][0];
            sort[1][2] <= cal_reg[7][1];

            sort[2][0] <= 0;
            sort[2][1] <= 0;
            sort[2][2] <= 0;  
        end
        else if (counter == 63) begin
            sort[0][0] <= cal_reg[6][6];
            sort[0][1] <= cal_reg[6][7];
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[7][6];
            sort[1][1] <= cal_reg[7][7];
            sort[1][2] <= 0;

            sort[2][0] <= 0;
            sort[2][1] <= 0;
            sort[2][2] <= 0;  
        end
        else if (counter / 8 == 0) begin
            sort[0][0] <= 0;
            sort[0][1] <= 0;
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8 + 1];
        end
        else if (counter / 8 == 7 ) begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8 + 1];

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= 0;
            sort[2][1] <= 0;
            sort[2][2] <= 0;
        end
        else if (counter % 8 == 0) begin
            sort[0][0] <= 0;
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8 + 1];

            sort[1][0] <= 0;
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= 0;
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8 + 1];
        end
        else if (counter % 8 == 7) begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= 0;

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= 0;
        end
        else begin
            sort[0][0] <= cal_reg[counter / 8 - 1][counter % 8 - 1];
            sort[0][1] <= cal_reg[counter / 8 - 1][counter % 8];
            sort[0][2] <= cal_reg[counter / 8 - 1][counter % 8 + 1];

            sort[1][0] <= cal_reg[counter / 8][counter % 8 - 1];
            sort[1][1] <= cal_reg[counter / 8][counter % 8];
            sort[1][2] <= cal_reg[counter / 8][counter % 8 + 1];

            sort[2][0] <= cal_reg[counter / 8 + 1][counter % 8 - 1];
            sort[2][1] <= cal_reg[counter / 8 + 1][counter % 8];
            sort[2][2] <= cal_reg[counter / 8 + 1][counter % 8 + 1]; 
        end
    end
    else if (image_size_reg == 2 && counter < 256) begin
        if (counter == 0) begin
           sort[0][0] <= 0;
           sort[0][1] <= 0;
           sort[0][2] <= 0;

           sort[1][0] <= 0;
           sort[1][1] <= cal_reg[0][0];
           sort[1][2] <= cal_reg[0][1];

           sort[2][0] <= 0;
           sort[2][1] <= cal_reg[1][0];
           sort[2][2] <= cal_reg[1][1];  
        end
        else if  (counter == 15) begin
           sort[0][0] <= 0;
           sort[0][1] <= 0;
           sort[0][2] <= 0;

           sort[1][0] <= cal_reg[0][14];
           sort[1][1] <= cal_reg[0][15];
           sort[1][2] <= 0;

           sort[2][0] <= cal_reg[1][14];
           sort[2][1] <= cal_reg[1][15];
           sort[2][2] <= 0;  
        end
        else if  (counter == 240) begin
           sort[0][0] <= 0;
           sort[0][1] <= cal_reg[14][0];
           sort[0][2] <= cal_reg[14][1];

           sort[1][0] <= 0;
           sort[1][1] <= cal_reg[15][0];
           sort[1][2] <= cal_reg[15][1];

           sort[2][0] <= 0;
           sort[2][1] <= 0;
           sort[2][2] <= 0;  
        end
        else if  (counter == 255) begin
           sort[0][0] <= cal_reg[14][14];
           sort[0][1] <= cal_reg[14][15];
           sort[0][2] <= 0;

           sort[1][0] <= cal_reg[15][14];
           sort[1][1] <= cal_reg[15][15];
           sort[1][2] <= 0;

           sort[2][0] <= 0;
           sort[2][1] <= 0;
           sort[2][2] <= 0;  
        end

        else if (counter / 16 == 0 ) begin
            sort[0][0] <= 0;
            sort[0][1] <= 0;
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[counter / 16][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16 + 1];

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16 + 1];
        end

        else if (counter / 16 == 15 ) begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16 + 1];

            sort[1][0] <= cal_reg[counter / 16][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16 + 1];

            sort[2][0] <= 0;
            sort[2][1] <= 0;
            sort[2][2] <= 0;
        end

        else if (counter % 16 == 0 ) begin
            sort[0][0] <= 0;
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16 + 1];

            sort[1][0] <= 0;
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= cal_reg[counter / 16][counter % 16 + 1];

            sort[2][0] <= 0;
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16 + 1];
        end

        else if (counter % 16 == 15 ) begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= 0;

            sort[1][0] <= cal_reg[counter / 16][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16][counter % 16];
            sort[1][2] <= 0;

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= 0;
        end

        else begin
            sort[0][0] <= cal_reg[counter / 16 - 1][counter % 16 - 1];
            sort[0][1] <= cal_reg[counter / 16 - 1][counter % 16];
            sort[0][2] <= cal_reg[counter / 16 - 1][counter % 16 + 1];

            sort[1][0] <= cal_reg[counter / 16 ][counter % 16 - 1];
            sort[1][1] <= cal_reg[counter / 16 ][counter % 16];
            sort[1][2] <= cal_reg[counter / 16 ][counter % 16 + 1];

            sort[2][0] <= cal_reg[counter / 16 + 1][counter % 16 - 1];
            sort[2][1] <= cal_reg[counter / 16 + 1][counter % 16];
            sort[2][2] <= cal_reg[counter / 16 + 1][counter % 16 + 1]; 
        end
    end
end
end


wire [7:0] sort_0;
wire [7:0] sort_1;
wire [7:0] sort_2;
wire [7:0] sort_3;
wire [7:0] sort_4;
wire [7:0] sort_5;
wire [7:0] sort_6;
wire [7:0] sort_7;
wire [7:0] sort_8;
wire [3:0] sum_0, sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8;
reg [7:0] mid;

assign sort_0[0] = (sort[0][0] > sort[0][1]) ? 1'b1 : 1'b0; // ab
assign sort_0[1] = (sort[0][0] > sort[0][2]) ? 1'b1 : 1'b0; // ac
assign sort_0[2] = (sort[0][0] > sort[1][0]) ? 1'b1 : 1'b0; // ad
assign sort_0[3] = (sort[0][0] > sort[1][1]) ? 1'b1 : 1'b0; // ae
assign sort_0[4] = (sort[0][0] > sort[1][2]) ? 1'b1 : 1'b0;
assign sort_0[5] = (sort[0][0] > sort[2][0]) ? 1'b1 : 1'b0;
assign sort_0[6] = (sort[0][0] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_0[7] = (sort[0][0] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_1[0] = ~sort_0[0]; // ba
assign sort_1[1] = (sort[0][1] > sort[0][2]) ? 1'b1 : 1'b0;
assign sort_1[2] = (sort[0][1] > sort[1][0]) ? 1'b1 : 1'b0;
assign sort_1[3] = (sort[0][1] > sort[1][1]) ? 1'b1 : 1'b0;
assign sort_1[4] = (sort[0][1] > sort[1][2]) ? 1'b1 : 1'b0;
assign sort_1[5] = (sort[0][1] > sort[2][0]) ? 1'b1 : 1'b0;
assign sort_1[6] = (sort[0][1] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_1[7] = (sort[0][1] > sort[2][2]) ? 1'b1 : 1'b0;


assign sort_2[0] = ~sort_0[1];
assign sort_2[1] = ~sort_1[1];
assign sort_2[2] = (sort[0][2] > sort[1][0]) ? 1'b1 : 1'b0; 
assign sort_2[3] = (sort[0][2] > sort[1][1]) ? 1'b1 : 1'b0; 
assign sort_2[4] = (sort[0][2] > sort[1][2]) ? 1'b1 : 1'b0;
assign sort_2[5] = (sort[0][2] > sort[2][0]) ? 1'b1 : 1'b0;
assign sort_2[6] = (sort[0][2] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_2[7] = (sort[0][2] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_3[0] = ~sort_0[2];
assign sort_3[1] = ~sort_1[2];
assign sort_3[2] = ~sort_2[2]; 
assign sort_3[3] = (sort[1][0] > sort[1][1]) ? 1'b1 : 1'b0; 
assign sort_3[4] = (sort[1][0] > sort[1][2]) ? 1'b1 : 1'b0;
assign sort_3[5] = (sort[1][0] > sort[2][0]) ? 1'b1 : 1'b0;
assign sort_3[6] = (sort[1][0] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_3[7] = (sort[1][0] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_4[0] = ~sort_0[3];
assign sort_4[1] = ~sort_1[3];
assign sort_4[2] = ~sort_2[3]; 
assign sort_4[3] = ~sort_3[3]; 
assign sort_4[4] = (sort[1][1] > sort[1][2]) ? 1'b1 : 1'b0;
assign sort_4[5] = (sort[1][1] > sort[2][0]) ? 1'b1 : 1'b0;
assign sort_4[6] = (sort[1][1] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_4[7] = (sort[1][1] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_5[0] = ~sort_0[4];
assign sort_5[1] = ~sort_1[4];
assign sort_5[2] = ~sort_2[4]; 
assign sort_5[3] = ~sort_3[4]; 
assign sort_5[4] = ~sort_4[4]; 
assign sort_5[5] = (sort[1][2] > sort[2][0]) ? 1'b1 : 1'b0;
assign sort_5[6] = (sort[1][2] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_5[7] = (sort[1][2] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_6[0] = ~sort_0[5];
assign sort_6[1] = ~sort_1[5];
assign sort_6[2] = ~sort_2[5]; 
assign sort_6[3] = ~sort_3[5]; 
assign sort_6[4] = ~sort_4[5]; 
assign sort_6[5] = ~sort_5[5];
assign sort_6[6] = (sort[2][0] > sort[2][1]) ? 1'b1 : 1'b0;
assign sort_6[7] = (sort[2][0] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_7[0] = ~sort_0[6];
assign sort_7[1] = ~sort_1[6];
assign sort_7[2] = ~sort_2[6]; 
assign sort_7[3] = ~sort_3[6]; 
assign sort_7[4] = ~sort_4[6]; 
assign sort_7[5] = ~sort_5[6];
assign sort_7[6] = ~sort_6[6];
assign sort_7[7] = (sort[2][1] > sort[2][2]) ? 1'b1 : 1'b0;

assign sort_8[0] = ~sort_0[7];
assign sort_8[1] = ~sort_1[7];
assign sort_8[2] = ~sort_2[7]; 
assign sort_8[3] = ~sort_3[7]; 
assign sort_8[4] = ~sort_4[7]; 
assign sort_8[5] = ~sort_5[7];
assign sort_8[6] = ~sort_6[7];
assign sort_8[7] = ~sort_7[7];

assign sum_0 = sort_0[0]+sort_0[1]+sort_0[2]+sort_0[3]+sort_0[4]+sort_0[5]+sort_0[6]+sort_0[7];
assign sum_1 = sort_1[0]+sort_1[1]+sort_1[2]+sort_1[3]+sort_1[4]+sort_1[5]+sort_1[6]+sort_1[7];
assign sum_2 = sort_2[0]+sort_2[1]+sort_2[2]+sort_2[3]+sort_2[4]+sort_2[5]+sort_2[6]+sort_2[7];
assign sum_3 = sort_3[0]+sort_3[1]+sort_3[2]+sort_3[3]+sort_3[4]+sort_3[5]+sort_3[6]+sort_3[7];
assign sum_4 = sort_4[0]+sort_4[1]+sort_4[2]+sort_4[3]+sort_4[4]+sort_4[5]+sort_4[6]+sort_4[7];
assign sum_5 = sort_5[0]+sort_5[1]+sort_5[2]+sort_5[3]+sort_5[4]+sort_5[5]+sort_5[6]+sort_5[7];
assign sum_6 = sort_6[0]+sort_6[1]+sort_6[2]+sort_6[3]+sort_6[4]+sort_6[5]+sort_6[6]+sort_6[7];
assign sum_7 = sort_7[0]+sort_7[1]+sort_7[2]+sort_7[3]+sort_7[4]+sort_7[5]+sort_7[6]+sort_7[7];
assign sum_8 = sort_8[0]+sort_8[1]+sort_8[2]+sort_8[3]+sort_8[4]+sort_8[5]+sort_8[6]+sort_8[7];

always @(posedge clk) begin
    if (cs == IMG_FILTER) begin
        if (sum_0 == 4) begin
            mid <= sort[0][0];
        end
        else if (sum_1 == 4) begin
            mid <= sort[0][1];
        end
        else if (sum_2 == 4) begin
            mid <= sort[0][2];
        end
        else if (sum_3 == 4) begin
            mid <= sort[1][0];
        end
        else if (sum_4 == 4) begin
            mid <= sort[1][1];
        end
        else if (sum_5 == 4) begin
            mid <= sort[1][2];
        end
        else if (sum_6 == 4) begin
            mid <= sort[2][0];
        end
        else if (sum_7 == 4) begin
            mid <= sort[2][1];
        end
        else if (sum_8 == 4) begin
            mid <= sort[2][2];
        end
    end
end
always @(posedge clk) begin
    if (cs == CONV) begin
    con_ans <=  sort[0][0]*temp_reg[0][0] + sort[0][1]*temp_reg[0][1] + sort[0][2]*temp_reg[0][2]+ 
                sort[1][0]*temp_reg[1][0] + sort[1][1]*temp_reg[1][1] + sort[1][2]*temp_reg[1][2]+ 
                sort[2][0]*temp_reg[2][0] + sort[2][1]*temp_reg[2][1] + sort[2][2]*temp_reg[2][2];
    end
end
reg [7:0] addr_out;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr_out <= 0;
    end
    else if (cs == WAIT) begin
        addr_out <= 0;
    end
    else if (cs == CONV && counter > 1) begin
        if (image_size_reg == 0 && counter < 17) begin
            addr_out <= addr_out + 1;
        end
        else if (image_size_reg == 1 && counter < 65) begin
            addr_out <= addr_out + 1;
        end
        else if (image_size_reg == 2 && counter < 257) begin
            addr_out <= addr_out + 1;
        end
        else if (image_size_reg == 0 && counter == 18) begin
            addr_out <= 0;
        end
        else if (image_size_reg == 1 && counter == 66) begin
            addr_out <= 0;
        end
        else if (image_size_reg == 2 && counter == 258) begin
            addr_out <= 0;
        end
        else addr_out <= addr_out;
    end
    else if (cs == OUT && counter_out_bit == 19) begin
        if (image_size_reg == 0 && addr_out == 15) begin
            addr_out <= 0;
        end
        else if (image_size_reg == 1 && addr_out == 63) begin
            addr_out <= 0;
        end
        else if (image_size_reg == 2 && addr_out == 255) begin
            addr_out <= 0;
        end
        else addr_out <= addr_out + 1;
    end

end
reg web_out;
reg out_time, out_time_seq;
reg [4:0] out_time_bit;
reg [19:0] out_reg;
reg [19:0] out_reg_seq;

always @(*)begin
	if(cs == CONV && counter > 1) web_out = 0;
    else web_out = 1;
end

MEM_20_int G4(.A(addr_out), .DO(out_reg), .DI(con_ans), .CK(clk), .WEB(web_out), .OE(1'b1), .CS(1'b1));

always @(posedge clk) begin
    out_reg_seq <= out_reg;
end

always @(posedge clk) begin
    if (cs == OUT)  out_time <= 1;
    else out_time <= 0;
end

always @(posedge clk) begin
    out_time_seq <= out_time;
end

always @(posedge clk) begin
    if (out_time_seq == 1) begin
        if (out_time_bit < 19) begin
            out_time_bit <= out_time_bit + 1;
        end
        else begin
            out_time_bit <=0;
        end
    end
    else if (out_time_seq == 0) begin
        out_time_bit <=0;
    end
end







always @(posedge clk) begin
    if (cs == IMG_FILTER && image_size_reg == 0) begin
        for (i = 4; i < 16; i = i + 1) begin
            filter_map[0][i] <= 0;
            filter_map[1][i] <= 0;
        end
        case (counter)
            2, 10: filter_map[0][0] <= mid;
            3, 11: filter_map[0][1] <= mid;
            4, 12: filter_map[0][2] <= mid;
            5, 13: filter_map[0][3] <= mid;

            6, 14: filter_map[1][0] <= mid;
            7, 15: filter_map[1][1] <= mid;
            8, 16: filter_map[1][2] <= mid;
            9, 17: filter_map[1][3] <= mid;
        endcase

    end
    else if (cs == IMG_FILTER && image_size_reg == 1) begin
        for (i = 8; i < 16; i = i + 1) begin
            filter_map[0][i] <= 0;
            filter_map[1][i] <= 0;
        end
        case (counter)
            2, 18, 34, 50 : filter_map[0][0] <= mid;
            3, 19, 35, 51 : filter_map[0][1] <= mid;
            4, 20, 36, 52 : filter_map[0][2] <= mid;
            5, 21, 37, 53 : filter_map[0][3] <= mid;
            6, 22, 38, 54 : filter_map[0][4] <= mid;
            7, 23, 39, 55 : filter_map[0][5] <= mid;
            8, 24, 40, 56 : filter_map[0][6] <= mid;
            9, 25, 41, 57 : filter_map[0][7] <= mid;

            10, 26, 42, 58 : filter_map[1][0] <= mid;
            11, 27, 43, 59 : filter_map[1][1] <= mid;
            12, 28, 44, 60 : filter_map[1][2] <= mid;
            13, 29, 45, 61 : filter_map[1][3] <= mid;
            14, 30, 46, 62 : filter_map[1][4] <= mid;
            15, 31, 47, 63 : filter_map[1][5] <= mid;
            16, 32, 48, 64 : filter_map[1][6] <= mid;
            17, 33, 49, 65 : filter_map[1][7] <= mid;
        endcase
    end
    else if (cs == IMG_FILTER && image_size_reg == 2) begin
        case (counter)
            2, 34, 66, 98, 130, 162, 194, 226 : filter_map[0][0] <= mid;
            3, 35, 67, 99, 131, 163, 195, 227 : filter_map[0][1] <= mid;
            4, 36, 68, 100, 132, 164, 196, 228 : filter_map[0][2] <= mid;
            5, 37, 69, 101, 133, 165, 197, 229 : filter_map[0][3] <= mid;
            6, 38, 70, 102, 134, 166, 198, 230 : filter_map[0][4] <= mid;
            7, 39, 71, 103, 135, 167, 199, 231 : filter_map[0][5] <= mid;
            8, 40, 72, 104, 136, 168, 200, 232 : filter_map[0][6] <= mid;
            9, 41, 73, 105, 137, 169, 201, 233 : filter_map[0][7] <= mid;
            
            10, 42, 74, 106, 138, 170, 202, 234 : filter_map[0][8] <= mid;
            11, 43, 75, 107, 139, 171, 203, 235 : filter_map[0][9] <= mid;
            12, 44, 76, 108, 140, 172, 204, 236 : filter_map[0][10] <= mid;
            13, 45, 77, 109, 141, 173, 205, 237 : filter_map[0][11] <= mid;
            14, 46, 78, 110, 142, 174, 206, 238 : filter_map[0][12] <= mid;
            15, 47, 79, 111, 143, 175, 207, 239 : filter_map[0][13] <= mid;
            16, 48, 80, 112, 144, 176, 208, 240 : filter_map[0][14] <= mid;
            17, 49, 81, 113, 145, 177, 209, 241 : filter_map[0][15] <= mid;

            18, 50, 82, 114, 146, 178, 210, 242 : filter_map[1][0] <= mid;
            19, 51, 83, 115, 147, 179, 211, 243 : filter_map[1][1] <= mid;
            20, 52, 84, 116, 148, 180, 212, 244 : filter_map[1][2] <= mid;
            21, 53, 85, 117, 149, 181, 213, 245 : filter_map[1][3] <= mid;
            22, 54, 86, 118, 150, 182, 214, 246 : filter_map[1][4] <= mid;
            23, 55, 87, 119, 151, 183, 215, 247 : filter_map[1][5] <= mid;
            24, 56, 88, 120, 152, 184, 216, 248 : filter_map[1][6] <= mid;
            25, 57, 89, 121, 153, 185, 217, 249 : filter_map[1][7] <= mid;

            26, 58, 90, 122, 154, 186, 218, 250 : filter_map[1][8] <= mid;
            27, 59, 91, 123, 155, 187, 219, 251 : filter_map[1][9] <= mid;
            28, 60, 92, 124, 156, 188, 220, 252 : filter_map[1][10] <= mid;
            29, 61, 93, 125, 157, 189, 221, 253 : filter_map[1][11] <= mid;
            30, 62, 94, 126, 158, 190, 222, 254 : filter_map[1][12] <= mid;
            31, 63, 95, 127, 159, 191, 223, 255 : filter_map[1][13] <= mid;
            32, 64, 96, 128, 160, 192, 224, 256 : filter_map[1][14] <= mid;
            33, 65, 97, 129, 161, 193, 225, 257 : filter_map[1][15] <= mid;
        endcase
    end
    /*
    else if (cs == CONV && image_size_reg == 0) begin
        for (i = 4; i < 16; i = i + 1) begin
            filter_map[0][i] <= 0;
            filter_map[1][i] <= 0;
        end
        case (counter)
            2, 10: filter_map[0][0] <= con_ans;
            3, 11: filter_map[0][1] <= con_ans;
            4, 12: filter_map[0][2] <= con_ans;
            5, 13: filter_map[0][3] <= con_ans;

            6, 14: filter_map[1][0] <= con_ans;
            7, 15: filter_map[1][1] <= con_ans;
            8, 16: filter_map[1][2] <= con_ans;
            9, 17: filter_map[1][3] <= con_ans;
        endcase
    end
    else if (cs == CONV && image_size_reg == 1) begin
        for (i = 8; i < 16; i = i + 1) begin
            filter_map[0][i] <= 0;
            filter_map[1][i] <= 0;
        end
        case (counter)
            2, 18, 34, 50 : filter_map[0][0] <= con_ans;
            3, 19, 35, 51 : filter_map[0][1] <= con_ans;
            4, 20, 36, 52 : filter_map[0][2] <= con_ans;
            5, 21, 37, 53 : filter_map[0][3] <= con_ans;
            6, 22, 38, 54 : filter_map[0][4] <= con_ans;
            7, 23, 39, 55 : filter_map[0][5] <= con_ans;
            8, 24, 40, 56 : filter_map[0][6] <= con_ans;
            9, 25, 41, 57 : filter_map[0][7] <= con_ans;

            10, 26, 42, 58 : filter_map[1][0] <= con_ans;
            11, 27, 43, 59 : filter_map[1][1] <= con_ans;
            12, 28, 44, 60 : filter_map[1][2] <= con_ans;
            13, 29, 45, 61 : filter_map[1][3] <= con_ans;
            14, 30, 46, 62 : filter_map[1][4] <= con_ans;
            15, 31, 47, 63 : filter_map[1][5] <= con_ans;
            16, 32, 48, 64 : filter_map[1][6] <= con_ans;
            17, 33, 49, 65 : filter_map[1][7] <= con_ans;
        endcase
    end
    else if (cs == CONV && image_size_reg == 2) begin
        case (counter)
            2, 34, 66, 98, 130, 162, 194, 226 : filter_map[0][0] <= con_ans;
            3, 35, 67, 99, 131, 163, 195, 227 : filter_map[0][1] <= con_ans;
            4, 36, 68, 100, 132, 164, 196, 228 : filter_map[0][2] <= con_ans;
            5, 37, 69, 101, 133, 165, 197, 229 : filter_map[0][3] <= con_ans;
            6, 38, 70, 102, 134, 166, 198, 230 : filter_map[0][4] <= con_ans;
            7, 39, 71, 103, 135, 167, 199, 231 : filter_map[0][5] <= con_ans;
            8, 40, 72, 104, 136, 168, 200, 232 : filter_map[0][6] <= con_ans;
            9, 41, 73, 105, 137, 169, 201, 233 : filter_map[0][7] <= con_ans;
            
            10, 42, 74, 106, 138, 170, 202, 234 : filter_map[0][8] <= con_ans;
            11, 43, 75, 107, 139, 171, 203, 235 : filter_map[0][9] <= con_ans;
            12, 44, 76, 108, 140, 172, 204, 236 : filter_map[0][10] <= con_ans;
            13, 45, 77, 109, 141, 173, 205, 237 : filter_map[0][11] <= con_ans;
            14, 46, 78, 110, 142, 174, 206, 238 : filter_map[0][12] <= con_ans;
            15, 47, 79, 111, 143, 175, 207, 239 : filter_map[0][13] <= con_ans;
            16, 48, 80, 112, 144, 176, 208, 240 : filter_map[0][14] <= con_ans;
            17, 49, 81, 113, 145, 177, 209, 241 : filter_map[0][15] <= con_ans;

            18, 50, 82, 114, 146, 178, 210, 242 : filter_map[1][0] <= con_ans;
            19, 51, 83, 115, 147, 179, 211, 243 : filter_map[1][1] <= con_ans;
            20, 52, 84, 116, 148, 180, 212, 244 : filter_map[1][2] <= con_ans;
            21, 53, 85, 117, 149, 181, 213, 245 : filter_map[1][3] <= con_ans;
            22, 54, 86, 118, 150, 182, 214, 246 : filter_map[1][4] <= con_ans;
            23, 55, 87, 119, 151, 183, 215, 247 : filter_map[1][5] <= con_ans;
            24, 56, 88, 120, 152, 184, 216, 248 : filter_map[1][6] <= con_ans;
            25, 57, 89, 121, 153, 185, 217, 249 : filter_map[1][7] <= con_ans;

            26, 58, 90, 122, 154, 186, 218, 250 : filter_map[1][8] <= con_ans;
            27, 59, 91, 123, 155, 187, 219, 251 : filter_map[1][9] <= con_ans;
            28, 60, 92, 124, 156, 188, 220, 252 : filter_map[1][10] <= con_ans;
            29, 61, 93, 125, 157, 189, 221, 253 : filter_map[1][11] <= con_ans;
            30, 62, 94, 126, 158, 190, 222, 254 : filter_map[1][12] <= con_ans;
            31, 63, 95, 127, 159, 191, 223, 255 : filter_map[1][13] <= con_ans;
            32, 64, 96, 128, 160, 192, 224, 256 : filter_map[1][14] <= con_ans;
            33, 65, 97, 129, 161, 193, 225, 257 : filter_map[1][15] <= con_ans;
        endcase
    end
    */
end

always @(posedge clk) begin
    if (cs == MAX_POOLING && image_size_reg == 1) begin
            max_sort[0][0] <= cal_reg[(counter / 4) *2][(counter % 4) *2];
            max_sort[0][1] <= cal_reg[(counter / 4) *2][(counter % 4) *2 + 1];
            max_sort[1][0] <= cal_reg[(counter / 4) *2 + 1][(counter % 4) *2];
            max_sort[1][1] <= cal_reg[(counter / 4) *2 + 1][(counter % 4) *2 + 1];

    end

    if (cs == MAX_POOLING && image_size_reg == 2) begin
            max_sort[0][0] <= cal_reg[counter / 8 *2][counter % 8 *2];
            max_sort[0][1] <= cal_reg[counter / 8 *2][counter % 8 *2 + 1];
            max_sort[1][0] <= cal_reg[counter / 8 *2 + 1][counter % 8 *2];
            max_sort[1][1] <= cal_reg[counter / 8 *2 + 1][counter % 8 *2 + 1];
    end

end


assign m_1 = (max_sort[0][0] > max_sort[0][1])? max_sort[0][0] : max_sort[0][1];
assign m_2 = (max_sort[1][0] > max_sort[1][1])? max_sort[1][0] : max_sort[1][1];
assign max_poo = (m_1 > m_2)? m_1 : m_2;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (out_time_seq == 1)begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_value <= 0;
    end
    else if (out_time_seq == 1)begin
        out_value <= out_reg_seq[19-out_time_bit];
    end
    else begin
        out_value <= 0;
    end
end

/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (cs == OUT)begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_value <= 0;
    end
    else if (cs == OUT)begin
        out_value <= cal_reg[counter][counter_out_add][19-counter_out_bit];
    end
    else begin
        out_value <= 0;
    end
end
*/

endmodule



module MEM_256_8_int(A, DO, DI, CK, WEB, OE, CS);
input [7:0] A;
input [7:0] DI;
input CK, CS, OE, WEB;
output [7:0] DO;

    MEM_256_8 U0(
        .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]),
        .DO0(DO[0]), .DO1(DO[1]), .DO2(DO[2]), .DO3(DO[3]), .DO4(DO[4]), .DO5(DO[5]), .DO6(DO[6]), .DO7(DO[7]), 
        .DI0(DI[0]), .DI1(DI[1]), .DI2(DI[2]), .DI3(DI[3]), .DI4(DI[4]), .DI5(DI[5]), .DI6(DI[6]), .DI7(DI[7]), 
        .CK(CK), .WEB(WEB), .OE(OE), .CS(CS)
    );
endmodule

module MEM_20_int(A, DO, DI, CK, WEB, OE, CS);
input [7:0] A;
input [19:0] DI;
input CK, CS, OE, WEB;
output [19:0] DO;

    MEM_20 U1(
        .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]),
        .DO0(DO[0]), .DO1(DO[1]), .DO2(DO[2]), .DO3(DO[3]), .DO4(DO[4]), .DO5(DO[5]), .DO6(DO[6]), .DO7(DO[7]),
        .DO8(DO[8]), .DO9(DO[9]), .DO10(DO[10]), .DO11(DO[11]), .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),
        .DO16(DO[16]), .DO17(DO[17]), .DO18(DO[18]), .DO19(DO[19]),
        .DI0(DI[0]), .DI1(DI[1]), .DI2(DI[2]), .DI3(DI[3]), .DI4(DI[4]), .DI5(DI[5]), .DI6(DI[6]), .DI7(DI[7]),
        .DI8(DI[8]), .DI9(DI[9]), .DI10(DI[10]), .DI11(DI[11]), .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]),
        .DI16(DI[16]), .DI17(DI[17]), .DI18(DI[18]), .DI19(DI[19]),  
        .CK(CK), .WEB(WEB), .OE(OE), .CS(CS)
    );
endmodule