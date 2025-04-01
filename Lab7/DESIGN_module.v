module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_row,
    in_kernel,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_data,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk;
input rst_n;
input in_valid;
input [17:0] in_row;
input [11:0] in_kernel;
input out_idle;
output reg handshake_sready;
output reg [29:0] handshake_din;
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [7:0] out_data;
// You can use the the custom flag ports for your design
output flag_clk1_to_fifo;
input flag_fifo_to_clk1;


localparam IDLE = 3'b000;
localparam READ = 3'b001;
localparam TRA = 3'b010;
localparam WAIT = 3'b011;
localparam OUT = 3'b100;

reg [2:0] cs_1, ns_1;
reg [13:0] count, count_din, count_final;
integer i,j;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs_1 <= IDLE;
    end else begin
        cs_1 <= ns_1;
    end
end

always @(*) begin
	case (cs_1)
		IDLE: begin
			if (in_valid == 1) ns_1 = READ;
            else ns_1 = cs_1;
		end
		READ: begin
            if (in_valid != 1) ns_1 = TRA;
            else ns_1 = cs_1;
		end
        TRA: begin
            if (count_din == 6) ns_1 = WAIT;
            else ns_1 = cs_1;
		end
        WAIT: begin
            if (flag_fifo_to_clk1) ns_1 = OUT;
            else ns_1 = cs_1;
        end
        OUT: begin
			if (count_final == 149) begin
                ns_1 = IDLE;
            end
            else begin
                ns_1 = cs_1;
            end
		end
		default:ns_1 = IDLE;

	endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= 0;
    else if (in_valid) count <= count + 1;
    else if (cs_1 == IDLE) count <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_final <= 0;
    else if (cs_1 == OUT && flag_fifo_to_clk1) count_final <= count_final + 1;
    //else if (cs_1 == OUT && count_final == 150) count_final <= 0;
    else if (cs_1 == IDLE) count_final <= 0;
end
reg [2:0] map [0:5][0:5];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6; i = i + 1) begin
            map[i][0] <= 0;
            map[i][1] <= 0;
            map[i][2] <= 0;
            map[i][3] <= 0;
            map[i][4] <= 0;
            map[i][5] <= 0;
        end
    end 
    else if (in_valid)begin
        case (count)
            0: map[0] <= {in_row[2:0],in_row[5:3],in_row[8:6],in_row[11:9],in_row[14:12],in_row[17:15]};
            1: map[1] <= {in_row[2:0],in_row[5:3],in_row[8:6],in_row[11:9],in_row[14:12],in_row[17:15]};
            2: map[2] <= {in_row[2:0],in_row[5:3],in_row[8:6],in_row[11:9],in_row[14:12],in_row[17:15]};
            3: map[3] <= {in_row[2:0],in_row[5:3],in_row[8:6],in_row[11:9],in_row[14:12],in_row[17:15]};
            4: map[4] <= {in_row[2:0],in_row[5:3],in_row[8:6],in_row[11:9],in_row[14:12],in_row[17:15]};
            5: map[5] <= {in_row[2:0],in_row[5:3],in_row[8:6],in_row[11:9],in_row[14:12],in_row[17:15]};
        endcase
    end
end

reg [2:0] kernal [0:5][0:3];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (j = 0; j < 6; j = j + 1) begin
            kernal[j][0] <= 0;
            kernal[j][1] <= 0;
            kernal[j][2] <= 0;
            kernal[j][3] <= 0;
        end
    end
    else if (in_valid)begin
        case (count)
            0: kernal[0] <= {in_kernel[2:0],in_kernel[5:3],in_kernel[8:6],in_kernel[11:9]};
            1: kernal[1] <= {in_kernel[2:0],in_kernel[5:3],in_kernel[8:6],in_kernel[11:9]};
            2: kernal[2] <= {in_kernel[2:0],in_kernel[5:3],in_kernel[8:6],in_kernel[11:9]};
            3: kernal[3] <= {in_kernel[2:0],in_kernel[5:3],in_kernel[8:6],in_kernel[11:9]};
            4: kernal[4] <= {in_kernel[2:0],in_kernel[5:3],in_kernel[8:6],in_kernel[11:9]};
            5: kernal[5] <= {in_kernel[2:0],in_kernel[5:3],in_kernel[8:6],in_kernel[11:9]};
        endcase
    end
