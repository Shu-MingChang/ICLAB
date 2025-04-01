//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/9
//		Version		: v1.0
//   	File Name   : MDC.v
//   	Module Name : MDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "HAMMING_IP.v"
//synopsys translate_on

module MDC(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Output signals
    out_valid, 
	out_data
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [8:0] in_mode;
input [14:0] in_data;

output reg out_valid;
output reg [206:0] out_data;
//////////////////////////////////////////////////////
integer j;
parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter CAL = 2'b10;
parameter OUT = 2'b11;


reg [1:0] cs, ns;

reg [8:0] in_mode_reg;
reg [14:0] in_data_reg;
reg  [4:0] mode_decode;
reg signed [10:0] data_decode;

reg signed [10:0] data_map[0:3][0:3];
reg [4:0] mode_map;
reg [7:0] count;

////////////////////


HAMMING_IP #(.IP_BIT(5)) in_mode_ip (.IN_code(in_mode_reg), .OUT_code(mode_decode));
HAMMING_IP #(.IP_BIT(11)) in_data_ip (.IN_code(in_data_reg), .OUT_code(data_decode));







always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_mode_reg <= 0;
    end 
    else if (cs == IDLE && ns == READ)begin
        in_mode_reg <= in_mode;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_data_reg <= 0;
    end 
    else if (in_valid)begin
        in_data_reg <= in_data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= 0;
    else if (cs == READ && count < 15) count <= count + 1;
    else if (cs == READ && count == 15) count <= 0;
    else if (cs == CAL && mode_map == 5'b10110 && count < 6) count <= count + 1;
    else if (cs == CAL && mode_map == 5'b10110 && count == 6) count <= 0;
    else if (cs == CAL && mode_map == 5'b00110 && count < 2) count <= count + 1;
    else if (cs == CAL && mode_map == 5'b00110 && count == 2) count <= 0;
    else if (cs == CAL && mode_map == 5'b00100 && count < 1) count <= count + 1;
    else if (cs == CAL && mode_map == 5'b00100 && count == 1) count <= 0;     
    else if (cs == IDLE) count <= 0;

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
			if (in_valid != 1)  begin
                ns = CAL;
            end
            else begin
                ns = cs;
            end
		end
        
        CAL: begin
			if (mode_map == 5'b10110 && count == 6) begin
                ns = OUT;
            end
            else if (mode_map == 5'b00110 && count == 2) begin
                ns = OUT;
            end
            else if (mode_map == 5'b00100 && count == 1) begin
                ns = OUT;
            end
            else begin
                ns = cs;
            end
		end
        
        OUT: begin
			if (count == 0) begin
                ns = IDLE;
            end
            else begin
                ns = cs;
            end
		end
		default:ns = IDLE;

	endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (j = 0; j < 4; j = j + 1) begin
            data_map[j][0] <= 0;
            data_map[j][1] <= 0;
            data_map[j][2] <= 0;
            data_map[j][3] <= 0;
        end
    end
    else if (cs == READ)begin
        case (count)
            0: data_map[0][0] <= data_decode;
            1: data_map[0][1] <= data_decode;
            2: data_map[0][2] <= data_decode;
            3: data_map[0][3] <= data_decode;
            4: data_map[1][0] <= data_decode;
            5: data_map[1][1] <= data_decode;
            6: data_map[1][2] <= data_decode;
            7: data_map[1][3] <= data_decode;
            8: data_map[2][0] <= data_decode;
            9: data_map[2][1] <= data_decode;
            10: data_map[2][2] <= data_decode;
            11: data_map[2][3] <= data_decode;
            12: data_map[3][0] <= data_decode;
            13: data_map[3][1] <= data_decode;
            14: data_map[3][2] <= data_decode;
            15: data_map[3][3] <= data_decode;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode_map <= 0;
    end
    else if (cs == READ && count == 0)begin
        mode_map <= mode_decode;

    end

end
reg signed [10:0] det [0:1][0:1];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det[0][0] <= 0;
        det[0][1] <= 0;
        det[1][0] <= 0;
        det[1][1] <= 0;
    end
    else if (cs == READ &&  mode_map == 5'b00100)begin
        case (count)
            8: begin
                det[0][0] <= data_map[0][0];
                det[0][1] <= data_map[0][1];
                det[1][0] <= data_map[1][0];
                det[1][1] <= data_map[1][1];
            end
            9: begin
                det[0][0] <= data_map[0][1];
                det[0][1] <= data_map[0][2];
                det[1][0] <= data_map[1][1];
                det[1][1] <= data_map[1][2];
            end
            10: begin
                det[0][0] <= data_map[0][2];
                det[0][1] <= data_map[0][3];
                det[1][0] <= data_map[1][2];
                det[1][1] <= data_map[1][3];
            end
            11: begin
                det[0][0] <= data_map[1][0];
                det[0][1] <= data_map[1][1];
                det[1][0] <= data_map[2][0];
                det[1][1] <= data_map[2][1];
            end
            12: begin
                det[0][0] <= data_map[1][1];
                det[0][1] <= data_map[1][2];
                det[1][0] <= data_map[2][1];
                det[1][1] <= data_map[2][2];
            end
            13: begin
                det[0][0] <= data_map[1][2];
                det[0][1] <= data_map[1][3];
                det[1][0] <= data_map[2][2];
                det[1][1] <= data_map[2][3];
            end
            14: begin
                det[0][0] <= data_map[2][0];
                det[0][1] <= data_map[2][1];
                det[1][0] <= data_map[3][0];
                det[1][1] <= data_map[3][1];
            end
            15: begin
                det[0][0] <= data_map[2][1];
                det[0][1] <= data_map[2][2];
                det[1][0] <= data_map[3][1];
                det[1][1] <= data_map[3][2];
            end
            17: begin 
                det[0][0] <= 0;
                det[0][1] <= 0;
                det[1][0] <= 0;
                det[1][1] <= 0;
            end
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b00100) begin
        case (count)
            0: begin
                det[0][0] <= data_map[2][2];
                det[0][1] <= data_map[2][3];
                det[1][0] <= data_map[3][2];
                det[1][1] <= data_map[3][3];
            end
        endcase
    end
    else if (cs == READ &&  mode_map == 5'b00110)begin
        case (count)
            12: begin
                det[0][0] <= data_map[1][1];
                det[0][1] <= data_map[1][2];
                det[1][0] <= data_map[2][1];
                det[1][1] <= data_map[2][2];
            end
            13: begin
                det[0][0] <= data_map[0][1];
                det[0][1] <= data_map[0][2];
                det[1][0] <= data_map[2][1];
                det[1][1] <= data_map[2][2];
            end
            14: begin
                det[0][0] <= data_map[0][1];
                det[0][1] <= data_map[0][2];
                det[1][0] <= data_map[1][1];
                det[1][1] <= data_map[1][2];
            end
            15: begin
                det[0][0] <= data_map[2][1];
                det[0][1] <= data_map[2][2];
                det[1][0] <= data_map[3][1];
                det[1][1] <= data_map[3][2];
            end
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b00110)begin
        case (count)
            0: begin
                det[0][0] <= data_map[1][1];
                det[0][1] <= data_map[1][2];
                det[1][0] <= data_map[3][1];
                det[1][1] <= data_map[3][2];
            end
            1: begin
                det[0][0] <= data_map[1][1];
                det[0][1] <= data_map[1][2];
                det[1][0] <= data_map[2][1];
                det[1][1] <= data_map[2][2];
            end
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b10110)begin
        case (count)
            0: begin
                det[0][0] <= data_map[2][2];
                det[0][1] <= data_map[2][3];
                det[1][0] <= data_map[3][2];
                det[1][1] <= data_map[3][3];
            end
            1: begin
                det[0][0] <= data_map[1][2];
                det[0][1] <= data_map[1][3];
                det[1][0] <= data_map[3][2];
                det[1][1] <= data_map[3][3];
            end
            2: begin
                det[0][0] <= data_map[1][2];
                det[0][1] <= data_map[1][3];
                det[1][0] <= data_map[2][2];
                det[1][1] <= data_map[2][3];
            end
            3: begin
                det[0][0] <= data_map[2][0];
                det[0][1] <= data_map[2][1];
                det[1][0] <= data_map[3][0];
                det[1][1] <= data_map[3][1];
            end
            4: begin
                det[0][0] <= data_map[1][0];
                det[0][1] <= data_map[1][1];
                det[1][0] <= data_map[3][0];
                det[1][1] <= data_map[3][1];
            end
            5: begin
                det[0][0] <= data_map[1][0];
                det[0][1] <= data_map[1][1];
                det[1][0] <= data_map[2][0];
                det[1][1] <= data_map[2][1];
            end
            6: begin
                det[0][0] <= 0;
                det[0][1] <= 0;
                det[1][0] <= 0;
                det[1][1] <= 0;
            end
        endcase
    end

end

reg signed [22:0] det_out;
always @(*) begin
    det_out = det[0][0]*det[1][1]-det[0][1]*det[1][0];
end

reg signed [22:0] det_2_out[0:2][0:2];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_2_out[0][0] <= 0;
        det_2_out[0][1] <= 0;
        det_2_out[0][2] <= 0;
        det_2_out[1][0] <= 0;
        det_2_out[1][1] <= 0;
        det_2_out[1][2] <= 0;
        det_2_out[2][0] <= 0;
        det_2_out[2][1] <= 0;
        det_2_out[2][2] <= 0;
    end
    else if (cs == READ &&  mode_map == 5'b00100) begin
        case (count)
            9: det_2_out[0][0] <= det_out;
            10: det_2_out[0][1] <= det_out;
            11: det_2_out[0][2] <= det_out;
            12: det_2_out[1][0] <= det_out;
            13: det_2_out[1][1] <= det_out;
            14: det_2_out[1][2] <= det_out;
            15: det_2_out[2][0] <= det_out;
        endcase
    end
     else if (cs == CAL &&  mode_map == 5'b00100) begin
        case (count)
            0: det_2_out[2][1] <= det_out;
            1: det_2_out[2][2] <= det_out;
        endcase
    end
end


reg signed [11:0] det_coe_3_1, det_coe_3_2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_coe_3_1 <= 0;
    end
    else if (cs == READ &&  mode_map == 5'b00110)begin
        case (count)
            12: det_coe_3_1 <= data_map[0][0];
            13: det_coe_3_1 <= data_map[1][0];
            14: det_coe_3_1 <= data_map[2][0];
            15: det_coe_3_1 <= data_map[1][0];
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b00110)begin
        case (count)
            0: det_coe_3_1 <= data_map[2][0];
            1: det_coe_3_1 <= data_map[3][0];
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b10110)begin
        case (count)
            0: det_coe_3_1 <= data_map[1][1];
            1: det_coe_3_1 <= -data_map[2][1];
            2: det_coe_3_1 <= data_map[3][1];

            3: det_coe_3_1 <= data_map[1][3];
            4: det_coe_3_1 <= -data_map[2][3];
            5: det_coe_3_1 <= data_map[3][3];

            6 : det_coe_3_1 <= 0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_coe_3_2 <= 0;
    end
    else if (cs == READ &&  mode_map == 5'b00110)begin
        case (count)
            12: det_coe_3_2 <= data_map[0][3];
            13: det_coe_3_2 <= data_map[1][3];
            14: det_coe_3_2 <= data_map[2][3];
            15: det_coe_3_2 <= data_map[1][3];
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b00110)begin
        case (count)   
            0: det_coe_3_2 <= data_map[2][3];
            1: det_coe_3_2 <= data_map[3][3];
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b10110)begin
        case (count)
            0: det_coe_3_2 <= data_map[1][0];
            1: det_coe_3_2 <= -data_map[2][0];
            2: det_coe_3_2 <= data_map[3][0];

            3: det_coe_3_2 <= data_map[1][2];
            4: det_coe_3_2 <= -data_map[2][2];
            5: det_coe_3_2 <= data_map[3][2];
            6 : det_coe_3_2 <= 0;
        endcase
    end
end


reg signed [33:0] det_3_1, det_3_2;

always @(*) begin
    det_3_1 = det_out*det_coe_3_1;
end

always @(*) begin
    det_3_2 = det_out*det_coe_3_2;
end

reg signed [50:0] det_3_out[0:1][0:1];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_3_out[0][0] <= 0;
        det_3_out[0][1] <= 0;
        det_3_out[1][0] <= 0;
        det_3_out[1][1] <= 0;
    end
    else if (cs == READ &&  mode_map == 5'b00110)begin
        case (count)
            13: begin
                det_3_out[0][0] <= det_3_1;
                det_3_out[0][1] <= det_3_2;
            end
            14: begin
                det_3_out[0][0] <= det_3_out[0][0] - det_3_1;
                det_3_out[0][1] <= det_3_out[0][1] - det_3_2;
            end
            15: begin
                det_3_out[0][0] <= det_3_out[0][0] + det_3_1;
                det_3_out[0][1] <= det_3_out[0][1] + det_3_2;
            end
        endcase
    end
    else if (cs == CAL &&  mode_map == 5'b00110)begin
        case (count)
            0: begin
                det_3_out[1][0] <= det_3_1;
                det_3_out[1][1] <= det_3_2;
            end
            1: begin
                det_3_out[1][0] <= det_3_out[1][0] - det_3_1;
                det_3_out[1][1] <= det_3_out[1][1] - det_3_2;
            end
            2: begin
                det_3_out[1][0] <= det_3_out[1][0] + det_3_1;
                det_3_out[1][1] <= det_3_out[1][1] + det_3_2;
            end
        endcase
    end
end


reg signed [11:0] det_coe_4_1, det_coe_4_2;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_coe_4_1 <= 0;
    end
    else if (cs == CAL &&  mode_map == 5'b10110)begin
        case (count)
            0,1,2: det_coe_4_1 <= data_map[0][0];
            3,4,5: det_coe_4_1 <= data_map[0][2];
            6 : det_coe_4_1 <= 0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_coe_4_2 <= 0;
    end
    else if (cs == CAL &&  mode_map == 5'b10110)begin
        case (count)
            0,1,2: det_coe_4_2 <= -data_map[0][1];
            3,4,5: det_coe_4_2 <= -data_map[0][3];
            6 : det_coe_4_2 <= 0;
        endcase
    end
end




reg signed [44:0] det_4;

always @(*) begin
    det_4 = det_3_1*det_coe_4_1 + det_3_2*det_coe_4_2;
end

reg signed [44:0] det_4_out;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_4_out <= 0;
    end
    else if (cs == CAL &&  mode_map == 5'b10110)begin
        case (count)
            1: det_4_out <= det_4;
            2: det_4_out <= det_4_out + det_4;
            3: det_4_out <= det_4_out + det_4;
            4: det_4_out <= det_4_out + det_4;
            5: det_4_out <= det_4_out + det_4;
            6: det_4_out <= det_4_out + det_4;
        endcase

    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (cs == OUT) begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    /*
    else if (cs == OUT && mode_map == 5'b10110) begin
        if(det_4_out >= 0) begin
            out_data <= {162'd0,det_4_out};
        end
        else begin
            out_data <= {{18{9'b111111111}},det_4_out};
        end
    end
    */
    else if (cs == OUT && mode_map == 5'b10110) begin
        out_data <= det_4_out;
    end
    else if (cs == OUT && mode_map == 5'b00110) begin
        out_data <= {3'b000,det_3_out[0][0],det_3_out[0][1],det_3_out[1][0],det_3_out[1][1]};
    end
    else if (cs == OUT && mode_map == 5'b00100) begin
        out_data <= {det_2_out[0][0],det_2_out[0][1],det_2_out[0][2],det_2_out[1][0],det_2_out[1][1],det_2_out[1][2],det_2_out[2][0],det_2_out[2][1],det_2_out[2][2]};
    end
    else begin
        out_data <= 0;
    end
    
end



endmodule