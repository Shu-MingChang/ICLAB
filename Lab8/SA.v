/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: SA.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Fall IC Lab / Exersise Lab08 / SA
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on


module SA(
	// Input signals
	clk,
	rst_n,
    cg_en,
	in_valid,
	T,
	in_data,
	w_Q,
	w_K,
	w_V,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input cg_en;
input in_valid;
input [3:0] T;
input signed [7:0] in_data;
input signed [7:0] w_Q;
input signed [7:0] w_K;
input signed [7:0] w_V;

output reg out_valid;
output reg signed [63:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
localparam IDLE = 3'b000;
localparam READ = 3'b001;
localparam OUT = 3'b010;
//localparam WAIT = 3'b011;
//localparam OUT = 3'b100;
integer i;



//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [2:0] cs, ns;
reg [13:0] count, count_q, count_QK, count_QK_2, count_s, count_P_S, count_P_V;
reg [13:0] mult_count_in2;
reg [3:0] T_reg;

reg out_val_reg;

wire mul_wen, mul_wen_1, mul_wen_2, mul_wen_3;
reg mul_wen_reg, mul_wen_1_reg, mul_wen_2_reg, mul_wen_3_reg, mul_wen_3_reg_scal;

reg signed [7:0] in_data_r1[0:7];
reg signed [7:0] in_data_r2[0:7];
reg signed [7:0] in_data_r3[0:7];
reg signed [7:0] in_data_r4[0:7];
reg signed [7:0] in_data_r5[0:7];
reg signed [7:0] in_data_r6[0:7];
reg signed [7:0] in_data_r7[0:7];
reg signed [7:0] in_data_r8[0:7];

reg signed [7:0] in_data_q_r1[0:7];
reg signed [7:0] in_data_q_r2[0:7];
reg signed [7:0] in_data_q_r3[0:7];
reg signed [7:0] in_data_q_r4[0:7];
reg signed [7:0] in_data_q_r5[0:7];
reg signed [7:0] in_data_q_r6[0:7];
reg signed [7:0] in_data_q_r7[0:7];
reg signed [7:0] in_data_q_r8[0:7];

reg signed [7:0] in_data_k_r1[0:7];
reg signed [7:0] in_data_k_r2[0:7];
reg signed [7:0] in_data_k_r3[0:7];
reg signed [7:0] in_data_k_r4[0:7];
reg signed [7:0] in_data_k_r5[0:7];
reg signed [7:0] in_data_k_r6[0:7];
reg signed [7:0] in_data_k_r7[0:7];
reg signed [7:0] in_data_k_r8[0:7];

reg signed [7:0] in_data_v_r1[0:7];
reg signed [7:0] in_data_v_r2[0:7];
reg signed [7:0] in_data_v_r3[0:7];
reg signed [7:0] in_data_v_r4[0:7];
reg signed [7:0] in_data_v_r5[0:7];
reg signed [7:0] in_data_v_r6[0:7];
reg signed [7:0] in_data_v_r7[0:7];
reg signed [7:0] in_data_v_r8[0:7];


reg signed [19:0] Q_r1[0:7];
reg signed [19:0] Q_r2[0:7];
reg signed [19:0] Q_r3[0:7];
reg signed [19:0] Q_r4[0:7];
reg signed [19:0] Q_r5[0:7];
reg signed [19:0] Q_r6[0:7];
reg signed [19:0] Q_r7[0:7];
reg signed [19:0] Q_r8[0:7];

reg signed [19:0] K_r1[0:7];
reg signed [19:0] K_r2[0:7];
reg signed [19:0] K_r3[0:7];
reg signed [19:0] K_r4[0:7];
reg signed [19:0] K_r5[0:7];
reg signed [19:0] K_r6[0:7];
reg signed [19:0] K_r7[0:7];
reg signed [19:0] K_r8[0:7];

reg signed [19:0] V_r1[0:7];
reg signed [19:0] V_r2[0:7];
reg signed [19:0] V_r3[0:7];
reg signed [19:0] V_r4[0:7];
reg signed [19:0] V_r5[0:7];
reg signed [19:0] V_r6[0:7];
reg signed [19:0] V_r7[0:7];
reg signed [19:0] V_r8[0:7];

reg signed [7:0] mult_1[0:7];
reg signed [7:0] mult_2[0:7];

reg signed [19:0] mult_Q[0:7];
reg signed [19:0] mult_K[0:7];

reg signed [63:0] mult_P_S[0:7];
reg signed [63:0] mult_P_V[0:7];


reg signed [43:0] S_r1[0:7];
reg signed [43:0] S_r2[0:7];
reg signed [43:0] S_r3[0:7];
reg signed [43:0] S_r4[0:7];
reg signed [43:0] S_r5[0:7];
reg signed [43:0] S_r6[0:7];
reg signed [43:0] S_r7[0:7];
reg signed [43:0] S_r8[0:7];

//==============================================//
//                  design                      //
//==============================================//




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
			if (in_valid == 1) ns = READ;
            else ns = cs;
		end
		READ: begin
            if (count == 256) ns = OUT;
            else ns = cs;
		end
        OUT: begin 
            if (count_P_S == 63 && T_reg == 8) ns = IDLE;
			else if (count_P_S == 31 && T_reg == 4) ns = IDLE;
			else if (count_P_S == 7 && T_reg == 1) ns = IDLE;
            else ns = cs;
		end
       
		default:ns = IDLE;

	endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_val_reg <= 0;
    else if (cs == OUT) out_val_reg <= 1;
    else out_val_reg <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= 0;
    else if (in_valid || cs == READ) count <= count + 1;
    else if (cs == IDLE) count <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_QK <= 0;
	else if (count_QK == 63) count_QK <= 0;
    else if (mul_wen_reg) count_QK <= count_QK + 1;
    else  count_QK <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_QK_2 <= 0;
	else if (count_QK_2 == 7) count_QK_2 <= 0;
    else if (mul_wen_3_reg) count_QK_2 <= count_QK_2 + 1;
    else  count_QK_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_s <= 0;
	else if (count_s == 63) count_s <= 0;
    else if (mul_wen_3_reg_scal) count_s <= count_s + 1;
    else  count_s <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_P_S <= 0;
	//else if (count_P_S == 63) count_P_S <= 0;
    else if (cs == OUT) count_P_S <= count_P_S + 1;
    else  count_P_S <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_P_V <= 0;
	else if (count_P_V == 7) count_P_V <= 0;
    else if (cs == OUT) count_P_V <= count_P_V + 1;
    else  count_P_V <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) mult_count_in2 <= 0;
    else if ((in_valid || cs == READ) && mult_count_in2 < 7) mult_count_in2 <= mult_count_in2 + 1;
	else if ((in_valid || cs == READ) && mult_count_in2 == 7) mult_count_in2 <= 0;
    else if (cs == IDLE) mult_count_in2 <= 0;
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) T_reg <= 0;
    else if (in_valid && count == 0) T_reg <= T;
    else if (cs == IDLE) T_reg <= 0;
end



/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) count_q <= 0;
    else if (in_valid) count_q <= count_q + 1;
    else if (cs == IDLE) count_q <= 0;
end
*/

/////////////////////////////////////////////////
///               in_data                ////////////
//////////////////////////////////////////////
//wire G_clock_in_data_r1 ;
//wire G_s_in_data_r1 = !( count [8:0]< 8);
//GATED_OR GATED_indata_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r1)) ;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r1[i] <= 0;
		end
	end
	else if ( in_valid && count[8:0] < 8) begin
		case (count[5:0])
			0: in_data_r1[0] <= in_data;
			1: in_data_r1[1] <= in_data;
			2: in_data_r1[2] <= in_data;
			3: in_data_r1[3] <= in_data;
			4: in_data_r1[4] <= in_data;
			5: in_data_r1[5] <= in_data;
			6: in_data_r1[6] <= in_data;
			7: in_data_r1[7] <= in_data;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r1[i] <= in_data_r1[i];
		end
	end
end