end

//////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        handshake_sready <= 0;
    end
    else if (cs_1 == TRA && out_idle) begin
        handshake_sready <= 1;
    end
    else begin
        handshake_sready <= 0;
    end
end
///////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_din <= 0;
    else if (cs_1 == TRA  && out_idle) count_din <= count_din + 1;
    else if (cs_1 == IDLE) count_din <= 0;
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        handshake_din <= 0;
    end
    else if (cs_1 == TRA && out_idle) begin
        case (count_din)
            0: handshake_din <= {map[0][0],map[0][1],map[0][2],map[0][3],map[0][4],map[0][5]    ,kernal[0][0],kernal[0][1],kernal[0][2],kernal[0][3]};
            1: handshake_din <= {map[1][0],map[1][1],map[1][2],map[1][3],map[1][4],map[1][5]    ,kernal[1][0],kernal[1][1],kernal[1][2],kernal[1][3]};

            2: handshake_din <= {map[2][0],map[2][1],map[2][2],map[2][3],map[2][4],map[2][5]    ,kernal[2][0],kernal[2][1],kernal[2][2],kernal[2][3]};
            3: handshake_din <= {map[3][0],map[3][1],map[3][2],map[3][3],map[3][4],map[3][5]    ,kernal[3][0],kernal[3][1],kernal[3][2],kernal[3][3]};

            4: handshake_din <= {map[4][0],map[4][1],map[4][2],map[4][3],map[4][4],map[4][5]    ,kernal[4][0],kernal[4][1],kernal[4][2],kernal[4][3]};
            5: handshake_din <= {map[5][0],map[5][1],map[5][2],map[5][3],map[5][4],map[5][5]    ,kernal[5][0],kernal[5][1],kernal[5][2],kernal[5][3]};
        endcase
    end
    else begin
        handshake_din <= handshake_din;
    end
end

assign fifo_rinc = ~fifo_empty;



reg flag_fifo_to_clk1_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_fifo_to_clk1_reg <= 0;
    end
    
    else flag_fifo_to_clk1_reg <= flag_fifo_to_clk1;
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (cs_1 == OUT && flag_fifo_to_clk1_reg) out_valid <= 1;
    else out_valid <= 0;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else if (cs_1 == OUT && flag_fifo_to_clk1_reg) out_data <= fifo_rdata;
    else out_data <= 0;
end

endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid, //////dvalid
    fifo_full,
    in_data,
    out_valid,
    out_data,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [29:0] in_data;
output reg out_valid;
output reg [7:0] out_data;
output reg busy;

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;




localparam IDLE = 3'b000;
localparam READ = 3'b001;
localparam WAIT = 3'b010;
localparam CAL = 3'b011;
localparam OUT = 3'b100;


reg in_valid_2;
reg [2:0] cs_2, ns_2;
reg [13:0] count_d;
reg [13:0] count_conv;
reg [13:0] count_out;

reg [7:0] conv_ans_reg [0:149];
integer i,j;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_2 <= 0;
    end else begin
        in_valid_2 <= in_valid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs_2 <= IDLE;
    end else begin
        cs_2 <= ns_2;
    end
end

always @(*) begin
	case (cs_2)
		IDLE: begin
			if (in_valid == 1) ns_2 = READ;
            else ns_2 = cs_2;
		end
		READ: begin
            if (in_valid != 1 && count_d != 6) ns_2 = WAIT;
            else if (in_valid != 1 && count_d == 6) ns_2 = CAL;
            else ns_2 = cs_2;
		end
        WAIT: begin
            if (in_valid == 1) ns_2 = READ;
            else ns_2 = cs_2;
        end
        
        CAL: begin
            if (count_conv == 150) ns_2 = OUT;
            else ns_2 = cs_2;
		end
        
        OUT: begin
            if (count_out == 151) ns_2 = IDLE;
            else ns_2 = cs_2;
            end
		default:ns_2 = IDLE;

	endcase
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_out <= 0;
    else if (cs_2 == OUT && !fifo_full) count_out <= count_out + 1;
    else if (cs_2 == OUT && fifo_full) count_out <= count_out;
    else if (cs_2 == IDLE) count_out <= 0;
end


always @(*) begin
    if (cs_2 == OUT && !fifo_full) out_valid = 1;
    else  out_valid = 0;
end

/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_valid <= 0;
    else if (cs_2 == OUT ) out_valid <= 1;
    else  out_valid <= 0;
end
*/
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_data <= 0;
    else if (cs_2 == OUT && count_out <= 149) out_data <= conv_ans_reg[count_out];
    else  out_data <= 0;
end
*/

always @(*) begin
    
   if (out_valid == 1 && count_out < 151) out_data = conv_ans_reg[count_out];
    else  out_data = 0;
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_d <= 0;
    else if (in_valid && !in_valid_2) count_d <= count_d + 1;
    else if (cs_2 == IDLE) count_d <= 0;
end

reg [2:0] map_conv [0:5][0:5];
reg [2:0] kernal_conv [0:5][0:3];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6; i = i + 1) begin
            map_conv[i][0] <= 0;
            map_conv[i][1] <= 0;
            map_conv[i][2] <= 0;
            map_conv[i][3] <= 0;
            map_conv[i][4] <= 0;
            map_conv[i][5] <= 0;
        end
    end 
    else if (cs_2 == READ)begin
        case (count_d)
            1: begin
                map_conv[0][0] <= in_data[29:27];
                map_conv[0][1] <= in_data[26:24];
                map_conv[0][2] <= in_data[23:21];
                map_conv[0][3] <= in_data[20:18];
                map_conv[0][4] <= in_data[17:15];
                map_conv[0][5] <= in_data[14:12];
            end
            2: begin
                map_conv[1][0] <= in_data[29:27];
                map_conv[1][1] <= in_data[26:24];
                map_conv[1][2] <= in_data[23:21];
                map_conv[1][3] <= in_data[20:18];
                map_conv[1][4] <= in_data[17:15];
                map_conv[1][5] <= in_data[14:12];
            end
            3: begin
                map_conv[2][0] <= in_data[29:27];
                map_conv[2][1] <= in_data[26:24];
                map_conv[2][2] <= in_data[23:21];
                map_conv[2][3] <= in_data[20:18];
                map_conv[2][4] <= in_data[17:15];
                map_conv[2][5] <= in_data[14:12];
            end
            4: begin
                map_conv[3][0] <= in_data[29:27];
                map_conv[3][1] <= in_data[26:24];
                map_conv[3][2] <= in_data[23:21];
                map_conv[3][3] <= in_data[20:18];
                map_conv[3][4] <= in_data[17:15];
                map_conv[3][5] <= in_data[14:12];
            end
            5: begin
                map_conv[4][0] <= in_data[29:27];
                map_conv[4][1] <= in_data[26:24];
                map_conv[4][2] <= in_data[23:21];
                map_conv[4][3] <= in_data[20:18];
                map_conv[4][4] <= in_data[17:15];
                map_conv[4][5] <= in_data[14:12];
            end
            6: begin
                map_conv[5][0] <= in_data[29:27];
                map_conv[5][1] <= in_data[26:24];
                map_conv[5][2] <= in_data[23:21];
                map_conv[5][3] <= in_data[20:18];
                map_conv[5][4] <= in_data[17:15];
                map_conv[5][5] <= in_data[14:12];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6; i = i + 1) begin
            kernal_conv[i][0] <= 0;
            kernal_conv[i][1] <= 0;
            kernal_conv[i][2] <= 0;
            kernal_conv[i][3] <= 0;
        end
    end
    else if (cs_2 == READ)begin
        case (count_d)
            1: begin
                kernal_conv[0][0] <= in_data[11:9];
                kernal_conv[0][1] <= in_data[8:6];
                kernal_conv[0][2] <= in_data[5:3];
                kernal_conv[0][3] <= in_data[2:0];
            end
            2: begin
                kernal_conv[1][0] <= in_data[11:9];
                kernal_conv[1][1] <= in_data[8:6];
                kernal_conv[1][2] <= in_data[5:3];
                kernal_conv[1][3] <= in_data[2:0];
            end
            3: begin
                kernal_conv[2][0] <= in_data[11:9];
                kernal_conv[2][1] <= in_data[8:6];
                kernal_conv[2][2] <= in_data[5:3];
                kernal_conv[2][3] <= in_data[2:0];
            end
            4: begin
                kernal_conv[3][0] <= in_data[11:9];
                kernal_conv[3][1] <= in_data[8:6];
                kernal_conv[3][2] <= in_data[5:3];
                kernal_conv[3][3] <= in_data[2:0];
            end
            5: begin
                kernal_conv[4][0] <= in_data[11:9];
                kernal_conv[4][1] <= in_data[8:6];
                kernal_conv[4][2] <= in_data[5:3];
                kernal_conv[4][3] <= in_data[2:0];
            end
            6: begin
                kernal_conv[5][0] <= in_data[11:9];
                kernal_conv[5][1] <= in_data[8:6];
                kernal_conv[5][2] <= in_data[5:3];
                kernal_conv[5][3] <= in_data[2:0];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_conv <= 0;
    else if (cs_2 == CAL && count_conv < 150) count_conv <= count_conv + 1;
    else if (cs_2 == CAL && count_conv == 150) count_conv <= 0;
    else if (cs_2 == IDLE) count_conv <= 0;