wire G_clock_in_data_r2 ;
wire G_s_in_data_r2 = !( count[7:0] > 7 && count[7:0] < 16);
GATED_OR GATED_in_data_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r2)) ;
always @(posedge G_clock_in_data_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r2[i] <= 0;
		end
	end
	else if ( count[7:0] > 7 && count[7:0] < 16 && (T_reg == 4 || T_reg == 8)) begin
		case (count[5:0])
			8:  in_data_r2[0] <= in_data;
			9:  in_data_r2[1] <= in_data;
			10: in_data_r2[2] <= in_data;
			11: in_data_r2[3] <= in_data;
			12: in_data_r2[4] <= in_data;
			13: in_data_r2[5] <= in_data;
			14: in_data_r2[6] <= in_data;
			15: in_data_r2[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 7 && count[7:0] < 16 && T_reg == 1 ) begin
		case (count[5:0])
			8:  in_data_r2[0] <= 0;
			9:  in_data_r2[1] <= 0;
			10: in_data_r2[2] <= 0;
			11: in_data_r2[3] <= 0;
			12: in_data_r2[4] <= 0;
			13: in_data_r2[5] <= 0;
			14: in_data_r2[6] <= 0;
			15: in_data_r2[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r2[i] <= in_data_r2[i];
		end
	end
end

wire G_clock_in_data_r3 ;
wire G_s_in_data_r3 = !( count[7:0] > 15 && count[7:0] < 24) ;
GATED_OR GATED_in_data_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r3)) ;
always @(posedge G_clock_in_data_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r3[i] <= 0;
		end
	end
	else if ( count[7:0] > 15 && count[7:0] < 24 && (T_reg == 4 || T_reg == 8)) begin
		case (count[5:0])
			16: in_data_r3[0] <= in_data;
			17: in_data_r3[1] <= in_data;
			18: in_data_r3[2] <= in_data;
			19: in_data_r3[3] <= in_data;
			20: in_data_r3[4] <= in_data;
			21: in_data_r3[5] <= in_data;
			22: in_data_r3[6] <= in_data;
			23: in_data_r3[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 15 && count[7:0] < 24 && T_reg == 1 ) begin
		case (count[5:0])
			16: in_data_r3[0] <= 0;
			17: in_data_r3[1] <= 0;
			18: in_data_r3[2] <= 0;
			19: in_data_r3[3] <= 0;
			20: in_data_r3[4] <= 0;
			21: in_data_r3[5] <= 0;
			22: in_data_r3[6] <= 0;
			23: in_data_r3[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r3[i] <= in_data_r3[i];
		end
	end
end

wire G_clock_in_data_r4 ;
wire G_s_in_data_r4 = !( count[7:0] > 23 && count[7:0] < 32) ;
GATED_OR GATED_in_data_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r4)) ;
always @(posedge G_clock_in_data_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r4[i] <= 0;
		end
	end
	else if ( count[7:0] > 23 && count[7:0] < 32 && (T_reg == 4 || T_reg == 8)) begin
		case (count[5:0])
			24: in_data_r4[0] <= in_data;
			25: in_data_r4[1] <= in_data;
			26: in_data_r4[2] <= in_data;
			27: in_data_r4[3] <= in_data;
			28: in_data_r4[4] <= in_data;
			29: in_data_r4[5] <= in_data;
			30: in_data_r4[6] <= in_data;
			31: in_data_r4[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 23 && count[7:0] < 32 && T_reg == 1 ) begin
		case (count[5:0])
			24: in_data_r4[0] <= 0;
			25: in_data_r4[1] <= 0;
			26: in_data_r4[2] <= 0;
			27: in_data_r4[3] <= 0;
			28: in_data_r4[4] <= 0;
			29: in_data_r4[5] <= 0;
			30: in_data_r4[6] <= 0;
			31: in_data_r4[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r4[i] <= in_data_r4[i];
		end
	end
end

wire G_clock_in_data_r5 ;
wire G_s_in_data_r5 = !( count[7:0] > 31 && count[7:0] < 40 ) ;
GATED_OR GATED_in_data_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r5)) ;
always @(posedge G_clock_in_data_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r5[i] <= 0;
		end
	end
	else if ( count[7:0] > 31 && count[7:0] < 40 && T_reg == 8) begin
		case (count[5:0])
			32: in_data_r5[0] <= in_data;
			33: in_data_r5[1] <= in_data;
			34: in_data_r5[2] <= in_data;
			35: in_data_r5[3] <= in_data;
			36: in_data_r5[4] <= in_data;
			37: in_data_r5[5] <= in_data;
			38: in_data_r5[6] <= in_data;
			39: in_data_r5[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 31 && count[7:0] < 40 && (T_reg == 1 || T_reg == 4)) begin
		case (count[5:0])
			32: in_data_r5[0] <= 0;
			33: in_data_r5[1] <= 0;
			34: in_data_r5[2] <= 0;
			35: in_data_r5[3] <= 0;
			36: in_data_r5[4] <= 0;
			37: in_data_r5[5] <= 0;
			38: in_data_r5[6] <= 0;
			39: in_data_r5[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r5[i] <= in_data_r5[i];
		end
	end
end

wire G_clock_in_data_r6 ;
wire G_s_in_data_r6 = !( count[7:0] > 39 && count[7:0] < 48 ) ;
GATED_OR GATED_in_data_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r6)) ;
always @(posedge G_clock_in_data_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r6[i] <= 0;
		end
	end
	else if ( count[7:0] > 39 && count[7:0] < 48 && T_reg == 8) begin
		case (count[5:0])
			40: in_data_r6[0] <= in_data;
			41: in_data_r6[1] <= in_data;
			42: in_data_r6[2] <= in_data;
			43: in_data_r6[3] <= in_data;
			44: in_data_r6[4] <= in_data;
			45: in_data_r6[5] <= in_data;
			46: in_data_r6[6] <= in_data;
			47: in_data_r6[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 39 && count[7:0] < 48 && (T_reg == 1 || T_reg == 4)) begin
		case (count[5:0])
			40: in_data_r6[0] <= 0;
			41: in_data_r6[1] <= 0;
			42: in_data_r6[2] <= 0;
			43: in_data_r6[3] <= 0;
			44: in_data_r6[4] <= 0;
			45: in_data_r6[5] <= 0;
			46: in_data_r6[6] <= 0;
			47: in_data_r6[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r6[i] <= in_data_r6[i];
		end
	end
end

wire G_clock_in_data_r7 ;
wire G_s_in_data_r7 = !( count[7:0] > 47 && count[7:0] < 56 ) ;
GATED_OR GATED_in_data_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r7)) ;
always @(posedge G_clock_in_data_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r7[i] <= 0;
		end
	end
	else if ( count[7:0] > 47 && count[7:0] < 56 && T_reg == 8) begin
		case (count[5:0])
			48: in_data_r7[0] <= in_data;
			49: in_data_r7[1] <= in_data;
			50: in_data_r7[2] <= in_data;
			51: in_data_r7[3] <= in_data;
			52: in_data_r7[4] <= in_data;
			53: in_data_r7[5] <= in_data;
			54: in_data_r7[6] <= in_data;
			55: in_data_r7[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 47 && count[7:0] < 56 && (T_reg == 1 || T_reg == 4)) begin
		case (count[5:0])
			48: in_data_r7[0] <= 0;
			49: in_data_r7[1] <= 0;
			50: in_data_r7[2] <= 0;
			51: in_data_r7[3] <= 0;
			52: in_data_r7[4] <= 0;
			53: in_data_r7[5] <= 0;
			54: in_data_r7[6] <= 0;
			55: in_data_r7[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r7[i] <= in_data_r7[i];
		end
	end
end

wire G_clock_in_data_r8 ;
wire G_s_in_data_r8 = !( count[7:0] > 55 && count[7:0] < 64) ;
GATED_OR GATED_in_data_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_r8)) ;
always @(posedge G_clock_in_data_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_r8[i] <= 0;
		end
	end
	else if ( count[7:0] > 55 && count[7:0] < 64 && T_reg == 8) begin
		case (count[5:0])
			56: in_data_r8[0] <= in_data;
			57: in_data_r8[1] <= in_data;
			58: in_data_r8[2] <= in_data;
			59: in_data_r8[3] <= in_data;
			60: in_data_r8[4] <= in_data;
			61: in_data_r8[5] <= in_data;
			62: in_data_r8[6] <= in_data;
			63: in_data_r8[7] <= in_data;

		endcase
	end
    else if ( count[7:0] > 55 && count[7:0] < 64 && (T_reg == 1 || T_reg == 4)) begin
		case (count[5:0])
			56: in_data_r8[0] <= 0;
			57: in_data_r8[1] <= 0;
			58: in_data_r8[2] <= 0;
			59: in_data_r8[3] <= 0;
			60: in_data_r8[4] <= 0;
			61: in_data_r8[5] <= 0;
			62: in_data_r8[6] <= 0;
			63: in_data_r8[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_r8[i] <= in_data_r8[i];
		end
	end
end
/////////////////////////////////////////////////
///               in_q                ////////////
//////////////////////////////////////////////

//wire G_clock_in_data_q_r1 ;
//wire G_s_in_data_q_r1 = !(in_valid && count [7:0]< 8);
//GATED_OR GATED_indata_q_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r1));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r1[i] <= 0;
		end
	end
	else if (in_valid && count[7:0] < 8) begin
		case (count[5:0])
			0: in_data_q_r1[0] <= w_Q;
			1: in_data_q_r1[1] <= w_Q;
			2: in_data_q_r1[2] <= w_Q;
			3: in_data_q_r1[3] <= w_Q;
			4: in_data_q_r1[4] <= w_Q;
			5: in_data_q_r1[5] <= w_Q;
			6: in_data_q_r1[6] <= w_Q;
			7: in_data_q_r1[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r1[i] <= in_data_q_r1[i];
		end
	end
end

wire G_clock_in_data_q_r2;
wire G_s_in_data_q_r2 = !(count[7:0] > 7 && count[7:0] < 16) ;
GATED_OR GATED_indata_q_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r2));
always @(posedge G_clock_in_data_q_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r2[i] <= 0;
		end
	end
	else if ( count[7:0] > 7 && count[7:0] < 16) begin
		case (count[5:0])
			8:  in_data_q_r2[0] <= w_Q;
			9:  in_data_q_r2[1] <= w_Q;
			10: in_data_q_r2[2] <= w_Q;
			11: in_data_q_r2[3] <= w_Q;
			12: in_data_q_r2[4] <= w_Q;
			13: in_data_q_r2[5] <= w_Q;
			14: in_data_q_r2[6] <= w_Q;
			15: in_data_q_r2[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r2[i] <= in_data_q_r2[i];
		end
	end
end

wire G_clock_in_data_q_r3;
wire G_s_in_data_q_r3 = !(count[7:0] > 15 && count[7:0] < 24) ;
GATED_OR GATED_indata_q_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r3));
always @(posedge G_clock_in_data_q_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r3[i] <= 0;
		end
	end
	else if ( count[7:0] > 15 && count[7:0] < 24) begin
		case (count[5:0])
			16: in_data_q_r3[0] <= w_Q;
			17: in_data_q_r3[1] <= w_Q;
			18: in_data_q_r3[2] <= w_Q;
			19: in_data_q_r3[3] <= w_Q;
			20: in_data_q_r3[4] <= w_Q;
			21: in_data_q_r3[5] <= w_Q;
			22: in_data_q_r3[6] <= w_Q;
			23: in_data_q_r3[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r3[i] <= in_data_q_r3[i];
		end
	end
end

wire G_clock_in_data_q_r4;
wire G_s_in_data_q_r4 = !(count[7:0] > 23 && count[7:0] < 32) ;
GATED_OR GATED_indata_q_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r4));
always @(posedge G_clock_in_data_q_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r4[i] <= 0;
		end
	end
	else if ( count[7:0] > 23 && count[7:0] < 32) begin
		case (count[5:0])
			24: in_data_q_r4[0] <= w_Q;
			25: in_data_q_r4[1] <= w_Q;
			26: in_data_q_r4[2] <= w_Q;
			27: in_data_q_r4[3] <= w_Q;
			28: in_data_q_r4[4] <= w_Q;
			29: in_data_q_r4[5] <= w_Q;
			30: in_data_q_r4[6] <= w_Q;
			31: in_data_q_r4[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r4[i] <= in_data_q_r4[i];
		end
	end
end

wire G_clock_in_data_q_r5;
wire G_s_in_data_q_r5 = !(count[7:0] > 31 && count[7:0] < 40) ;
GATED_OR GATED_indata_q_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r5));
always @(posedge G_clock_in_data_q_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r5[i] <= 0;
		end
	end
	else if ( count[7:0] > 31 && count[7:0] < 40) begin
		case (count[5:0])
			32: in_data_q_r5[0] <= w_Q;
			33: in_data_q_r5[1] <= w_Q;
			34: in_data_q_r5[2] <= w_Q;
			35: in_data_q_r5[3] <= w_Q;
			36: in_data_q_r5[4] <= w_Q;
			37: in_data_q_r5[5] <= w_Q;
			38: in_data_q_r5[6] <= w_Q;
			39: in_data_q_r5[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r5[i] <= in_data_q_r5[i];
		end
	end
end

wire G_clock_in_data_q_r6;
wire G_s_in_data_q_r6 = !(count[7:0] > 39 && count[7:0] < 48) ;
GATED_OR GATED_indata_q_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r6));
always @(posedge G_clock_in_data_q_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r6[i] <= 0;
		end
	end
	else if ( count[7:0] > 39 && count[7:0] < 48) begin
		case (count[5:0])
			40: in_data_q_r6[0] <= w_Q;
			41: in_data_q_r6[1] <= w_Q;
			42: in_data_q_r6[2] <= w_Q;
			43: in_data_q_r6[3] <= w_Q;
			44: in_data_q_r6[4] <= w_Q;
			45: in_data_q_r6[5] <= w_Q;
			46: in_data_q_r6[6] <= w_Q;
			47: in_data_q_r6[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r6[i] <= in_data_q_r6[i];
		end
	end
end

wire G_clock_in_data_q_r7;
wire G_s_in_data_q_r7 = !(count[7:0] > 47 && count[7:0] < 56) ;
GATED_OR GATED_indata_q_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r7));
always @(posedge G_clock_in_data_q_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r7[i] <= 0;
		end
	end
	else if ( count[7:0] > 47 && count[7:0] < 56) begin
		case (count[7:0])
			48: in_data_q_r7[0] <= w_Q;
			49: in_data_q_r7[1] <= w_Q;
			50: in_data_q_r7[2] <= w_Q;
			51: in_data_q_r7[3] <= w_Q;
			52: in_data_q_r7[4] <= w_Q;
			53: in_data_q_r7[5] <= w_Q;
			54: in_data_q_r7[6] <= w_Q;
			55: in_data_q_r7[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r7[i] <= in_data_q_r7[i];
		end
	end
end

wire G_clock_in_data_q_r8;
wire G_s_in_data_q_r8 = !(count[7:0] > 55 && count[7:0] < 64) ;
GATED_OR GATED_indata_q_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_q_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_q_r8));
always @(posedge G_clock_in_data_q_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r8[i] <= 0;
		end
	end
	else if ( count[7:0] > 55 && count[7:0] < 64) begin
		case (count[5:0])
			56: in_data_q_r8[0] <= w_Q;
			57: in_data_q_r8[1] <= w_Q;
			58: in_data_q_r8[2] <= w_Q;
			59: in_data_q_r8[3] <= w_Q;
			60: in_data_q_r8[4] <= w_Q;
			61: in_data_q_r8[5] <= w_Q;
			62: in_data_q_r8[6] <= w_Q;
			63: in_data_q_r8[7] <= w_Q;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_q_r8[i] <= in_data_q_r8[i];
		end
	end
end
/////////////////////////////////////////////////
///               in_k                ////////////
//////////////////////////////////////////////

wire G_clock_in_data_k_r1 ;
wire G_s_in_data_k_r1 = !(count[7:0] > 63 && count[7:0] < 72);
GATED_OR GATED_indata_k_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r1));
always @(posedge G_clock_in_data_k_r1 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r1[i] <= 0;
		end
	end
	else if ( count[7:0] > 63 && count[7:0] < 72) begin
		case (count[5:0])
			0: in_data_k_r1[0] <= w_K;
			1: in_data_k_r1[1] <= w_K;
			2: in_data_k_r1[2] <= w_K;
			3: in_data_k_r1[3] <= w_K;
			4: in_data_k_r1[4] <= w_K;
			5: in_data_k_r1[5] <= w_K;
			6: in_data_k_r1[6] <= w_K;
			7: in_data_k_r1[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r1[i] <= in_data_k_r1[i];
		end
	end
end

wire G_clock_in_data_k_r2 ;
wire G_s_in_data_k_r2 = !(count[7:0] > 71 && count[7:0] < 80);
GATED_OR GATED_indata_k_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r2));
always @(posedge G_clock_in_data_k_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r2[i] <= 0;
		end
	end
	else if ( count[7:0] > 71 && count[7:0] < 80) begin
		case (count[5:0])
			8:  in_data_k_r2[0] <= w_K;
			9:  in_data_k_r2[1] <= w_K;
			10: in_data_k_r2[2] <= w_K;
			11: in_data_k_r2[3] <= w_K;
			12: in_data_k_r2[4] <= w_K;
			13: in_data_k_r2[5] <= w_K;
			14: in_data_k_r2[6] <= w_K;
			15: in_data_k_r2[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r2[i] <= in_data_k_r2[i];
		end
	end
end

wire G_clock_in_data_k_r3 ;
wire G_s_in_data_k_r3 = !(count[7:0] > 79 && count[7:0] < 88);
GATED_OR GATED_indata_k_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r3));
always @(posedge G_clock_in_data_k_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r3[i] <= 0;
		end
	end
	else if ( count[7:0] > 79 && count[7:0] < 88) begin
		case (count[5:0])
			16: in_data_k_r3[0] <= w_K;
			17: in_data_k_r3[1] <= w_K;
			18: in_data_k_r3[2] <= w_K;
			19: in_data_k_r3[3] <= w_K;
			20: in_data_k_r3[4] <= w_K;
			21: in_data_k_r3[5] <= w_K;
			22: in_data_k_r3[6] <= w_K;
			23: in_data_k_r3[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r3[i] <= in_data_k_r3[i];
		end
	end
end

wire G_clock_in_data_k_r4 ;
wire G_s_in_data_k_r4 = !(count[7:0] > 87 && count[7:0] < 96);
GATED_OR GATED_indata_k_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r4));
always @(posedge G_clock_in_data_k_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r4[i] <= 0;
		end
	end
	else if ( count[7:0] > 87 && count[7:0] < 96) begin
		case (count[5:0])
			24: in_data_k_r4[0] <= w_K;
			25: in_data_k_r4[1] <= w_K;
			26: in_data_k_r4[2] <= w_K;
			27: in_data_k_r4[3] <= w_K;
			28: in_data_k_r4[4] <= w_K;
			29: in_data_k_r4[5] <= w_K;
			30: in_data_k_r4[6] <= w_K;
			31: in_data_k_r4[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r4[i] <= in_data_k_r4[i];
		end
	end
end

wire G_clock_in_data_k_r5 ;
wire G_s_in_data_k_r5 = !(count[7:0] > 95 && count[7:0] < 104);
GATED_OR GATED_indata_k_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r5));
always @(posedge G_clock_in_data_k_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r5[i] <= 0;
		end
	end
	else if ( count[7:0] > 95 && count[7:0] < 104) begin
		case (count[5:0])
			32: in_data_k_r5[0] <= w_K;
			33: in_data_k_r5[1] <= w_K;
			34: in_data_k_r5[2] <= w_K;
			35: in_data_k_r5[3] <= w_K;
			36: in_data_k_r5[4] <= w_K;
			37: in_data_k_r5[5] <= w_K;
			38: in_data_k_r5[6] <= w_K;
			39: in_data_k_r5[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r5[i] <= in_data_k_r5[i];
		end
	end
end

wire G_clock_in_data_k_r6 ;
wire G_s_in_data_k_r6 = !(count[7:0] > 103 && count[7:0] < 112);
GATED_OR GATED_indata_k_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r6));
always @(posedge G_clock_in_data_k_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r6[i] <= 0;
		end
	end
	else if ( count[7:0] > 103 && count[7:0] < 112) begin
		case (count[5:0])
			40: in_data_k_r6[0] <= w_K;
			41: in_data_k_r6[1] <= w_K;
			42: in_data_k_r6[2] <= w_K;
			43: in_data_k_r6[3] <= w_K;
			44: in_data_k_r6[4] <= w_K;
			45: in_data_k_r6[5] <= w_K;
			46: in_data_k_r6[6] <= w_K;
			47: in_data_k_r6[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r6[i] <= in_data_k_r6[i];
		end
	end
end

wire G_clock_in_data_k_r7 ;
wire G_s_in_data_k_r7 = !(count[7:0] > 111 && count[7:0] < 120);
GATED_OR GATED_indata_k_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r7));
always @(posedge G_clock_in_data_k_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r7[i] <= 0;
		end
	end
	else if ( count[7:0] > 111 && count[7:0] < 120) begin
		case (count[5:0])
			48: in_data_k_r7[0] <= w_K;
			49: in_data_k_r7[1] <= w_K;
			50: in_data_k_r7[2] <= w_K;
			51: in_data_k_r7[3] <= w_K;
			52: in_data_k_r7[4] <= w_K;
			53: in_data_k_r7[5] <= w_K;
			54: in_data_k_r7[6] <= w_K;
			55: in_data_k_r7[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r7[i] <= in_data_k_r7[i];
		end
	end
end

wire G_clock_in_data_k_r8 ;
wire G_s_in_data_k_r8 = !(count[7:0] > 119 && count[7:0] < 128);
GATED_OR GATED_indata_k_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_k_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_k_r8));
always @(posedge G_clock_in_data_k_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r8[i] <= 0;
		end
	end
	else if ( count[7:0] > 119 && count[7:0] < 128) begin
		case (count[5:0])
			56: in_data_k_r8[0] <= w_K;
			57: in_data_k_r8[1] <= w_K;
			58: in_data_k_r8[2] <= w_K;
			59: in_data_k_r8[3] <= w_K;
			60: in_data_k_r8[4] <= w_K;
			61: in_data_k_r8[5] <= w_K;
			62: in_data_k_r8[6] <= w_K;
			63: in_data_k_r8[7] <= w_K;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_k_r8[i] <= in_data_k_r8[i];
		end
	end
end

/////////////////////////////////////////////////
///               in_v                ////////////
//////////////////////////////////////////////


wire G_clock_in_data_v_r1 ;
wire G_s_in_data_v_r1 = !(count[7:0] > 127 && count[7:0] < 136);
GATED_OR GATED_indata_v_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r1));
always @(posedge G_clock_in_data_v_r1 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r1[i] <= 0;
		end
	end
	else if ( count[7:0] > 127 && count[7:0] < 136) begin
		case (count[5:0])
			0: in_data_v_r1[0] <= w_V;
			1: in_data_v_r1[1] <= w_V;
			2: in_data_v_r1[2] <= w_V;
			3: in_data_v_r1[3] <= w_V;
			4: in_data_v_r1[4] <= w_V;
			5: in_data_v_r1[5] <= w_V;
			6: in_data_v_r1[6] <= w_V;
			7: in_data_v_r1[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r1[i] <= in_data_v_r1[i];
		end
	end
end

wire G_clock_in_data_v_r2 ;
wire G_s_in_data_v_r2 = !( count[7:0] > 135 && count[7:0] < 144);
GATED_OR GATED_indata_v_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r2));
always @(posedge G_clock_in_data_v_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r2[i] <= 0;
		end
	end
	else if ( count[7:0] > 135 && count[7:0] < 144) begin
		case (count[5:0])
			8:  in_data_v_r2[0] <= w_V;
			9:  in_data_v_r2[1] <= w_V;
			10: in_data_v_r2[2] <= w_V;
			11: in_data_v_r2[3] <= w_V;
			12: in_data_v_r2[4] <= w_V;
			13: in_data_v_r2[5] <= w_V;
			14: in_data_v_r2[6] <= w_V;
			15: in_data_v_r2[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r2[i] <= in_data_v_r2[i];
		end
	end
end

wire G_clock_in_data_v_r3 ;
wire G_s_in_data_v_r3 = !( count[7:0] > 143 && count[7:0] < 152);
GATED_OR GATED_indata_v_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r3));
always @(posedge G_clock_in_data_v_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r3[i] <= 0;
		end
	end
	else if ( count[7:0] > 143 && count[7:0] < 152) begin
		case (count[5:0])
			16: in_data_v_r3[0] <= w_V;
			17: in_data_v_r3[1] <= w_V;
			18: in_data_v_r3[2] <= w_V;
			19: in_data_v_r3[3] <= w_V;
			20: in_data_v_r3[4] <= w_V;
			21: in_data_v_r3[5] <= w_V;
			22: in_data_v_r3[6] <= w_V;
			23: in_data_v_r3[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r3[i] <= in_data_v_r3[i];
		end
	end
end

wire G_clock_in_data_v_r4 ;
wire G_s_in_data_v_r4 = !( count[7:0] > 151 && count[7:0] < 160);
GATED_OR GATED_indata_v_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r4));
always @(posedge G_clock_in_data_v_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r4[i] <= 0;
		end
	end
	else if ( count[7:0] > 151 && count[7:0] < 160) begin
		case (count[5:0])
			24: in_data_v_r4[0] <= w_V;
			25: in_data_v_r4[1] <= w_V;
			26: in_data_v_r4[2] <= w_V;
			27: in_data_v_r4[3] <= w_V;
			28: in_data_v_r4[4] <= w_V;
			29: in_data_v_r4[5] <= w_V;
			30: in_data_v_r4[6] <= w_V;
			31: in_data_v_r4[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r4[i] <= in_data_v_r4[i];
		end
	end
end

wire G_clock_in_data_v_r5 ;
wire G_s_in_data_v_r5 = !( count[7:0] > 159 && count[7:0] < 168);
GATED_OR GATED_indata_v_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r5));
always @(posedge G_clock_in_data_v_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r5[i] <= 0;
		end
	end
	else if ( count[7:0] > 159 && count[7:0] < 168) begin
		case (count[5:0])
			32: in_data_v_r5[0] <= w_V;
			33: in_data_v_r5[1] <= w_V;
			34: in_data_v_r5[2] <= w_V;
			35: in_data_v_r5[3] <= w_V;
			36: in_data_v_r5[4] <= w_V;
			37: in_data_v_r5[5] <= w_V;
			38: in_data_v_r5[6] <= w_V;
			39: in_data_v_r5[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r5[i] <= in_data_v_r5[i];
		end
	end
end

wire G_clock_in_data_v_r6 ;
wire G_s_in_data_v_r6 = !( count[7:0] > 167 && count[7:0] < 176);
GATED_OR GATED_indata_v_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r6));
always @(posedge G_clock_in_data_v_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r6[i] <= 0;
		end
	end
	else if ( count[7:0] > 167 && count[7:0] < 176) begin
		case (count[5:0])
			40: in_data_v_r6[0] <= w_V;
			41: in_data_v_r6[1] <= w_V;
			42: in_data_v_r6[2] <= w_V;
			43: in_data_v_r6[3] <= w_V;
			44: in_data_v_r6[4] <= w_V;
			45: in_data_v_r6[5] <= w_V;
			46: in_data_v_r6[6] <= w_V;
			47: in_data_v_r6[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r6[i] <= in_data_v_r6[i];
		end
	end
end

wire G_clock_in_data_v_r7 ;
wire G_s_in_data_v_r7 = !( count[7:0] > 175 && count[7:0] < 184);
GATED_OR GATED_indata_v_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r7));
always @(posedge G_clock_in_data_v_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r7[i] <= 0;
		end
	end
	else if ( count[7:0] > 175 && count[7:0] < 184) begin
		case (count[5:0])
			48: in_data_v_r7[0] <= w_V;
			49: in_data_v_r7[1] <= w_V;
			50: in_data_v_r7[2] <= w_V;
			51: in_data_v_r7[3] <= w_V;
			52: in_data_v_r7[4] <= w_V;
			53: in_data_v_r7[5] <= w_V;
			54: in_data_v_r7[6] <= w_V;
			55: in_data_v_r7[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r7[i] <= in_data_v_r7[i];
		end
	end
end

wire G_clock_in_data_v_r8 ;
wire G_s_in_data_v_r8 = !( count[7:0] > 183 && count[7:0] < 192);
GATED_OR GATED_indata_v_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_in_data_v_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_in_data_v_r8));
always @(posedge G_clock_in_data_v_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r8[i] <= 0;
		end
	end
	else if ( count[7:0] > 183 && count[7:0] < 192) begin
		case (count[5:0])
			56: in_data_v_r8[0] <= w_V;
			57: in_data_v_r8[1] <= w_V;
			58: in_data_v_r8[2] <= w_V;
			59: in_data_v_r8[3] <= w_V;
			60: in_data_v_r8[4] <= w_V;
			61: in_data_v_r8[5] <= w_V;
			62: in_data_v_r8[6] <= w_V;
			63: in_data_v_r8[7] <= w_V;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			in_data_v_r8[i] <= in_data_v_r8[i];
		end
	end
end

/////////////////////////////////////////////////
///               mult_1                ////////////
//////////////////////////////////////////////

assign mul_wen = count[7] | count[6];
assign mul_wen_3 = count[7] & count[6];
assign mul_wen_1 = (count[7:6] == 1)? 1:0;
assign mul_wen_2 = (count[7:6] == 2)? 1:0;



always @(posedge clk or negedge rst_n) begin
	if (!rst_n)  mul_wen_reg <= 0;
	else	mul_wen_reg <= mul_wen;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)  mul_wen_1_reg <= 0;
	else	mul_wen_1_reg <= mul_wen_1;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)  mul_wen_2_reg <= 0;
	else	mul_wen_2_reg <= mul_wen_2;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)  mul_wen_3_reg <= 0;
	else	mul_wen_3_reg <= mul_wen_3;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)  mul_wen_3_reg_scal <= 0;
	else	mul_wen_3_reg_scal <= mul_wen_3_reg;