end

reg [2:0] cal_map_conv [0:3];
reg [2:0] cal_kernal_conv [0:3];
reg [7:0] conv_ans;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cal_map_conv[0] <= 0;
        cal_map_conv[1] <= 0;
        cal_map_conv[2] <= 0;
        cal_map_conv[3] <= 0;
    end
    else if (cs_2 == CAL) begin
        case(count_conv % 25)
            0: begin
                cal_map_conv[0] <= map_conv[0][0];
                cal_map_conv[1] <= map_conv[0][1];
                cal_map_conv[2] <= map_conv[1][0];
                cal_map_conv[3] <= map_conv[1][1];
            end
            1: begin
                cal_map_conv[0] <= map_conv[0][1];
                cal_map_conv[1] <= map_conv[0][2];
                cal_map_conv[2] <= map_conv[1][1];
                cal_map_conv[3] <= map_conv[1][2];
            end
            2: begin
                cal_map_conv[0] <= map_conv[0][2];
                cal_map_conv[1] <= map_conv[0][3];
                cal_map_conv[2] <= map_conv[1][2];
                cal_map_conv[3] <= map_conv[1][3];
            end
            3: begin
                cal_map_conv[0] <= map_conv[0][3];
                cal_map_conv[1] <= map_conv[0][4];
                cal_map_conv[2] <= map_conv[1][3];
                cal_map_conv[3] <= map_conv[1][4];
            end
            4: begin
                cal_map_conv[0] <= map_conv[0][4];
                cal_map_conv[1] <= map_conv[0][5];
                cal_map_conv[2] <= map_conv[1][4];
                cal_map_conv[3] <= map_conv[1][5];
            end


            5: begin
                cal_map_conv[0] <= map_conv[1][0];
                cal_map_conv[1] <= map_conv[1][1];
                cal_map_conv[2] <= map_conv[2][0];
                cal_map_conv[3] <= map_conv[2][1];
            end
            6: begin
                cal_map_conv[0] <= map_conv[1][1];
                cal_map_conv[1] <= map_conv[1][2];
                cal_map_conv[2] <= map_conv[2][1];
                cal_map_conv[3] <= map_conv[2][2];
            end
            7: begin
                cal_map_conv[0] <= map_conv[1][2];
                cal_map_conv[1] <= map_conv[1][3];
                cal_map_conv[2] <= map_conv[2][2];
                cal_map_conv[3] <= map_conv[2][3];
            end
            8: begin
                cal_map_conv[0] <= map_conv[1][3];
                cal_map_conv[1] <= map_conv[1][4];
                cal_map_conv[2] <= map_conv[2][3];
                cal_map_conv[3] <= map_conv[2][4];
            end
            9: begin
                cal_map_conv[0] <= map_conv[1][4];
                cal_map_conv[1] <= map_conv[1][5];
                cal_map_conv[2] <= map_conv[2][4];
                cal_map_conv[3] <= map_conv[2][5];
            end


            10: begin
                cal_map_conv[0] <= map_conv[2][0];
                cal_map_conv[1] <= map_conv[2][1];
                cal_map_conv[2] <= map_conv[3][0];
                cal_map_conv[3] <= map_conv[3][1];
            end
            11: begin
                cal_map_conv[0] <= map_conv[2][1];
                cal_map_conv[1] <= map_conv[2][2];
                cal_map_conv[2] <= map_conv[3][1];
                cal_map_conv[3] <= map_conv[3][2];
            end
            12: begin
                cal_map_conv[0] <= map_conv[2][2];
                cal_map_conv[1] <= map_conv[2][3];
                cal_map_conv[2] <= map_conv[3][2];
                cal_map_conv[3] <= map_conv[3][3];
            end
            13: begin
                cal_map_conv[0] <= map_conv[2][3];
                cal_map_conv[1] <= map_conv[2][4];
                cal_map_conv[2] <= map_conv[3][3];
                cal_map_conv[3] <= map_conv[3][4];
            end
            14: begin
                cal_map_conv[0] <= map_conv[2][4];
                cal_map_conv[1] <= map_conv[2][5];
                cal_map_conv[2] <= map_conv[3][4];
                cal_map_conv[3] <= map_conv[3][5];
            end


            15: begin
                cal_map_conv[0] <= map_conv[3][0];
                cal_map_conv[1] <= map_conv[3][1];
                cal_map_conv[2] <= map_conv[4][0];
                cal_map_conv[3] <= map_conv[4][1];
            end
            16: begin
                cal_map_conv[0] <= map_conv[3][1];
                cal_map_conv[1] <= map_conv[3][2];
                cal_map_conv[2] <= map_conv[4][1];
                cal_map_conv[3] <= map_conv[4][2];
            end
            17: begin
                cal_map_conv[0] <= map_conv[3][2];
                cal_map_conv[1] <= map_conv[3][3];
                cal_map_conv[2] <= map_conv[4][2];
                cal_map_conv[3] <= map_conv[4][3];
            end
            18: begin
                cal_map_conv[0] <= map_conv[3][3];
                cal_map_conv[1] <= map_conv[3][4];
                cal_map_conv[2] <= map_conv[4][3];
                cal_map_conv[3] <= map_conv[4][4];
            end
            19: begin
                cal_map_conv[0] <= map_conv[3][4];
                cal_map_conv[1] <= map_conv[3][5];
                cal_map_conv[2] <= map_conv[4][4];
                cal_map_conv[3] <= map_conv[4][5];
            end

            20: begin
                cal_map_conv[0] <= map_conv[4][0];
                cal_map_conv[1] <= map_conv[4][1];
                cal_map_conv[2] <= map_conv[5][0];
                cal_map_conv[3] <= map_conv[5][1];
            end
            21: begin
                cal_map_conv[0] <= map_conv[4][1];
                cal_map_conv[1] <= map_conv[4][2];
                cal_map_conv[2] <= map_conv[5][1];
                cal_map_conv[3] <= map_conv[5][2];
            end
            22: begin
                cal_map_conv[0] <= map_conv[4][2];
                cal_map_conv[1] <= map_conv[4][3];
                cal_map_conv[2] <= map_conv[5][2];
                cal_map_conv[3] <= map_conv[5][3];
            end
            23: begin
                cal_map_conv[0] <= map_conv[4][3];
                cal_map_conv[1] <= map_conv[4][4];
                cal_map_conv[2] <= map_conv[5][3];
                cal_map_conv[3] <= map_conv[5][4];
            end
            24: begin
                cal_map_conv[0] <= map_conv[4][4];
                cal_map_conv[1] <= map_conv[4][5];
                cal_map_conv[2] <= map_conv[5][4];
                cal_map_conv[3] <= map_conv[5][5];
            end
        endcase 
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cal_kernal_conv[0] <= 0;
        cal_kernal_conv[1] <= 0;
        cal_kernal_conv[2] <= 0;
        cal_kernal_conv[3] <= 0;
    end
    else if (cs_2 == CAL) begin
        case(count_conv / 25)
            0: begin
                cal_kernal_conv[0] <= kernal_conv[0][0];
                cal_kernal_conv[1] <= kernal_conv[0][1];
                cal_kernal_conv[2] <= kernal_conv[0][2];
                cal_kernal_conv[3] <= kernal_conv[0][3];
            end
            1: begin
                cal_kernal_conv[0] <= kernal_conv[1][0];
                cal_kernal_conv[1] <= kernal_conv[1][1];
                cal_kernal_conv[2] <= kernal_conv[1][2];
                cal_kernal_conv[3] <= kernal_conv[1][3];
            end
            2: begin
                cal_kernal_conv[0] <= kernal_conv[2][0];
                cal_kernal_conv[1] <= kernal_conv[2][1];
                cal_kernal_conv[2] <= kernal_conv[2][2];
                cal_kernal_conv[3] <= kernal_conv[2][3];
            end
            3: begin
                cal_kernal_conv[0] <= kernal_conv[3][0];
                cal_kernal_conv[1] <= kernal_conv[3][1];
                cal_kernal_conv[2] <= kernal_conv[3][2];
                cal_kernal_conv[3] <= kernal_conv[3][3];
            end
            4: begin
                cal_kernal_conv[0] <= kernal_conv[4][0];
                cal_kernal_conv[1] <= kernal_conv[4][1];
                cal_kernal_conv[2] <= kernal_conv[4][2];
                cal_kernal_conv[3] <= kernal_conv[4][3];
            end
            5: begin
                cal_kernal_conv[0] <= kernal_conv[5][0];
                cal_kernal_conv[1] <= kernal_conv[5][1];
                cal_kernal_conv[2] <= kernal_conv[5][2];
                cal_kernal_conv[3] <= kernal_conv[5][3];
            end
        endcase
    end
end

always @(*) begin
    conv_ans = cal_map_conv[0]*cal_kernal_conv[0] + cal_map_conv[1]*cal_kernal_conv[1] + cal_map_conv[2]*cal_kernal_conv[2] + cal_map_conv[3]*cal_kernal_conv[3];
end




genvar k;
generate
    for (k = 0; k < 150; k = k + 1) begin: conv_rrrrrr
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                    conv_ans_reg[k] <= 0;
                end
            else if (cs_2 == CAL) begin
                if (count_conv == k+1) begin
                   conv_ans_reg[k] <= conv_ans;
                end
            end
            end
        end
endgenerate 






always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        busy <= 1;
    end 
    else if (cs_2 == IDLE) begin
        busy <= 0;
    end
    else if (cs_2 == READ) begin
        busy <= 0;
    end
    else if (cs_2 == WAIT) begin
        busy <= 0;
    end
    else if (cs_2 == CAL) begin
        busy <= 1;
    end
    else if (cs_2 == OUT) begin
        busy <= 1;
    end
end



endmodule