end

////////////////////////////////////////////

wire G_clock_mult_1 ;
wire G_s_mult_1 = !(mul_wen);
GATED_OR GATED_mult_1 (.CLOCK(clk), .SLEEP_CTRL(G_s_mult_1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_mult_1));
always @(posedge G_clock_mult_1 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			mult_1[i] <= 0;
		end
	end
	else if (cs == READ && count[5:0] < 8 && mul_wen ) begin
		mult_1[0] <= in_data_r1[0];
		mult_1[1] <= in_data_r1[1];
		mult_1[2] <= in_data_r1[2];
		mult_1[3] <= in_data_r1[3];
		mult_1[4] <= in_data_r1[4];
		mult_1[5] <= in_data_r1[5];
		mult_1[6] <= in_data_r1[6];
		mult_1[7] <= in_data_r1[7];
	end
	else if (cs == READ && count[5:0] > 7 && count[5:0] < 16 && (T_reg == 4 || T_reg == 8) && mul_wen ) begin
		mult_1[0] <= in_data_r2[0];
		mult_1[1] <= in_data_r2[1];
		mult_1[2] <= in_data_r2[2];
		mult_1[3] <= in_data_r2[3];
		mult_1[4] <= in_data_r2[4];
		mult_1[5] <= in_data_r2[5];
		mult_1[6] <= in_data_r2[6];
		mult_1[7] <= in_data_r2[7];
	end
	else if (cs == READ && count[5:0] > 15 && count[5:0] < 24 && (T_reg == 4 || T_reg == 8) && mul_wen ) begin
		mult_1[0] <= in_data_r3[0];
		mult_1[1] <= in_data_r3[1];
		mult_1[2] <= in_data_r3[2];
		mult_1[3] <= in_data_r3[3];
		mult_1[4] <= in_data_r3[4];
		mult_1[5] <= in_data_r3[5];
		mult_1[6] <= in_data_r3[6];
		mult_1[7] <= in_data_r3[7];
	end
	else if (cs == READ && count[5:0] > 23 && count[5:0] < 32 && (T_reg == 4 || T_reg == 8) && mul_wen ) begin
		mult_1[0] <= in_data_r4[0];
		mult_1[1] <= in_data_r4[1];
		mult_1[2] <= in_data_r4[2];
		mult_1[3] <= in_data_r4[3];
		mult_1[4] <= in_data_r4[4];
		mult_1[5] <= in_data_r4[5];
		mult_1[6] <= in_data_r4[6];
		mult_1[7] <= in_data_r4[7];
	end
	else if (cs == READ && count[5:0] > 31 && count[5:0] < 40 &&  T_reg == 8 && mul_wen ) begin
		mult_1[0] <= in_data_r5[0];
		mult_1[1] <= in_data_r5[1];
		mult_1[2] <= in_data_r5[2];
		mult_1[3] <= in_data_r5[3];
		mult_1[4] <= in_data_r5[4];
		mult_1[5] <= in_data_r5[5];
		mult_1[6] <= in_data_r5[6];
		mult_1[7] <= in_data_r5[7];
	end
	else if (cs == READ && count[5:0] > 39 && count[5:0] < 48 &&  T_reg == 8 && mul_wen ) begin
		mult_1[0] <= in_data_r6[0];
		mult_1[1] <= in_data_r6[1];
		mult_1[2] <= in_data_r6[2];
		mult_1[3] <= in_data_r6[3];
		mult_1[4] <= in_data_r6[4];
		mult_1[5] <= in_data_r6[5];
		mult_1[6] <= in_data_r6[6];
		mult_1[7] <= in_data_r6[7];
	end
	else if (cs == READ && count[5:0] > 47 && count[5:0] < 56 &&  T_reg == 8 && mul_wen ) begin
		mult_1[0] <= in_data_r7[0];
		mult_1[1] <= in_data_r7[1];
		mult_1[2] <= in_data_r7[2];
		mult_1[3] <= in_data_r7[3];
		mult_1[4] <= in_data_r7[4];
		mult_1[5] <= in_data_r7[5];
		mult_1[6] <= in_data_r7[6];
		mult_1[7] <= in_data_r7[7];
	end
	else if (cs == READ && count[5:0] > 55 && count[5:0] < 64 &&  T_reg == 8 && mul_wen ) begin
		mult_1[0] <= in_data_r8[0];
		mult_1[1] <= in_data_r8[1];
		mult_1[2] <= in_data_r8[2];
		mult_1[3] <= in_data_r8[3];
		mult_1[4] <= in_data_r8[4];
		mult_1[5] <= in_data_r8[5];
		mult_1[6] <= in_data_r8[6];
		mult_1[7] <= in_data_r8[7];
	end
	else begin
		for (i = 0; i < 8; i++) begin
			mult_1[i] <= mult_1[i];
		end
	end
end

wire G_clock_mult_2 ;
wire G_s_mult_2 = !(mul_wen);
GATED_OR GATED_mult_2 (.CLOCK(clk), .SLEEP_CTRL(G_s_mult_2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_mult_2));
always @(posedge G_clock_mult_2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			mult_2[i] <= 0;
		end
	end
	else if (cs == READ && mul_wen) begin
		if (mul_wen_1) begin
			mult_2[0] <= in_data_q_r1[mult_count_in2];
			mult_2[1] <= in_data_q_r2[mult_count_in2];
			mult_2[2] <= in_data_q_r3[mult_count_in2];
			mult_2[3] <= in_data_q_r4[mult_count_in2];
			mult_2[4] <= in_data_q_r5[mult_count_in2];
			mult_2[5] <= in_data_q_r6[mult_count_in2];
			mult_2[6] <= in_data_q_r7[mult_count_in2];
			mult_2[7] <= in_data_q_r8[mult_count_in2];
		end
		else if (mul_wen_2) begin
			mult_2[0] <= in_data_k_r1[mult_count_in2];
			mult_2[1] <= in_data_k_r2[mult_count_in2];
			mult_2[2] <= in_data_k_r3[mult_count_in2];
			mult_2[3] <= in_data_k_r4[mult_count_in2];
			mult_2[4] <= in_data_k_r5[mult_count_in2];
			mult_2[5] <= in_data_k_r6[mult_count_in2];
			mult_2[6] <= in_data_k_r7[mult_count_in2];
			mult_2[7] <= in_data_k_r8[mult_count_in2];
		end
		else if (mul_wen_3) begin
			mult_2[0] <= in_data_v_r1[mult_count_in2];
			mult_2[1] <= in_data_v_r2[mult_count_in2];
			mult_2[2] <= in_data_v_r3[mult_count_in2];
			mult_2[3] <= in_data_v_r4[mult_count_in2];
			mult_2[4] <= in_data_v_r5[mult_count_in2];
			mult_2[5] <= in_data_v_r6[mult_count_in2];
			mult_2[6] <= in_data_v_r7[mult_count_in2];
			mult_2[7] <= in_data_v_r8[mult_count_in2];
		end
	end
	else begin
		for (i = 0; i < 8; i++) begin
			mult_2[i] <= mult_2[i];
		end
	end
end

reg signed [19:0] mult_ans;

always @(*) begin
	mult_ans = mult_1[0]*mult_2[0] + mult_1[1]*mult_2[1] + mult_1[2]*mult_2[2] + mult_1[3]*mult_2[3] + mult_1[4]*mult_2[4] + mult_1[5]*mult_2[5] + mult_1[6]*mult_2[6] + mult_1[7]*mult_2[7];
end


/////////////////////////////////////////////////
///               save Q K V              ////////////
//////////////////////////////////////////////


wire G_clock_Q_r1;
wire G_s_Q_r1 = !(mul_wen_1_reg && count_QK[5:0] < 8);
GATED_OR GATED_Q_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r1));
always @(posedge G_clock_Q_r1 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r1[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] < 8) begin
		case (count_QK[5:0])
			0: Q_r1[0] <= mult_ans;
			1: Q_r1[1] <= mult_ans;
			2: Q_r1[2] <= mult_ans;
			3: Q_r1[3] <= mult_ans;
			4: Q_r1[4] <= mult_ans;
			5: Q_r1[5] <= mult_ans;
			6: Q_r1[6] <= mult_ans;
			7: Q_r1[7] <= mult_ans;
		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r1[i] <= Q_r1[i];
		end
	end
end


wire G_clock_Q_r2;
wire G_s_Q_r2 = !(mul_wen_1_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 );
GATED_OR GATED_Q_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r2));
always @(posedge G_clock_Q_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r2[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			8:  Q_r2[0] <= mult_ans;
			9:  Q_r2[1] <= mult_ans;
			10: Q_r2[2] <= mult_ans;
			11: Q_r2[3] <= mult_ans;
			12: Q_r2[4] <= mult_ans;
			13: Q_r2[5] <= mult_ans;
			14: Q_r2[6] <= mult_ans;
			15: Q_r2[7] <= mult_ans;

		endcase
	end
    else if (mul_wen_1_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 && T_reg == 1) begin
		case (count_QK[5:0])
			8:  Q_r2[0] <= 0;
			9:  Q_r2[1] <= 0;
			10: Q_r2[2] <= 0;
			11: Q_r2[3] <= 0;
			12: Q_r2[4] <= 0;
			13: Q_r2[5] <= 0;
			14: Q_r2[6] <= 0;
			15: Q_r2[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r2[i] <= Q_r2[i];
		end
	end
end

wire G_clock_Q_r3;
wire G_s_Q_r3 = !(mul_wen_1_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24 );
GATED_OR GATED_Q_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r3));
always @(posedge G_clock_Q_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r3[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			16: Q_r3[0] <= mult_ans;
			17: Q_r3[1] <= mult_ans;
			18: Q_r3[2] <= mult_ans;
			19: Q_r3[3] <= mult_ans;
			20: Q_r3[4] <= mult_ans;
			21: Q_r3[5] <= mult_ans;
			22: Q_r3[6] <= mult_ans;
			23: Q_r3[7] <= mult_ans;

		endcase
	end
    else if (mul_wen_1_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24 && (T_reg == 1)) begin
		case (count_QK[5:0])
			16: Q_r3[0] <= 0;
			17: Q_r3[1] <= 0;
			18: Q_r3[2] <= 0;
			19: Q_r3[3] <= 0;
			20: Q_r3[4] <= 0;
			21: Q_r3[5] <= 0;
			22: Q_r3[6] <= 0;
			23: Q_r3[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r3[i] <= Q_r3[i];
		end
	end
end


wire G_clock_Q_r4;
wire G_s_Q_r4 = !(mul_wen_1_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 );
GATED_OR GATED_Q_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r4));
always @(posedge G_clock_Q_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r4[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			24: Q_r4[0] <= mult_ans;
			25: Q_r4[1] <= mult_ans;
			26: Q_r4[2] <= mult_ans;
			27: Q_r4[3] <= mult_ans;
			28: Q_r4[4] <= mult_ans;
			29: Q_r4[5] <= mult_ans;
			30: Q_r4[6] <= mult_ans;
			31: Q_r4[7] <= mult_ans;

		endcase
	end
    else if (mul_wen_1_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 && (T_reg == 1)) begin
		case (count_QK[5:0])
			24: Q_r4[0] <= 0;
			25: Q_r4[1] <= 0;
			26: Q_r4[2] <= 0;
			27: Q_r4[3] <= 0;
			28: Q_r4[4] <= 0;
			29: Q_r4[5] <= 0;
			30: Q_r4[6] <= 0;
			31: Q_r4[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r4[i] <= Q_r4[i];
		end
	end
end


wire G_clock_Q_r5;
wire G_s_Q_r5 = !(mul_wen_1_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 );
GATED_OR GATED_Q_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r5));
always @(posedge G_clock_Q_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r5[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 && T_reg == 8) begin
		case (count_QK[5:0])
			32: Q_r5[0] <= mult_ans;
			33: Q_r5[1] <= mult_ans;
			34: Q_r5[2] <= mult_ans;
			35: Q_r5[3] <= mult_ans;
			36: Q_r5[4] <= mult_ans;
			37: Q_r5[5] <= mult_ans;
			38: Q_r5[6] <= mult_ans;
			39: Q_r5[7] <= mult_ans;

		endcase
	end
    else if (mul_wen_1_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			32: Q_r5[0] <= 0;
			33: Q_r5[1] <= 0;
			34: Q_r5[2] <= 0;
			35: Q_r5[3] <= 0;
			36: Q_r5[4] <= 0;
			37: Q_r5[5] <= 0;
			38: Q_r5[6] <= 0;
			39: Q_r5[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r5[i] <= Q_r5[i];
		end
	end
end

wire G_clock_Q_r6;
wire G_s_Q_r6 = !(mul_wen_1_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 );
GATED_OR GATED_Q_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r6));
always @(posedge G_clock_Q_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r6[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 && T_reg == 8) begin
		case (count_QK[5:0])
			40: Q_r6[0] <= mult_ans;
			41: Q_r6[1] <= mult_ans;
			42: Q_r6[2] <= mult_ans;
			43: Q_r6[3] <= mult_ans;
			44: Q_r6[4] <= mult_ans;
			45: Q_r6[5] <= mult_ans;
			46: Q_r6[6] <= mult_ans;
			47: Q_r6[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			40: Q_r6[0] <= 0;
			41: Q_r6[1] <= 0;
			42: Q_r6[2] <= 0;
			43: Q_r6[3] <= 0;
			44: Q_r6[4] <= 0;
			45: Q_r6[5] <= 0;
			46: Q_r6[6] <= 0;
			47: Q_r6[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r6[i] <= Q_r6[i];
		end
	end
end

wire G_clock_Q_r7;
wire G_s_Q_r7 = !(mul_wen_1_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 );
GATED_OR GATED_Q_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r7));
always @(posedge G_clock_Q_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r7[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 && T_reg == 8) begin
		case (count_QK[5:0])
			48: Q_r7[0] <= mult_ans;
			49: Q_r7[1] <= mult_ans;
			50: Q_r7[2] <= mult_ans;
			51: Q_r7[3] <= mult_ans;
			52: Q_r7[4] <= mult_ans;
			53: Q_r7[5] <= mult_ans;
			54: Q_r7[6] <= mult_ans;
			55: Q_r7[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			48: Q_r7[0] <= 0;
			49: Q_r7[1] <= 0;
			50: Q_r7[2] <= 0;
			51: Q_r7[3] <= 0;
			52: Q_r7[4] <= 0;
			53: Q_r7[5] <= 0;
			54: Q_r7[6] <= 0;
			55: Q_r7[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r7[i] <= Q_r7[i];
		end
	end
end


wire G_clock_Q_r8;
wire G_s_Q_r8 = !(mul_wen_1_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 );
GATED_OR GATED_Q_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_Q_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_Q_r8));
always @(posedge G_clock_Q_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			Q_r8[i] <= 0;
		end
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 && T_reg == 8) begin
		case (count_QK[5:0])
			56: Q_r8[0] <= mult_ans;
			57: Q_r8[1] <= mult_ans;
			58: Q_r8[2] <= mult_ans;
			59: Q_r8[3] <= mult_ans;
			60: Q_r8[4] <= mult_ans;
			61: Q_r8[5] <= mult_ans;
			62: Q_r8[6] <= mult_ans;
			63: Q_r8[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_1_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			56: Q_r8[0] <= 0;
			57: Q_r8[1] <= 0;
			58: Q_r8[2] <= 0;
			59: Q_r8[3] <= 0;
			60: Q_r8[4] <= 0;
			61: Q_r8[5] <= 0;
			62: Q_r8[6] <= 0;
			63: Q_r8[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			Q_r8[i] <= Q_r8[i];
		end
	end
end




wire G_clock_K_r1;
wire G_s_K_r1 = !(mul_wen_2_reg && count_QK[5:0] < 8);
GATED_OR GATED_K_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r1));
always @(posedge G_clock_K_r1 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r1[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] < 8) begin
		case (count_QK[5:0])
			0: K_r1[0] <= mult_ans;
			1: K_r1[1] <= mult_ans;
			2: K_r1[2] <= mult_ans;
			3: K_r1[3] <= mult_ans;
			4: K_r1[4] <= mult_ans;
			5: K_r1[5] <= mult_ans;
			6: K_r1[6] <= mult_ans;
			7: K_r1[7] <= mult_ans;
		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r1[i] <= K_r1[i];
		end
	end
end

wire G_clock_K_r2;
wire G_s_K_r2 = !(mul_wen_2_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 );
GATED_OR GATED_K_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r2));
always @(posedge G_clock_K_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r2[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			8:  K_r2[0] <= mult_ans;
			9:  K_r2[1] <= mult_ans;
			10: K_r2[2] <= mult_ans;
			11: K_r2[3] <= mult_ans;
			12: K_r2[4] <= mult_ans;
			13: K_r2[5] <= mult_ans;
			14: K_r2[6] <= mult_ans;
			15: K_r2[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 && (T_reg == 1)) begin
		case (count_QK[5:0])
			8:  K_r2[0] <= 0;
			9:  K_r2[1] <= 0;
			10: K_r2[2] <= 0;
			11: K_r2[3] <= 0;
			12: K_r2[4] <= 0;
			13: K_r2[5] <= 0;
			14: K_r2[6] <= 0;
			15: K_r2[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r2[i] <= K_r2[i];
		end
	end
end

wire G_clock_K_r3;
wire G_s_K_r3 = !(mul_wen_2_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24 );
GATED_OR GATED_K_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r3));
always @(posedge G_clock_K_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r3[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			16: K_r3[0] <= mult_ans;
			17: K_r3[1] <= mult_ans;
			18: K_r3[2] <= mult_ans;
			19: K_r3[3] <= mult_ans;
			20: K_r3[4] <= mult_ans;
			21: K_r3[5] <= mult_ans;
			22: K_r3[6] <= mult_ans;
			23: K_r3[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24 && (T_reg == 1)) begin
		case (count_QK[5:0])
			16: K_r3[0] <= 0;
			17: K_r3[1] <= 0;
			18: K_r3[2] <= 0;
			19: K_r3[3] <= 0;
			20: K_r3[4] <= 0;
			21: K_r3[5] <= 0;
			22: K_r3[6] <= 0;
			23: K_r3[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r3[i] <= K_r3[i];
		end
	end
end

wire G_clock_K_r4;
wire G_s_K_r4 = !(mul_wen_2_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 );
GATED_OR GATED_K_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r4));
always @(posedge G_clock_K_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r4[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			24: K_r4[0] <= mult_ans;
			25: K_r4[1] <= mult_ans;
			26: K_r4[2] <= mult_ans;
			27: K_r4[3] <= mult_ans;
			28: K_r4[4] <= mult_ans;
			29: K_r4[5] <= mult_ans;
			30: K_r4[6] <= mult_ans;
			31: K_r4[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 && (T_reg == 1)) begin
		case (count_QK[5:0])
			24: K_r4[0] <= 0;
			25: K_r4[1] <= 0;
			26: K_r4[2] <= 0;
			27: K_r4[3] <= 0;
			28: K_r4[4] <= 0;
			29: K_r4[5] <= 0;
			30: K_r4[6] <= 0;
			31: K_r4[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r4[i] <= K_r4[i];
		end
	end
end

wire G_clock_K_r5;
wire G_s_K_r5 = !(mul_wen_2_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 );
GATED_OR GATED_K_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r5));
always @(posedge G_clock_K_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r5[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 && T_reg == 8) begin
		case (count_QK[5:0])
			32: K_r5[0] <= mult_ans;
			33: K_r5[1] <= mult_ans;
			34: K_r5[2] <= mult_ans;
			35: K_r5[3] <= mult_ans;
			36: K_r5[4] <= mult_ans;
			37: K_r5[5] <= mult_ans;
			38: K_r5[6] <= mult_ans;
			39: K_r5[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			32: K_r5[0] <= 0;
			33: K_r5[1] <= 0;
			34: K_r5[2] <= 0;
			35: K_r5[3] <= 0;
			36: K_r5[4] <= 0;
			37: K_r5[5] <= 0;
			38: K_r5[6] <= 0;
			39: K_r5[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r5[i] <= K_r5[i];
		end
	end
end

wire G_clock_K_r6;
wire G_s_K_r6 = !(mul_wen_2_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 );
GATED_OR GATED_K_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r6));
always @(posedge G_clock_K_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r6[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 && T_reg == 8) begin
		case (count_QK[5:0])
			40: K_r6[0] <= mult_ans;
			41: K_r6[1] <= mult_ans;
			42: K_r6[2] <= mult_ans;
			43: K_r6[3] <= mult_ans;
			44: K_r6[4] <= mult_ans;
			45: K_r6[5] <= mult_ans;
			46: K_r6[6] <= mult_ans;
			47: K_r6[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			40: K_r6[0] <= 0;
			41: K_r6[1] <= 0;
			42: K_r6[2] <= 0;
			43: K_r6[3] <= 0;
			44: K_r6[4] <= 0;
			45: K_r6[5] <= 0;
			46: K_r6[6] <= 0;
			47: K_r6[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r6[i] <= K_r6[i];
		end
	end
end

wire G_clock_K_r7;
wire G_s_K_r7 = !(mul_wen_2_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 );
GATED_OR GATED_K_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r7));
always @(posedge G_clock_K_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r7[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 && T_reg == 8) begin
		case (count_QK[5:0])
			48: K_r7[0] <= mult_ans;
			49: K_r7[1] <= mult_ans;
			50: K_r7[2] <= mult_ans;
			51: K_r7[3] <= mult_ans;
			52: K_r7[4] <= mult_ans;
			53: K_r7[5] <= mult_ans;
			54: K_r7[6] <= mult_ans;
			55: K_r7[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			48: K_r7[0] <= 0;
			49: K_r7[1] <= 0;
			50: K_r7[2] <= 0;
			51: K_r7[3] <= 0;
			52: K_r7[4] <= 0;
			53: K_r7[5] <= 0;
			54: K_r7[6] <= 0;
			55: K_r7[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r7[i] <= K_r7[i];
		end
	end
end

wire G_clock_K_r8;
wire G_s_K_r8 = !(mul_wen_2_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 );
GATED_OR GATED_K_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_K_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_K_r8));
always @(posedge G_clock_K_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			K_r8[i] <= 0;
		end
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 && T_reg == 8) begin
		case (count_QK[5:0])
			56: K_r8[0] <= mult_ans;
			57: K_r8[1] <= mult_ans;
			58: K_r8[2] <= mult_ans;
			59: K_r8[3] <= mult_ans;
			60: K_r8[4] <= mult_ans;
			61: K_r8[5] <= mult_ans;
			62: K_r8[6] <= mult_ans;
			63: K_r8[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_2_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			56: K_r8[0] <= 0;
			57: K_r8[1] <= 0;
			58: K_r8[2] <= 0;
			59: K_r8[3] <= 0;
			60: K_r8[4] <= 0;
			61: K_r8[5] <= 0;
			62: K_r8[6] <= 0;
			63: K_r8[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			K_r8[i] <= K_r8[i];
		end
	end
end


wire G_clock_V_r1;
wire G_s_V_r1 = !(mul_wen_3_reg && count_QK[5:0] < 8);
GATED_OR GATED_V_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r1));
always @(posedge G_clock_V_r1 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r1[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] < 8) begin
		case (count_QK[5:0])
			0: V_r1[0] <= mult_ans;
			1: V_r1[1] <= mult_ans;
			2: V_r1[2] <= mult_ans;
			3: V_r1[3] <= mult_ans;
			4: V_r1[4] <= mult_ans;
			5: V_r1[5] <= mult_ans;
			6: V_r1[6] <= mult_ans;
			7: V_r1[7] <= mult_ans;
		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r1[i] <= V_r1[i];
		end
	end
end

wire G_clock_V_r2;
wire G_s_V_r2 = !(mul_wen_3_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 );
GATED_OR GATED_V_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r2));
always @(posedge G_clock_V_r2 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r2[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			8:  V_r2[0] <= mult_ans;
			9:  V_r2[1] <= mult_ans;
			10: V_r2[2] <= mult_ans;
			11: V_r2[3] <= mult_ans;
			12: V_r2[4] <= mult_ans;
			13: V_r2[5] <= mult_ans;
			14: V_r2[6] <= mult_ans;
			15: V_r2[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 7 && count_QK[5:0] < 16 && (T_reg == 1)) begin
		case (count_QK[5:0])
			8:  V_r2[0] <= 0;
			9:  V_r2[1] <= 0;
			10: V_r2[2] <= 0;
			11: V_r2[3] <= 0;
			12: V_r2[4] <= 0;
			13: V_r2[5] <= 0;
			14: V_r2[6] <= 0;
			15: V_r2[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r2[i] <= V_r2[i];
		end
	end
end

wire G_clock_V_r3;
wire G_s_V_r3 = !(mul_wen_3_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24);
GATED_OR GATED_V_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r3));
always @(posedge G_clock_V_r3 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r3[i] <= 0;
		end
	end
    else if (mul_wen_3_reg && count_QK[5:0] > 15 && count_QK[5:0] < 24) begin
        if (T_reg == 4 || T_reg == 8) begin
            case (count_QK[5:0])
                16: V_r3[0] <= mult_ans;
                17: V_r3[1] <= mult_ans;
                18: V_r3[2] <= mult_ans;
                19: V_r3[3] <= mult_ans;
                20: V_r3[4] <= mult_ans;
                21: V_r3[5] <= mult_ans;
                22: V_r3[6] <= mult_ans;
                23: V_r3[7] <= mult_ans;

            endcase
        end
        else if (T_reg == 1) begin
            case (count_QK[5:0])
                16: V_r3[0] <= 0;
                17: V_r3[1] <= 0;
                18: V_r3[2] <= 0;
                19: V_r3[3] <= 0;
                20: V_r3[4] <= 0;
                21: V_r3[5] <= 0;
                22: V_r3[6] <= 0;
                23: V_r3[7] <= 0;
            endcase
        end
    end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r3[i] <= V_r3[i];
		end
	end
end

wire G_clock_V_r4;
wire G_s_V_r4 = !(mul_wen_3_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 );
GATED_OR GATED_V_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r4));
always @(posedge G_clock_V_r4 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r4[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 && (T_reg == 4 || T_reg == 8)) begin
		case (count_QK[5:0])
			24: V_r4[0] <= mult_ans;
			25: V_r4[1] <= mult_ans;
			26: V_r4[2] <= mult_ans;
			27: V_r4[3] <= mult_ans;
			28: V_r4[4] <= mult_ans;
			29: V_r4[5] <= mult_ans;
			30: V_r4[6] <= mult_ans;
			31: V_r4[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 23 && count_QK[5:0] < 32 && (T_reg == 1)) begin
		case (count_QK[5:0])
			24: V_r4[0] <= 0;
			25: V_r4[1] <= 0;
			26: V_r4[2] <= 0;
			27: V_r4[3] <= 0;
			28: V_r4[4] <= 0;
			29: V_r4[5] <= 0;
			30: V_r4[6] <= 0;
			31: V_r4[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r4[i] <= V_r4[i];
		end
	end
end

wire G_clock_V_r5;
wire G_s_V_r5 = !(mul_wen_3_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 );
GATED_OR GATED_V_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r5));
always @(posedge G_clock_V_r5 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r5[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 && T_reg == 8) begin
		case (count_QK[5:0])
			32: V_r5[0] <= mult_ans;
			33: V_r5[1] <= mult_ans;
			34: V_r5[2] <= mult_ans;
			35: V_r5[3] <= mult_ans;
			36: V_r5[4] <= mult_ans;
			37: V_r5[5] <= mult_ans;
			38: V_r5[6] <= mult_ans;
			39: V_r5[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 31 && count_QK[5:0] < 40 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			32: V_r5[0] <= 0;
			33: V_r5[1] <= 0;
			34: V_r5[2] <= 0;
			35: V_r5[3] <= 0;
			36: V_r5[4] <= 0;
			37: V_r5[5] <= 0;
			38: V_r5[6] <= 0;
			39: V_r5[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r5[i] <= V_r5[i];
		end
	end
end

wire G_clock_V_r6;
wire G_s_V_r6 = !(mul_wen_3_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 );
GATED_OR GATED_V_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r6));
always @(posedge G_clock_V_r6 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r6[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 && T_reg == 8) begin
		case (count_QK[5:0])
			40: V_r6[0] <= mult_ans;
			41: V_r6[1] <= mult_ans;
			42: V_r6[2] <= mult_ans;
			43: V_r6[3] <= mult_ans;
			44: V_r6[4] <= mult_ans;
			45: V_r6[5] <= mult_ans;
			46: V_r6[6] <= mult_ans;
			47: V_r6[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 39 && count_QK[5:0] < 48 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			40: V_r6[0] <= 0;
			41: V_r6[1] <= 0;
			42: V_r6[2] <= 0;
			43: V_r6[3] <= 0;
			44: V_r6[4] <= 0;
			45: V_r6[5] <= 0;
			46: V_r6[6] <= 0;
			47: V_r6[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r6[i] <= V_r6[i];
		end
	end
end

wire G_clock_V_r7;
wire G_s_V_r7 = !(mul_wen_3_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 );
GATED_OR GATED_V_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r7));
always @(posedge G_clock_V_r7 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r7[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 && T_reg == 8) begin
		case (count_QK[5:0])
			48: V_r7[0] <= mult_ans;
			49: V_r7[1] <= mult_ans;
			50: V_r7[2] <= mult_ans;
			51: V_r7[3] <= mult_ans;
			52: V_r7[4] <= mult_ans;
			53: V_r7[5] <= mult_ans;
			54: V_r7[6] <= mult_ans;
			55: V_r7[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 47 && count_QK[5:0] < 56 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			48: V_r7[0] <= 0;
			49: V_r7[1] <= 0;
			50: V_r7[2] <= 0;
			51: V_r7[3] <= 0;
			52: V_r7[4] <= 0;
			53: V_r7[5] <= 0;
			54: V_r7[6] <= 0;
			55: V_r7[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r7[i] <= V_r7[i];
		end
	end
end

wire G_clock_V_r8;
wire G_s_V_r8 = !(mul_wen_3_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 );
GATED_OR GATED_V_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_V_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_V_r8));
always @(posedge G_clock_V_r8 or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			V_r8[i] <= 0;
		end
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 && T_reg == 8) begin
		case (count_QK[5:0])
			56: V_r8[0] <= mult_ans;
			57: V_r8[1] <= mult_ans;
			58: V_r8[2] <= mult_ans;
			59: V_r8[3] <= mult_ans;
			60: V_r8[4] <= mult_ans;
			61: V_r8[5] <= mult_ans;
			62: V_r8[6] <= mult_ans;
			63: V_r8[7] <= mult_ans;

		endcase
	end
	else if (mul_wen_3_reg && count_QK[5:0] > 55 && count_QK[5:0] < 64 && (T_reg == 4 || T_reg == 1)) begin
		case (count_QK[5:0])
			56: V_r8[0] <= 0;
			57: V_r8[1] <= 0;
			58: V_r8[2] <= 0;
			59: V_r8[3] <= 0;
			60: V_r8[4] <= 0;
			61: V_r8[5] <= 0;
			62: V_r8[6] <= 0;
			63: V_r8[7] <= 0;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			V_r8[i] <= V_r8[i];
		end
	end
end



/////////////////////////////////////////////////
///               MULT Q K    T          ////////////
//////////////////////////////////////////////

//wire G_clock_mult_Q;
//wire G_s_mult_Q = !(mul_wen_3_reg );
//GATED_OR GATED_mult_Q (.CLOCK(clk), .SLEEP_CTRL(G_s_mult_Q && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_mult_Q));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			mult_Q[i] <= 0;
		end
	end
	else if ( count_QK[5:0] < 8 && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r1[0];
		mult_Q[1] <= Q_r1[1];
		mult_Q[2] <= Q_r1[2];
		mult_Q[3] <= Q_r1[3];
		mult_Q[4] <= Q_r1[4];
		mult_Q[5] <= Q_r1[5];
		mult_Q[6] <= Q_r1[6];
		mult_Q[7] <= Q_r1[7];
	end
	else if ( count_QK[5:0] > 7 && count_QK[5:0] < 16  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r2[0];
		mult_Q[1] <= Q_r2[1];
		mult_Q[2] <= Q_r2[2];
		mult_Q[3] <= Q_r2[3];
		mult_Q[4] <= Q_r2[4];
		mult_Q[5] <= Q_r2[5];
		mult_Q[6] <= Q_r2[6];
		mult_Q[7] <= Q_r2[7];
	end
	else if ( count_QK[5:0] > 15 && count_QK[5:0] < 24  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r3[0];
		mult_Q[1] <= Q_r3[1];
		mult_Q[2] <= Q_r3[2];
		mult_Q[3] <= Q_r3[3];
		mult_Q[4] <= Q_r3[4];
		mult_Q[5] <= Q_r3[5];
		mult_Q[6] <= Q_r3[6];
		mult_Q[7] <= Q_r3[7];
	end
	else if ( count_QK[5:0] > 23 && count_QK[5:0] < 32  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r4[0];
		mult_Q[1] <= Q_r4[1];
		mult_Q[2] <= Q_r4[2];
		mult_Q[3] <= Q_r4[3];
		mult_Q[4] <= Q_r4[4];
		mult_Q[5] <= Q_r4[5];
		mult_Q[6] <= Q_r4[6];
		mult_Q[7] <= Q_r4[7];
	end
	else if ( count_QK[5:0] > 31 && count_QK[5:0] < 40  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r5[0];
		mult_Q[1] <= Q_r5[1];
		mult_Q[2] <= Q_r5[2];
		mult_Q[3] <= Q_r5[3];
		mult_Q[4] <= Q_r5[4];
		mult_Q[5] <= Q_r5[5];
		mult_Q[6] <= Q_r5[6];
		mult_Q[7] <= Q_r5[7];
	end
	else if ( count_QK[5:0] > 39 && count_QK[5:0] < 48  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r6[0];
		mult_Q[1] <= Q_r6[1];
		mult_Q[2] <= Q_r6[2];
		mult_Q[3] <= Q_r6[3];
		mult_Q[4] <= Q_r6[4];
		mult_Q[5] <= Q_r6[5];
		mult_Q[6] <= Q_r6[6];
		mult_Q[7] <= Q_r6[7];
	end
	else if ( count_QK[5:0] > 47 && count_QK[5:0] < 56  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r7[0];
		mult_Q[1] <= Q_r7[1];
		mult_Q[2] <= Q_r7[2];
		mult_Q[3] <= Q_r7[3];
		mult_Q[4] <= Q_r7[4];
		mult_Q[5] <= Q_r7[5];
		mult_Q[6] <= Q_r7[6];
		mult_Q[7] <= Q_r7[7];
	end
	else if ( count_QK[5:0] > 55 && count_QK[5:0] < 64  && mul_wen_3_reg ) begin
		mult_Q[0] <= Q_r8[0];
		mult_Q[1] <= Q_r8[1];
		mult_Q[2] <= Q_r8[2];
		mult_Q[3] <= Q_r8[3];
		mult_Q[4] <= Q_r8[4];
		mult_Q[5] <= Q_r8[5];
		mult_Q[6] <= Q_r8[6];
		mult_Q[7] <= Q_r8[7];
	end
	else begin
		for (i = 0; i < 8; i++) begin
			mult_Q[i] <=mult_Q[i];
		end
	end
end

//wire G_clock_mult_K ;
//wire G_s_mult_K = !(mul_wen_3_reg);
//GATED_OR GATED_mult_K (.CLOCK(clk), .SLEEP_CTRL(G_s_mult_K && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_mult_K));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			mult_K[i] <= 0;
		end
	end
	else if (cs == READ ) begin
		if (mul_wen_3_reg && T_reg == 8) begin
			case (count_QK_2)
				0: begin
					mult_K[0] <= K_r1[0];
					mult_K[1] <= K_r1[1];
					mult_K[2] <= K_r1[2];
					mult_K[3] <= K_r1[3];
					mult_K[4] <= K_r1[4];
					mult_K[5] <= K_r1[5];
					mult_K[6] <= K_r1[6];
					mult_K[7] <= K_r1[7];
				end
				1: begin
					mult_K[0] <= K_r2[0];
					mult_K[1] <= K_r2[1];
					mult_K[2] <= K_r2[2];
					mult_K[3] <= K_r2[3];
					mult_K[4] <= K_r2[4];
					mult_K[5] <= K_r2[5];
					mult_K[6] <= K_r2[6];
					mult_K[7] <= K_r2[7];
				end
				2: begin
					mult_K[0] <= K_r3[0];
					mult_K[1] <= K_r3[1];
					mult_K[2] <= K_r3[2];
					mult_K[3] <= K_r3[3];
					mult_K[4] <= K_r3[4];
					mult_K[5] <= K_r3[5];
					mult_K[6] <= K_r3[6];
					mult_K[7] <= K_r3[7];
				end
				3: begin
					mult_K[0] <= K_r4[0];
					mult_K[1] <= K_r4[1];
					mult_K[2] <= K_r4[2];
					mult_K[3] <= K_r4[3];
					mult_K[4] <= K_r4[4];
					mult_K[5] <= K_r4[5];
					mult_K[6] <= K_r4[6];
					mult_K[7] <= K_r4[7];
				end
				4: begin
					mult_K[0] <= K_r5[0];
					mult_K[1] <= K_r5[1];
					mult_K[2] <= K_r5[2];
					mult_K[3] <= K_r5[3];
					mult_K[4] <= K_r5[4];
					mult_K[5] <= K_r5[5];
					mult_K[6] <= K_r5[6];
					mult_K[7] <= K_r5[7];
				end
				5: begin
					mult_K[0] <= K_r6[0];
					mult_K[1] <= K_r6[1];
					mult_K[2] <= K_r6[2];
					mult_K[3] <= K_r6[3];
					mult_K[4] <= K_r6[4];
					mult_K[5] <= K_r6[5];
					mult_K[6] <= K_r6[6];
					mult_K[7] <= K_r6[7];
				end
				6: begin
					mult_K[0] <= K_r7[0];
					mult_K[1] <= K_r7[1];
					mult_K[2] <= K_r7[2];
					mult_K[3] <= K_r7[3];
					mult_K[4] <= K_r7[4];
					mult_K[5] <= K_r7[5];
					mult_K[6] <= K_r7[6];
					mult_K[7] <= K_r7[7];
				end
				7: begin
					mult_K[0] <= K_r8[0];
					mult_K[1] <= K_r8[1];
					mult_K[2] <= K_r8[2];
					mult_K[3] <= K_r8[3];
					mult_K[4] <= K_r8[4];
					mult_K[5] <= K_r8[5];
					mult_K[6] <= K_r8[6];
					mult_K[7] <= K_r8[7];
				end
			endcase
		end
		else if (mul_wen_3_reg && T_reg == 4) begin
			case (count_QK_2)
				0: begin
					mult_K[0] <= K_r1[0];
					mult_K[1] <= K_r1[1];
					mult_K[2] <= K_r1[2];
					mult_K[3] <= K_r1[3];
					mult_K[4] <= K_r1[4];
					mult_K[5] <= K_r1[5];
					mult_K[6] <= K_r1[6];
					mult_K[7] <= K_r1[7];
				end
				1: begin
					mult_K[0] <= K_r2[0];
					mult_K[1] <= K_r2[1];
					mult_K[2] <= K_r2[2];
					mult_K[3] <= K_r2[3];
					mult_K[4] <= K_r2[4];
					mult_K[5] <= K_r2[5];
					mult_K[6] <= K_r2[6];
					mult_K[7] <= K_r2[7];
				end
				2: begin
					mult_K[0] <= K_r3[0];
					mult_K[1] <= K_r3[1];
					mult_K[2] <= K_r3[2];
					mult_K[3] <= K_r3[3];
					mult_K[4] <= K_r3[4];
					mult_K[5] <= K_r3[5];
					mult_K[6] <= K_r3[6];
					mult_K[7] <= K_r3[7];
				end
				3: begin
					mult_K[0] <= K_r4[0];
					mult_K[1] <= K_r4[1];
					mult_K[2] <= K_r4[2];
					mult_K[3] <= K_r4[3];
					mult_K[4] <= K_r4[4];
					mult_K[5] <= K_r4[5];
					mult_K[6] <= K_r4[6];
					mult_K[7] <= K_r4[7];
				end
				4: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				5: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				6: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				7: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
			endcase
		end
		else if (mul_wen_3_reg && T_reg == 1) begin
			case (count_QK_2)
				0: begin
					mult_K[0] <= K_r1[0];
					mult_K[1] <= K_r1[1];
					mult_K[2] <= K_r1[2];
					mult_K[3] <= K_r1[3];
					mult_K[4] <= K_r1[4];
					mult_K[5] <= K_r1[5];
					mult_K[6] <= K_r1[6];
					mult_K[7] <= K_r1[7];
				end
				1: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				2: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				3: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				4: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				5: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				6: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
				7: begin
					mult_K[0] <= 0;
					mult_K[1] <= 0;
					mult_K[2] <= 0;
					mult_K[3] <= 0;
					mult_K[4] <= 0;
					mult_K[5] <= 0;
					mult_K[6] <= 0;
					mult_K[7] <= 0;
				end
			endcase
		end
	end
	else begin
		for (i = 0; i < 8; i++) begin
			mult_K[i] <= mult_K[i];
		end
	end
end

reg signed [43:0] mult_QKT;
reg signed [43:0] mult_relu;

always @(*) begin
	mult_QKT = (mult_Q[0]*mult_K[0] + mult_Q[1]*mult_K[1] + mult_Q[2]*mult_K[2] + mult_Q[3]*mult_K[3] + mult_Q[4]*mult_K[4] + mult_Q[5]*mult_K[5] + mult_Q[6]*mult_K[6] + mult_Q[7]*mult_K[7])/3;
end

always @(*) begin
	mult_relu = (mult_QKT < 0)? 0:mult_QKT;
end

/////////////////////////////////////////
//////             S           //////////
/////////////////////////////////////////

//wire G_clock_S_r1;
//wire G_s_S_r1 = !(mul_wen_3_reg_scal && count_s[5:0] < 8);
//GATED_OR GATED_S_r1 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r1 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r1));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r1[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] < 8) begin
		case (count_s[5:0])
			0: S_r1[0] <= mult_relu;
			1: S_r1[1] <= mult_relu;
			2: S_r1[2] <= mult_relu;
			3: S_r1[3] <= mult_relu;
			4: S_r1[4] <= mult_relu;
			5: S_r1[5] <= mult_relu;
			6: S_r1[6] <= mult_relu;
			7: S_r1[7] <= mult_relu;
		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r1[i] <= S_r1[i];
		end
	end
end

//wire G_clock_S_r2;
//wire G_s_S_r2 = !(mul_wen_3_reg_scal && count_s[5:0] > 7 && count_s[5:0] < 16 );
//GATED_OR GATED_S_r2 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r2 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r2));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r2[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 7 && count_s[5:0] < 16 ) begin
		case (count_s[5:0])
			8: S_r2[0] <= mult_relu;
			9: S_r2[1] <= mult_relu;
			10: S_r2[2] <= mult_relu;
			11: S_r2[3] <= mult_relu;
			12: S_r2[4] <= mult_relu;
			13: S_r2[5] <= mult_relu;
			14: S_r2[6] <= mult_relu;
			15: S_r2[7] <= mult_relu;
		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r2[i] <= S_r2[i];
		end
	end
end

//wire G_clock_S_r3;
//wire G_s_S_r3 = !(mul_wen_3_reg_scal && count_s[5:0] > 15 && count_s[5:0] < 24 );
//GATED_OR GATED_S_r3 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r3 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r3));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r3[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 15 && count_s[5:0] < 24 ) begin
		case (count_s[5:0])
			16: S_r3[0] <= mult_relu;
			17: S_r3[1] <= mult_relu;
			18: S_r3[2] <= mult_relu;
			19: S_r3[3] <= mult_relu;
			20: S_r3[4] <= mult_relu;
			21: S_r3[5] <= mult_relu;
			22: S_r3[6] <= mult_relu;
			23: S_r3[7] <= mult_relu;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r3[i] <= S_r3[i];
		end
	end
end

//wire G_clock_S_r4;
//wire G_s_S_r4 = !(mul_wen_3_reg_scal && count_s[5:0] > 23 && count_s[5:0] < 32 );
//GATED_OR GATED_S_r4 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r4 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r4));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r4[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 23 && count_s[5:0] < 32) begin
		case (count_s[5:0])
			24: S_r4[0] <= mult_relu;
			25: S_r4[1] <= mult_relu;
			26: S_r4[2] <= mult_relu;
			27: S_r4[3] <= mult_relu;
			28: S_r4[4] <= mult_relu;
			29: S_r4[5] <= mult_relu;
			30: S_r4[6] <= mult_relu;
			31: S_r4[7] <= mult_relu;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r4[i] <= S_r4[i];
		end
	end
end

//wire G_clock_S_r5;
//wire G_s_S_r5 = !(mul_wen_3_reg_scal && count_s[5:0] > 31 && count_s[5:0] < 40 );
//GATED_OR GATED_S_r5 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r5 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r5));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r5[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 31 && count_s[5:0] < 40 ) begin
		case (count_s[5:0])
			32: S_r5[0] <= mult_relu;
			33: S_r5[1] <= mult_relu;
			34: S_r5[2] <= mult_relu;
			35: S_r5[3] <= mult_relu;
			36: S_r5[4] <= mult_relu;
			37: S_r5[5] <= mult_relu;
			38: S_r5[6] <= mult_relu;
			39: S_r5[7] <= mult_relu;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r5[i] <= S_r5[i];
		end
	end
end

//wire G_clock_S_r6;
//wire G_s_S_r6 = !(mul_wen_3_reg_scal && count_s[5:0] > 39 && count_s[5:0] < 48  );
//GATED_OR GATED_S_r6 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r6 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r6));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r6[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 39 && count_s[5:0] < 48 ) begin
		case (count_s[5:0])
			40: S_r6[0] <= mult_relu;
			41: S_r6[1] <= mult_relu;
			42: S_r6[2] <= mult_relu;
			43: S_r6[3] <= mult_relu;
			44: S_r6[4] <= mult_relu;
			45: S_r6[5] <= mult_relu;
			46: S_r6[6] <= mult_relu;
			47: S_r6[7] <= mult_relu;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r6[i] <= S_r6[i];
		end
	end
end

//wire G_clock_S_r7;
//wire G_s_S_r7 = !(mul_wen_3_reg_scal && count_s[5:0] > 47 && count_s[5:0] < 56  );
//GATED_OR GATED_S_r7 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r7 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r7));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r7[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 47 && count_s[5:0] < 56 ) begin
		case (count_s[5:0])
			48: S_r7[0] <= mult_relu;
			49: S_r7[1] <= mult_relu;
			50: S_r7[2] <= mult_relu;
			51: S_r7[3] <= mult_relu;
			52: S_r7[4] <= mult_relu;
			53: S_r7[5] <= mult_relu;
			54: S_r7[6] <= mult_relu;
			55: S_r7[7] <= mult_relu;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r7[i] <= S_r7[i];
		end
	end
end

//wire G_clock_S_r8;
//wire G_s_S_r8 = !(mul_wen_3_reg_scal && count_s[5:0] > 55 && count_s[5:0] < 64  );
//GATED_OR GATED_S_r8 (.CLOCK(clk), .SLEEP_CTRL(G_s_S_r8 && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_S_r8));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			S_r8[i] <= 0;
		end
	end
	else if (mul_wen_3_reg_scal && count_s[5:0] > 55 && count_s[5:0] < 64 ) begin
		case (count_s[5:0])
			56: S_r8[0] <= mult_relu;
			57: S_r8[1] <= mult_relu;
			58: S_r8[2] <= mult_relu;
			59: S_r8[3] <= mult_relu;
			60: S_r8[4] <= mult_relu;
			61: S_r8[5] <= mult_relu;
			62: S_r8[6] <= mult_relu;
			63: S_r8[7] <= mult_relu;

		endcase
	end
	else begin
		for (i = 0; i < 8; i++) begin
			S_r8[i] <= S_r8[i];
		end
	end
end


//wire G_clock_mult_P_S;
//wire G_s_mult_P_S = !(cs == OUT);
//GATED_OR GATED_mult_P_S (.CLOCK(clk), .SLEEP_CTRL(G_s_mult_P_S && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_mult_P_S));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			mult_P_S[i] <= 0;
		end
	end
	else if (cs == OUT && count_P_S[5:0] < 8 ) begin
		mult_P_S[0] <= S_r1[0];
		mult_P_S[1] <= S_r1[1];
		mult_P_S[2] <= S_r1[2];
		mult_P_S[3] <= S_r1[3];
		mult_P_S[4] <= S_r1[4];
		mult_P_S[5] <= S_r1[5];
		mult_P_S[6] <= S_r1[6];
		mult_P_S[7] <= S_r1[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 7 && count_P_S[5:0] < 16 ) begin
		mult_P_S[0] <= S_r2[0];
		mult_P_S[1] <= S_r2[1];
		mult_P_S[2] <= S_r2[2];
		mult_P_S[3] <= S_r2[3];
		mult_P_S[4] <= S_r2[4];
		mult_P_S[5] <= S_r2[5];
		mult_P_S[6] <= S_r2[6];
		mult_P_S[7] <= S_r2[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 15 && count_P_S[5:0] < 24  ) begin
		mult_P_S[0] <= S_r3[0];
		mult_P_S[1] <= S_r3[1];
		mult_P_S[2] <= S_r3[2];
		mult_P_S[3] <= S_r3[3];
		mult_P_S[4] <= S_r3[4];
		mult_P_S[5] <= S_r3[5];
		mult_P_S[6] <= S_r3[6];
		mult_P_S[7] <= S_r3[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 23 && count_P_S[5:0] < 32  ) begin
		mult_P_S[0] <= S_r4[0];
		mult_P_S[1] <= S_r4[1];
		mult_P_S[2] <= S_r4[2];
		mult_P_S[3] <= S_r4[3];
		mult_P_S[4] <= S_r4[4];
		mult_P_S[5] <= S_r4[5];
		mult_P_S[6] <= S_r4[6];
		mult_P_S[7] <= S_r4[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 31 && count_P_S[5:0] < 40 ) begin
		mult_P_S[0] <= S_r5[0];
		mult_P_S[1] <= S_r5[1];
		mult_P_S[2] <= S_r5[2];
		mult_P_S[3] <= S_r5[3];
		mult_P_S[4] <= S_r5[4];
		mult_P_S[5] <= S_r5[5];
		mult_P_S[6] <= S_r5[6];
		mult_P_S[7] <= S_r5[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 39 && count_P_S[5:0] < 48 ) begin
		mult_P_S[0] <= S_r6[0];
		mult_P_S[1] <= S_r6[1];
		mult_P_S[2] <= S_r6[2];
		mult_P_S[3] <= S_r6[3];
		mult_P_S[4] <= S_r6[4];
		mult_P_S[5] <= S_r6[5];
		mult_P_S[6] <= S_r6[6];
		mult_P_S[7] <= S_r6[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 47 && count_P_S[5:0] < 56  ) begin
		mult_P_S[0] <= S_r7[0];
		mult_P_S[1] <= S_r7[1];
		mult_P_S[2] <= S_r7[2];
		mult_P_S[3] <= S_r7[3];
		mult_P_S[4] <= S_r7[4];
		mult_P_S[5] <= S_r7[5];
		mult_P_S[6] <= S_r7[6];
		mult_P_S[7] <= S_r7[7];
	end
	else if (cs == OUT && count_P_S[5:0] > 55 && count_P_S[5:0] < 64 ) begin
		mult_P_S[0] <= S_r8[0];
		mult_P_S[1] <= S_r8[1];
		mult_P_S[2] <= S_r8[2];
		mult_P_S[3] <= S_r8[3];
		mult_P_S[4] <= S_r8[4];
		mult_P_S[5] <= S_r8[5];
		mult_P_S[6] <= S_r8[6];
		mult_P_S[7] <= S_r8[7];
	end
	else begin
		for (i = 0; i < 8; i++) begin
			mult_P_S[i] <= mult_P_S[i];
		end
	end
end

//wire G_clock_mult_P_V;
//wire G_s_mult_P_V = !(cs == OUT);
//GATED_OR GATED_mult_P_V (.CLOCK(clk), .SLEEP_CTRL(G_s_mult_P_V && cg_en), .RST_N(rst_n), .CLOCK_GATED(G_clock_mult_P_V));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		for (i = 0; i < 8; i++) begin
			mult_P_V[i] <= 0;
		end
	end
	else if (cs == OUT ) begin
		
			mult_P_V[0] <= V_r1[count_P_V];
			mult_P_V[1] <= V_r2[count_P_V];
			mult_P_V[2] <= V_r3[count_P_V];
			mult_P_V[3] <= V_r4[count_P_V];
			mult_P_V[4] <= V_r5[count_P_V];
			mult_P_V[5] <= V_r6[count_P_V];
			mult_P_V[6] <= V_r7[count_P_V];
			mult_P_V[7] <= V_r8[count_P_V];
		
	end
	else begin
		for (i = 0; i < 8; i++) begin
			mult_P_V[i] <= mult_P_V[i];
		end
	end
end

reg signed [63:0] mult_OUT;

always @(*) begin
	mult_OUT = mult_P_S[0]*mult_P_V[0] + mult_P_S[1]*mult_P_V[1] + mult_P_S[2]*mult_P_V[2] + mult_P_S[3]*mult_P_V[3] + mult_P_S[4]*mult_P_V[4] + mult_P_S[5]*mult_P_V[5] + mult_P_S[6]*mult_P_V[6] + mult_P_S[7]*mult_P_V[7];
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end 
	else if (out_val_reg) begin
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
	else if (out_val_reg) begin
		out_data <= mult_OUT;
	end
	else begin
        out_data <= 0;
    end
end



endmodule

