//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

parameter IDLE = 3'd0;
parameter IN = 3'd1;
parameter CAL = 3'd2;
parameter OUT = 3'd3;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [6:0] c_count, n_count;
reg [7:0] count;
reg [2:0] cs, ns;
reg next_opt_reg, current_opt_reg;

reg [31:0] img_reg_1 [0:4][0:4];
reg [31:0] img_reg_2 [0:4][0:4];

reg[31:0] sa_img [0:3];

reg[31:0] pe_reg [0:3];
reg[31:0] pe_reg_ch2 [0:3];

reg[31:0] pe_out [0:3];
reg[31:0] pe_out_ch2 [0:3];

reg[31:0] pe_out_seq [0:3];
reg[31:0] pe_out_seq_ch2 [0:3];


reg [31:0] conv_map1[0:5][0:5];
reg [31:0] conv_map2[0:5][0:5];

reg [31:0] pe1_par_in;
reg [31:0] pe1_par_in_ch2;

reg [31:0] img_seq;


reg [31:0] k1_1[0:1][0:1];
reg [31:0] k1_2[0:1][0:1];
reg [31:0] k1_3[0:1][0:1];
reg [31:0] k2_1[0:1][0:1];
reg [31:0] k2_2[0:1][0:1];
reg [31:0] k2_3[0:1][0:1];

reg [31:0] weight_reg[0:2][0:7];



reg[31:0] act_f;
reg[31:0] e_pos, e_neg;
reg [31:0] sigmoid_d, sigmoid;
reg [31:0] tanh_u, tanh_d, tanh;

reg [31:0] act_finish_reg;

localparam Padding_0 = 32'd0;


//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------


//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_count <= 7'd75;
    end else begin
        c_count <= n_count;
    end
end

always @(*) begin
    if(c_count == 75 && (!in_valid)) begin
        n_count = 7'd75;
    end
    else if (c_count == 75 && (in_valid)) begin
        n_count = 7'd0;
    end
    else begin
        n_count = c_count + 1;
    end
end



reg start_count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
    end
    else if (in_valid == 1) begin
        count <= count + 1;
    end
    else if (start_count == 1) begin
        count <= count + 1; //
    end
    else if (start_count == 0 && in_valid == 0) begin
        count <=0;
    end
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_count <= 0;
    end
    else if (in_valid == 1) begin
        start_count <= 1;  // 
    end
    else if (count == 127)  begin
        start_count <= 0;
    end

    /*
    else if (count == 121) begin
        start_count <=0;
    end
    */
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
                ns = IN;
            end
            else begin
                ns = cs;
            end
        end

        IN: begin
            if (c_count == 7'd75) begin
                ns = CAL;
            end
             else begin
                ns = cs;
            end
        end

        CAL: begin         
            if (c_count == 6'd3) begin
                ns =IDLE;
            end
             else begin
                ns = cs;
            end
        end

        OUT: begin
            if (c_count == 6'd3) begin
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
        img_seq <= 0;
    end
    else if (count == 8'd74) begin
        img_seq <= Img;
    end
    else if (count == 8'd75) begin
        img_seq <= img_seq;
    end
    else img_seq <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k1_1[0][0] <= 0;
        k1_1[0][1] <= 0;
        k1_1[1][0] <= 0;
        k1_1[1][1] <= 0;
    end
    else begin
        case (count)
            8'd0: k1_1[0][0] <= Kernel_ch1;
            8'd1: k1_1[0][1] <= Kernel_ch1;
            8'd2: k1_1[1][0] <= Kernel_ch1;
            8'd3: k1_1[1][1] <= Kernel_ch1;

            8'd36: k1_1[0][0] <= k1_2[0][0];
            8'd37: k1_1[0][1] <= k1_2[0][1];
            8'd38: k1_1[1][0] <= k1_2[1][0];
            8'd39: k1_1[1][1] <= k1_2[1][1];

            8'd72: k1_1[0][0] <= k1_3[0][0];
            8'd73: k1_1[0][1] <= k1_3[0][1];
            8'd74: k1_1[1][0] <= k1_3[1][0];
            8'd75: k1_1[1][1] <= k1_3[1][1];
            default: begin
                k1_1[0][0] <= k1_1[0][0];
                k1_1[0][1] <= k1_1[0][1];
                k1_1[1][0] <= k1_1[1][0];
                k1_1[1][1] <= k1_1[1][1];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k1_2[0][0] <= 0;
        k1_2[0][1] <= 0;
        k1_2[1][0] <= 0;
        k1_2[1][1] <= 0;
    end
    else begin
        case (count)
            8'd4: k1_2[0][0] <= Kernel_ch1;
            8'd5: k1_2[0][1] <= Kernel_ch1;
            8'd6: k1_2[1][0] <= Kernel_ch1;
            8'd7: k1_2[1][1] <= Kernel_ch1;
            default: begin
                k1_2[0][0] <= k1_2[0][0];
                k1_2[0][1] <= k1_2[0][1];
                k1_2[1][0] <= k1_2[1][0];
                k1_2[1][1] <= k1_2[1][1];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k1_3[0][0] <= 0;
        k1_3[0][1] <= 0;
        k1_3[1][0] <= 0;
        k1_3[1][1] <= 0;
    end
    else begin
        case (count)
            8'd8: k1_3[0][0] <= Kernel_ch1;
            8'd9: k1_3[0][1] <= Kernel_ch1;
            8'd10: k1_3[1][0] <= Kernel_ch1;
            8'd11: k1_3[1][1] <= Kernel_ch1;
            default: begin
                k1_3[0][0] <= k1_3[0][0];
                k1_3[0][1] <= k1_3[0][1];
                k1_3[1][0] <= k1_3[1][0];
                k1_3[1][1] <= k1_3[1][1];
            end
        endcase
    end
end




always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k2_1[0][0] <= 0;
        k2_1[0][1] <= 0;
        k2_1[1][0] <= 0;
        k2_1[1][1] <= 0;
    end
    else begin
        case (count)
            8'd0: k2_1[0][0] <= Kernel_ch2;
            8'd1: k2_1[0][1] <= Kernel_ch2;
            8'd2: k2_1[1][0] <= Kernel_ch2;
            8'd3: k2_1[1][1] <= Kernel_ch2;

            8'd36: k2_1[0][0] <= k2_2[0][0];
            8'd37: k2_1[0][1] <= k2_2[0][1];
            8'd38: k2_1[1][0] <= k2_2[1][0];
            8'd39: k2_1[1][1] <= k2_2[1][1];

            8'd72: k2_1[0][0] <= k2_3[0][0];
            8'd73: k2_1[0][1] <= k2_3[0][1];
            8'd74: k2_1[1][0] <= k2_3[1][0];
            8'd75: k2_1[1][1] <= k2_3[1][1];
            default: begin
                k2_1[0][0] <= k2_1[0][0];
                k2_1[0][1] <= k2_1[0][1];
                k2_1[1][0] <= k2_1[1][0];
                k2_1[1][1] <= k2_1[1][1];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k2_2[0][0] <= 0;
        k2_2[0][1] <= 0;
        k2_2[1][0] <= 0;
        k2_2[1][1] <= 0;
    end
    else begin
        case (count)
            8'd4: k2_2[0][0] <= Kernel_ch2;
            8'd5: k2_2[0][1] <= Kernel_ch2;
            8'd6: k2_2[1][0] <= Kernel_ch2;
            8'd7: k2_2[1][1] <= Kernel_ch2;
            default: begin
                k2_2[0][0] <= k2_2[0][0];
                k2_2[0][1] <= k2_2[0][1];
                k2_2[1][0] <= k2_2[1][0];
                k2_2[1][1] <= k2_2[1][1];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k2_3[0][0] <= 0;
        k2_3[0][1] <= 0;
        k2_3[1][0] <= 0;
        k2_3[1][1] <= 0;
    end
    else begin
        case (count)
            8'd8: k2_3[0][0] <= Kernel_ch2;
            8'd9: k2_3[0][1] <= Kernel_ch2;
            8'd10: k2_3[1][0] <= Kernel_ch2;
            8'd11: k2_3[1][1] <= Kernel_ch2;
            default: begin
                k2_3[0][0] <= k2_3[0][0];
                k2_3[0][1] <= k2_3[0][1];
                k2_3[1][0] <= k2_3[1][0];
                k2_3[1][1] <= k2_3[1][1];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_reg[0][0] <= 0;
        weight_reg[0][1] <= 0;
        weight_reg[0][2] <= 0;
        weight_reg[0][3] <= 0;
        weight_reg[0][4] <= 0;
        weight_reg[0][5] <= 0;
        weight_reg[0][6] <= 0;
        weight_reg[0][7] <= 0;
        weight_reg[1][0] <= 0;
        weight_reg[1][1] <= 0;
        weight_reg[1][2] <= 0;
        weight_reg[1][3] <= 0;
        weight_reg[1][4] <= 0;
        weight_reg[1][5] <= 0;
        weight_reg[1][6] <= 0;
        weight_reg[1][7] <= 0;
        weight_reg[2][0] <= 0;
        weight_reg[2][1] <= 0;
        weight_reg[2][2] <= 0;
        weight_reg[2][3] <= 0;
        weight_reg[2][4] <= 0;
        weight_reg[2][5] <= 0;
        weight_reg[2][6] <= 0;
        weight_reg[2][7] <= 0;
    end
    else begin
        case (count)
            8'd0: weight_reg[0][0] <= Weight;
            8'd1: weight_reg[0][1] <= Weight;
            8'd2: weight_reg[0][2] <= Weight;
            8'd3: weight_reg[0][3] <= Weight;
            8'd4: weight_reg[0][4] <= Weight;
            8'd5: weight_reg[0][5] <= Weight;
            8'd6: weight_reg[0][6] <= Weight;
            8'd7: weight_reg[0][7] <= Weight;

            8'd8: weight_reg[1][0] <= Weight;
            8'd9: weight_reg[1][1] <= Weight;
            8'd10: weight_reg[1][2] <= Weight;
            8'd11: weight_reg[1][3] <= Weight;            
            8'd12: weight_reg[1][4] <= Weight;
            8'd13: weight_reg[1][5] <= Weight;
            8'd14: weight_reg[1][6] <= Weight;
            8'd15: weight_reg[1][7] <= Weight;

            8'd16: weight_reg[2][0] <= Weight;
            8'd17: weight_reg[2][1] <= Weight;
            8'd18: weight_reg[2][2] <= Weight;
            8'd19: weight_reg[2][3] <= Weight;            
            8'd20: weight_reg[2][4] <= Weight;
            8'd21: weight_reg[2][5] <= Weight;
            8'd22: weight_reg[2][6] <= Weight;
            8'd23: weight_reg[2][7] <= Weight;


            default: begin
                weight_reg[0][0] <= weight_reg[0][0];
                weight_reg[0][1] <= weight_reg[0][1];
                weight_reg[0][2] <= weight_reg[0][2];
                weight_reg[0][3] <= weight_reg[0][3];
                weight_reg[0][4] <= weight_reg[0][4];
                weight_reg[0][5] <= weight_reg[0][5];
                weight_reg[0][6] <= weight_reg[0][6];
                weight_reg[0][7] <= weight_reg[0][7];
                weight_reg[1][0] <= weight_reg[1][0];
                weight_reg[1][1] <= weight_reg[1][1];
                weight_reg[1][2] <= weight_reg[1][2];
                weight_reg[1][3] <= weight_reg[1][3];
                weight_reg[1][4] <= weight_reg[1][4];
                weight_reg[1][5] <= weight_reg[1][5];
                weight_reg[1][6] <= weight_reg[1][6];
                weight_reg[1][7] <= weight_reg[1][7];
                weight_reg[2][0] <= weight_reg[2][0];
                weight_reg[2][1] <= weight_reg[2][1];
                weight_reg[2][2] <= weight_reg[2][2];
                weight_reg[2][3] <= weight_reg[2][3];
                weight_reg[2][4] <= weight_reg[2][4];
                weight_reg[2][5] <= weight_reg[2][5];
                weight_reg[2][6] <= weight_reg[2][6];
                weight_reg[2][7] <= weight_reg[2][7];
            end
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        img_reg_1[0][0] <= 0;
        img_reg_1[0][1] <= 0;
        img_reg_1[0][2] <= 0;
        img_reg_1[0][3] <= 0;
        img_reg_1[0][4] <= 0;
        img_reg_1[1][0] <= 0;
        img_reg_1[1][1] <= 0;
        img_reg_1[1][2] <= 0;
        img_reg_1[1][3] <= 0;
        img_reg_1[1][4] <= 0;
        img_reg_1[2][0] <= 0;
        img_reg_1[2][1] <= 0;
        img_reg_1[2][2] <= 0;
        img_reg_1[2][3] <= 0;
        img_reg_1[2][4] <= 0;
        img_reg_1[3][0] <= 0;
        img_reg_1[3][1] <= 0;
        img_reg_1[3][2] <= 0;
        img_reg_1[3][3] <= 0;
        img_reg_1[3][4] <= 0;
        img_reg_1[4][0] <= 0;
        img_reg_1[4][1] <= 0;
        img_reg_1[4][2] <= 0;
        img_reg_1[4][3] <= 0;
        img_reg_1[4][4] <= 0;

    end
    else if (in_valid == 1) begin
    case (count)
        8'd0, 8'd25, 8'd50: img_reg_1[0][0] <= Img;
        8'd1, 8'd26, 8'd51: img_reg_1[0][1] <= Img;
        8'd2, 8'd27, 8'd52: img_reg_1[0][2] <= Img;
        8'd3, 8'd28, 8'd53: img_reg_1[0][3] <= Img;
        8'd4, 8'd29, 8'd54: img_reg_1[0][4] <= Img;
        8'd5, 8'd30, 8'd55: img_reg_1[1][0] <= Img;
        8'd6, 8'd31, 8'd56: img_reg_1[1][1] <= Img;
        8'd7, 8'd32, 8'd57: img_reg_1[1][2] <= Img;
        8'd8, 8'd33, 8'd58: img_reg_1[1][3] <= Img;
        8'd9, 8'd34, 8'd59: img_reg_1[1][4] <= Img;
        8'd10, 8'd35, 8'd60: img_reg_1[2][0] <= Img;
        8'd11, 8'd36, 8'd61: img_reg_1[2][1] <= Img;
        8'd12, 8'd37, 8'd62: img_reg_1[2][2] <= Img;
        8'd13, 8'd38, 8'd63: img_reg_1[2][3] <= Img;
        8'd14, 8'd39, 8'd64: img_reg_1[2][4] <= Img;
        8'd15, 8'd40, 8'd65: img_reg_1[3][0] <= Img;
        8'd16, 8'd41, 8'd66: img_reg_1[3][1] <= Img;
        8'd17, 8'd42, 8'd67: img_reg_1[3][2] <= Img;
        8'd18, 8'd43, 8'd68: img_reg_1[3][3] <= Img;
        8'd19, 8'd44, 8'd69: img_reg_1[3][4] <= Img;
        8'd20, 8'd45, 8'd70: img_reg_1[4][0] <= Img;
        8'd21, 8'd46, 8'd71: img_reg_1[4][1] <= Img;
        8'd22, 8'd47, 8'd72: img_reg_1[4][2] <= Img;
        8'd23, 8'd48, 8'd73: img_reg_1[4][3] <= Img;
        8'd24, 8'd49:        img_reg_1[4][4] <= Img;

    endcase
    end
    else if  ( count == 8'd75 )   img_reg_1[4][4] <= img_seq;
end
////////////////////////////
//           pe_img         //
//////////////////////////////

always @(*) begin
    case(count)
        8'd1, 8'd37, 8'd73    : sa_img[0] = current_opt_reg ? img_reg_1[0][0] : Padding_0; //1
        8'd2, 8'd38, 8'd74    : sa_img[0] = current_opt_reg ? img_reg_1[0][0] : Padding_0; //2
        8'd3, 8'd39, 8'd75    : sa_img[0] = current_opt_reg ? img_reg_1[0][1] : Padding_0; //3
        8'd4, 8'd40, 8'd76    : sa_img[0] = current_opt_reg ? img_reg_1[0][2] : Padding_0;
        8'd5, 8'd41, 8'd77    : sa_img[0] = current_opt_reg ? img_reg_1[0][3] : Padding_0;
        8'd6, 8'd42, 8'd78    : sa_img[0] = current_opt_reg ? img_reg_1[0][4] : Padding_0;

        8'd7, 8'd43, 8'd79    : sa_img[0] = current_opt_reg ? img_reg_1[0][0] : Padding_0;
        8'd8, 8'd44, 8'd80    : sa_img[0] =                   img_reg_1[0][0] ;
        8'd9, 8'd45, 8'd81    : sa_img[0] =                   img_reg_1[0][1] ;
        8'd10, 8'd46, 8'd82   : sa_img[0] =                   img_reg_1[0][2] ;
        8'd11, 8'd47, 8'd83   : sa_img[0] =                   img_reg_1[0][3] ;
        8'd12, 8'd48, 8'd84   : sa_img[0] =                   img_reg_1[0][4] ;

        8'd13, 8'd49, 8'd85   : sa_img[0] = current_opt_reg ? img_reg_1[1][0] : Padding_0;
        8'd14, 8'd50, 8'd86   : sa_img[0] =                   img_reg_1[1][0] ;
        8'd15, 8'd51, 8'd87   : sa_img[0] =                   img_reg_1[1][1] ;
        8'd16, 8'd52, 8'd88   : sa_img[0] =                   img_reg_1[1][2] ;
        8'd17, 8'd53, 8'd89   : sa_img[0] =                   img_reg_1[1][3] ;
        8'd18, 8'd54, 8'd90   : sa_img[0] =                   img_reg_1[1][4] ;

        8'd19, 8'd55, 8'd91   : sa_img[0] = current_opt_reg ? img_reg_1[2][0] : Padding_0;
        8'd20, 8'd56, 8'd92   : sa_img[0] =                   img_reg_1[2][0] ;
        8'd21, 8'd57, 8'd93   : sa_img[0] =                   img_reg_1[2][1] ;
        8'd22, 8'd58, 8'd94   : sa_img[0] =                   img_reg_1[2][2] ;
        8'd23, 8'd59, 8'd95   : sa_img[0] =                   img_reg_1[2][3] ;
        8'd24, 8'd60, 8'd96   : sa_img[0] =                   img_reg_1[2][4] ;

        8'd25, 8'd61, 8'd97   : sa_img[0] = current_opt_reg ? img_reg_1[3][0] : Padding_0;
        8'd26, 8'd62, 8'd98   : sa_img[0] =                   img_reg_1[3][0] ;
        8'd27, 8'd63, 8'd99   : sa_img[0] =                   img_reg_1[3][1] ;
        8'd28, 8'd64, 8'd100  : sa_img[0] =                   img_reg_1[3][2] ;
        8'd29, 8'd65, 8'd101  : sa_img[0] =                   img_reg_1[3][3] ;
        8'd30, 8'd66, 8'd102  : sa_img[0] =                   img_reg_1[3][4] ;

        8'd31, 8'd67, 8'd103  : sa_img[0] = current_opt_reg ? img_reg_1[4][0] : Padding_0;
        8'd32, 8'd68, 8'd104  : sa_img[0] =                   img_reg_1[4][0] ;
        8'd33, 8'd69, 8'd105  : sa_img[0] =                   img_reg_1[4][1] ;
        8'd34, 8'd70, 8'd106  : sa_img[0] =                   img_reg_1[4][2] ;
        8'd35, 8'd71, 8'd107  : sa_img[0] =                   img_reg_1[4][3] ;
        8'd36, 8'd72, 8'd108  : sa_img[0] =                   img_reg_1[4][4] ;

        default : sa_img[0] = 0 ;
    endcase
end

always @(*) begin
    case(count)

        8'd2, 8'd38, 8'd74    : sa_img[1] = current_opt_reg ? img_reg_1[0][0] : Padding_0; //2
        8'd3, 8'd39, 8'd75    : sa_img[1] = current_opt_reg ? img_reg_1[0][1] : Padding_0; //3
        8'd4, 8'd40, 8'd76    : sa_img[1] = current_opt_reg ? img_reg_1[0][2] : Padding_0;
        8'd5, 8'd41, 8'd77    : sa_img[1] = current_opt_reg ? img_reg_1[0][3] : Padding_0;
        8'd6, 8'd42, 8'd78    : sa_img[1] = current_opt_reg ? img_reg_1[0][4] : Padding_0;

        8'd7, 8'd43, 8'd79    : sa_img[1] = current_opt_reg ? img_reg_1[0][4] : Padding_0;
        8'd8, 8'd44, 8'd80    : sa_img[1] =                   img_reg_1[0][0] ;
        8'd9, 8'd45, 8'd81    : sa_img[1] =                   img_reg_1[0][1] ;
        8'd10, 8'd46, 8'd82   : sa_img[1] =                   img_reg_1[0][2] ;
        8'd11, 8'd47, 8'd83   : sa_img[1] =                   img_reg_1[0][3] ;
        8'd12, 8'd48, 8'd84   : sa_img[1] =                   img_reg_1[0][4] ;

        8'd13, 8'd49, 8'd85   : sa_img[1] = current_opt_reg ? img_reg_1[0][4] : Padding_0;
        8'd14, 8'd50, 8'd86   : sa_img[1] =                   img_reg_1[1][0] ;
        8'd15, 8'd51, 8'd87   : sa_img[1] =                   img_reg_1[1][1] ;
        8'd16, 8'd52, 8'd88   : sa_img[1] =                   img_reg_1[1][2] ;
        8'd17, 8'd53, 8'd89   : sa_img[1] =                   img_reg_1[1][3] ;
        8'd18, 8'd54, 8'd90   : sa_img[1] =                   img_reg_1[1][4] ;

        8'd19, 8'd55, 8'd91   : sa_img[1] = current_opt_reg ? img_reg_1[1][4] : Padding_0;
        8'd20, 8'd56, 8'd92   : sa_img[1] =                   img_reg_1[2][0] ;
        8'd21, 8'd57, 8'd93   : sa_img[1] =                   img_reg_1[2][1] ;
        8'd22, 8'd58, 8'd94   : sa_img[1] =                   img_reg_1[2][2] ;
        8'd23, 8'd59, 8'd95   : sa_img[1] =                   img_reg_1[2][3] ;
        8'd24, 8'd60, 8'd96   : sa_img[1] =                   img_reg_1[2][4] ;

        8'd25, 8'd61, 8'd97   : sa_img[1] = current_opt_reg ? img_reg_1[2][4] : Padding_0;
        8'd26, 8'd62, 8'd98   : sa_img[1] =                   img_reg_1[3][0] ;
        8'd27, 8'd63, 8'd99   : sa_img[1] =                   img_reg_1[3][1] ;
        8'd28, 8'd64, 8'd100  : sa_img[1] =                   img_reg_1[3][2] ;
        8'd29, 8'd65, 8'd101  : sa_img[1] =                   img_reg_1[3][3] ;
        8'd30, 8'd66, 8'd102  : sa_img[1] =                   img_reg_1[3][4] ;

        8'd31, 8'd67, 8'd103  : sa_img[1] = current_opt_reg ? img_reg_1[3][4] : Padding_0;
        8'd32, 8'd68, 8'd104  : sa_img[1] =                   img_reg_1[4][0] ;
        8'd33, 8'd69, 8'd105  : sa_img[1] =                   img_reg_1[4][1] ;
        8'd34, 8'd70, 8'd106  : sa_img[1] =                   img_reg_1[4][2] ;
        8'd35, 8'd71, 8'd107  : sa_img[1] =                   img_reg_1[4][3] ;
        8'd36, 8'd72, 8'd108  : sa_img[1] =                   img_reg_1[4][4] ;
        8'd37, 8'd73, 8'd109  : sa_img[1] = current_opt_reg ? img_reg_1[4][4] : Padding_0;
        default : sa_img[1] = 0 ;
    endcase
end

always @(*) begin
    case(count)

        8'd3,  8'd39,  8'd75    : sa_img[2] = current_opt_reg ? img_reg_1[0][0] : Padding_0; //3
        8'd4,  8'd40,  8'd76    : sa_img[2] =                   img_reg_1[0][0] ;
        8'd5,  8'd41,  8'd77    : sa_img[2] =                   img_reg_1[0][1] ;
        8'd6,  8'd42,  8'd78    : sa_img[2] =                   img_reg_1[0][2] ;
        8'd7,  8'd43,  8'd79    : sa_img[2] =                   img_reg_1[0][3] ;
        8'd8,  8'd44,  8'd80    : sa_img[2] =                   img_reg_1[0][4] ;

        8'd9,  8'd45,  8'd81    : sa_img[2] = current_opt_reg ? img_reg_1[1][0] : Padding_0; //3
        8'd10, 8'd46,  8'd82    : sa_img[2] =                   img_reg_1[1][0] ;
        8'd11, 8'd47,  8'd83    : sa_img[2] =                   img_reg_1[1][1] ;
        8'd12, 8'd48,  8'd84    : sa_img[2] =                   img_reg_1[1][2] ;
        8'd13, 8'd49,  8'd85    : sa_img[2] =                   img_reg_1[1][3] ;
        8'd14, 8'd50,  8'd86    : sa_img[2] =                   img_reg_1[1][4] ;

        8'd15, 8'd51,  8'd87    : sa_img[2] = current_opt_reg ? img_reg_1[2][0] : Padding_0;
        8'd16, 8'd52,  8'd88    : sa_img[2] =                   img_reg_1[2][0] ;
        8'd17, 8'd53,  8'd89    : sa_img[2] =                   img_reg_1[2][1] ;
        8'd18, 8'd54,  8'd90    : sa_img[2] =                   img_reg_1[2][2] ;
        8'd19, 8'd55,  8'd91    : sa_img[2] =                   img_reg_1[2][3] ;
        8'd20, 8'd56,  8'd92    : sa_img[2] =                   img_reg_1[2][4] ;

        8'd21, 8'd57,  8'd93    : sa_img[2] = current_opt_reg ? img_reg_1[3][0] : Padding_0;
        8'd22, 8'd58,  8'd94    : sa_img[2] =                   img_reg_1[3][0] ;
        8'd23, 8'd59,  8'd95    : sa_img[2] =                   img_reg_1[3][1] ;
        8'd24, 8'd60,  8'd96    : sa_img[2] =                   img_reg_1[3][2] ;
        8'd25, 8'd61,  8'd97    : sa_img[2] =                   img_reg_1[3][3] ;
        8'd26, 8'd62,  8'd98    : sa_img[2] =                   img_reg_1[3][4] ;

        8'd27, 8'd63,  8'd99    : sa_img[2] = current_opt_reg ? img_reg_1[4][0] : Padding_0;
        8'd28, 8'd64,  8'd100   : sa_img[2] =                   img_reg_1[4][0] ;
        8'd29, 8'd65,  8'd101   : sa_img[2] =                   img_reg_1[4][1] ;
        8'd30, 8'd66,  8'd102   : sa_img[2] =                   img_reg_1[4][2] ;
        8'd31, 8'd67,  8'd103   : sa_img[2] =                   img_reg_1[4][3] ;
        8'd32, 8'd68,  8'd104   : sa_img[2] =                   img_reg_1[4][4] ;

        8'd33, 8'd69,  8'd105   : sa_img[2] = current_opt_reg ? img_reg_1[4][0] : Padding_0;
        8'd34, 8'd70,  8'd106   : sa_img[2] = current_opt_reg ? img_reg_1[4][0] : Padding_0;
        8'd35, 8'd71,  8'd107   : sa_img[2] = current_opt_reg ? img_reg_1[4][1] : Padding_0;
        8'd36, 8'd72,  8'd108   : sa_img[2] = current_opt_reg ? img_reg_1[4][2] : Padding_0;
        8'd37, 8'd73,  8'd109   : sa_img[2] = current_opt_reg ? img_reg_1[4][3] : Padding_0;
        8'd38, 8'd74,  8'd110   : sa_img[2] = current_opt_reg ? img_reg_1[4][4] : Padding_0;


        default : sa_img[2] = 0 ;
    endcase
end

always @(*) begin
    case(count)


        8'd4,  8'd40,  8'd76    : sa_img[3] =                   img_reg_1[0][0] ;
        8'd5,  8'd41,  8'd77    : sa_img[3] =                   img_reg_1[0][1] ;
        8'd6,  8'd42,  8'd78    : sa_img[3] =                   img_reg_1[0][2] ;
        8'd7,  8'd43,  8'd79    : sa_img[3] =                   img_reg_1[0][3] ;
        8'd8,  8'd44,  8'd80    : sa_img[3] =                   img_reg_1[0][4] ;
        8'd9,  8'd45,  8'd81    : sa_img[3] = current_opt_reg ? img_reg_1[0][4] : Padding_0; //3

        8'd10, 8'd46,  8'd82    : sa_img[3] =                   img_reg_1[1][0] ;
        8'd11, 8'd47,  8'd83    : sa_img[3] =                   img_reg_1[1][1] ;
        8'd12, 8'd48,  8'd84    : sa_img[3] =                   img_reg_1[1][2] ;
        8'd13, 8'd49,  8'd85    : sa_img[3] =                   img_reg_1[1][3] ;
        8'd14, 8'd50,  8'd86    : sa_img[3] =                   img_reg_1[1][4] ;
        8'd15, 8'd51,  8'd87    : sa_img[3] = current_opt_reg ? img_reg_1[1][4] : Padding_0;

        8'd16, 8'd52,  8'd88    : sa_img[3] =                   img_reg_1[2][0] ;
        8'd17, 8'd53,  8'd89    : sa_img[3] =                   img_reg_1[2][1] ;
        8'd18, 8'd54,  8'd90    : sa_img[3] =                   img_reg_1[2][2] ;
        8'd19, 8'd55,  8'd91    : sa_img[3] =                   img_reg_1[2][3] ;
        8'd20, 8'd56,  8'd92    : sa_img[3] =                   img_reg_1[2][4] ;
        8'd21, 8'd57,  8'd93    : sa_img[3] = current_opt_reg ? img_reg_1[2][4] : Padding_0;

        8'd22, 8'd58,  8'd94    : sa_img[3] =                   img_reg_1[3][0] ;
        8'd23, 8'd59,  8'd95    : sa_img[3] =                   img_reg_1[3][1] ;
        8'd24, 8'd60,  8'd96    : sa_img[3] =                   img_reg_1[3][2] ;
        8'd25, 8'd61,  8'd97    : sa_img[3] =                   img_reg_1[3][3] ;
        8'd26, 8'd62,  8'd98    : sa_img[3] =                   img_reg_1[3][4] ;
        8'd27, 8'd63,  8'd99    : sa_img[3] = current_opt_reg ? img_reg_1[3][4] : Padding_0;

        8'd28, 8'd64,  8'd100   : sa_img[3] =                   img_reg_1[4][0] ;
        8'd29, 8'd65,  8'd101   : sa_img[3] =                   img_reg_1[4][1] ;
        8'd30, 8'd66,  8'd102   : sa_img[3] =                   img_reg_1[4][2] ;
        8'd31, 8'd67,  8'd103   : sa_img[3] =                   img_reg_1[4][3] ;
        8'd32, 8'd68,  8'd104   : sa_img[3] =                   img_reg_1[4][4] ;
        8'd33, 8'd69,  8'd105   : sa_img[3] = current_opt_reg ? img_reg_1[4][4] : Padding_0;

        8'd34, 8'd70,  8'd106   : sa_img[3] = current_opt_reg ? img_reg_1[4][0] : Padding_0;
        8'd35, 8'd71,  8'd107   : sa_img[3] = current_opt_reg ? img_reg_1[4][1] : Padding_0;
        8'd36, 8'd72,  8'd108   : sa_img[3] = current_opt_reg ? img_reg_1[4][2] : Padding_0;
        8'd37, 8'd73,  8'd109   : sa_img[3] = current_opt_reg ? img_reg_1[4][3] : Padding_0;
        8'd38, 8'd74,  8'd110   : sa_img[3] = current_opt_reg ? img_reg_1[4][4] : Padding_0;
        8'd39, 8'd75,  8'd111   : sa_img[3] = current_opt_reg ? img_reg_1[4][4] : Padding_0;


        default : sa_img[3] = 0 ;
    endcase
end

/////////////////////////
//     convalution //
////////////////////////


always @(posedge clk ) begin
    case (count)
        8'd36, 8'd72: pe1_par_in <= conv_map1[0][0];
        8'd37, 8'd73: pe1_par_in <= conv_map1[0][1];
        8'd38, 8'd74: pe1_par_in <= conv_map1[0][2];
        8'd39, 8'd75: pe1_par_in <= conv_map1[0][3];
        8'd40, 8'd76: pe1_par_in <= conv_map1[0][4];
        8'd41, 8'd77: pe1_par_in <= conv_map1[0][5];

        8'd42, 8'd78: pe1_par_in <= conv_map1[1][0];
        8'd43, 8'd79: pe1_par_in <= conv_map1[1][1];
        8'd44, 8'd80: pe1_par_in <= conv_map1[1][2];
        8'd45, 8'd81: pe1_par_in <= conv_map1[1][3];
        8'd46, 8'd82: pe1_par_in <= conv_map1[1][4];
        8'd47, 8'd83: pe1_par_in <= conv_map1[1][5];

        8'd48, 8'd84: pe1_par_in <= conv_map1[2][0];
        8'd49, 8'd85: pe1_par_in <= conv_map1[2][1];
        8'd50, 8'd86: pe1_par_in <= conv_map1[2][2];
        8'd51, 8'd87: pe1_par_in <= conv_map1[2][3];
        8'd52, 8'd88: pe1_par_in <= conv_map1[2][4];
        8'd53, 8'd89: pe1_par_in <= conv_map1[2][5];

        8'd54, 8'd90: pe1_par_in <= conv_map1[3][0];
        8'd55, 8'd91: pe1_par_in <= conv_map1[3][1];
        8'd56, 8'd92: pe1_par_in <= conv_map1[3][2];
        8'd57, 8'd93: pe1_par_in <= conv_map1[3][3];
        8'd58, 8'd94: pe1_par_in <= conv_map1[3][4];
        8'd59, 8'd95: pe1_par_in <= conv_map1[3][5];

        8'd60, 8'd96: pe1_par_in <= conv_map1[4][0];
        8'd61, 8'd97: pe1_par_in <= conv_map1[4][1];
        8'd62, 8'd98: pe1_par_in <= conv_map1[4][2];
        8'd63, 8'd99: pe1_par_in <= conv_map1[4][3];
        8'd64, 8'd100: pe1_par_in <= conv_map1[4][4];
        8'd65, 8'd101: pe1_par_in <= conv_map1[4][5];

        8'd66, 8'd102: pe1_par_in <= conv_map1[5][0];
        8'd67, 8'd103: pe1_par_in <= conv_map1[5][1];
        8'd68, 8'd104: pe1_par_in <= conv_map1[5][2];
        8'd69, 8'd105: pe1_par_in <= conv_map1[5][3];
        8'd70, 8'd106: pe1_par_in <= conv_map1[5][4];
        8'd71, 8'd107: pe1_par_in <= conv_map1[5][5];
        default: pe1_par_in <= 0;
    endcase
end


DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe0_mult ( .a(sa_img[0]), .b(k1_1[0][0]), .rnd(3'b000), .z(pe_reg[0]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe0_add ( .a(pe_reg[0]), .b(pe1_par_in), .rnd(3'b000), .z(pe_out[0]), .status() );

always @(posedge clk ) begin
    pe_out_seq[0] <= pe_out[0];
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe1_mult ( .a(sa_img[1]), .b(k1_1[0][1]), .rnd(3'b000), .z(pe_reg[1]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe1_add ( .a(pe_reg[1]), .b(pe_out_seq[0]), .rnd(3'b000), .z(pe_out[1]), .status() );

always @(posedge clk ) begin
    pe_out_seq[1] <= pe_out[1];
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe2_mult ( .a(sa_img[2]), .b(k1_1[1][0]), .rnd(3'b000), .z(pe_reg[2]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe2_add ( .a(pe_reg[2]), .b(pe_out_seq[1]), .rnd(3'b000), .z(pe_out[2]), .status() );

always @(posedge clk ) begin
    pe_out_seq[2] <= pe_out[2];
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe3_mult ( .a(sa_img[3]), .b(k1_1[1][1]), .rnd(3'b000), .z(pe_reg[3]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe3_add ( .a(pe_reg[3]), .b(pe_out_seq[2]), .rnd(3'b000), .z(pe_out[3]), .status() );

always @(posedge clk ) begin
    pe_out_seq[3] <= pe_out[3];
end

always @(posedge clk ) begin

    case (count)
        8'd0: begin 
            conv_map1[0][0] <= 0;
            conv_map1[0][1] <= 0;
            conv_map1[0][2] <= 0;
            conv_map1[0][3] <= 0;
            conv_map1[0][4] <= 0;
            conv_map1[0][5] <= 0;
            conv_map1[1][0] <= 0;
            conv_map1[1][1] <= 0;
            conv_map1[1][2] <= 0;
            conv_map1[1][3] <= 0;
            conv_map1[1][4] <= 0;
            conv_map1[1][5] <= 0;
            conv_map1[2][0] <= 0;
            conv_map1[2][1] <= 0;
            conv_map1[2][2] <= 0;
            conv_map1[2][3] <= 0;
            conv_map1[2][4] <= 0;
            conv_map1[2][5] <= 0;
            conv_map1[3][0] <= 0;
            conv_map1[3][1] <= 0;
            conv_map1[3][2] <= 0;
            conv_map1[3][3] <= 0;
            conv_map1[3][4] <= 0;
            conv_map1[3][5] <= 0;
            conv_map1[4][0] <= 0;
            conv_map1[4][1] <= 0;
            conv_map1[4][2] <= 0;
            conv_map1[4][3] <= 0;
            conv_map1[4][4] <= 0;
            conv_map1[4][5] <= 0;
            conv_map1[5][0] <= 0;
            conv_map1[5][1] <= 0;
            conv_map1[5][2] <= 0;
            conv_map1[5][3] <= 0;
            conv_map1[5][4] <= 0;
            conv_map1[5][5] <= 0;
        end
        8'd4,  8'd40, 8'd76:  conv_map1[0][0] <=  pe_out[3];
        8'd5,  8'd41, 8'd77:  conv_map1[0][1] <=  pe_out[3];
        8'd6,  8'd42, 8'd78:  conv_map1[0][2] <=  pe_out[3];
        8'd7,  8'd43, 8'd79:  conv_map1[0][3] <=  pe_out[3];
        8'd8,  8'd44, 8'd80:  conv_map1[0][4] <=  pe_out[3];
        8'd9,  8'd45, 8'd81:  conv_map1[0][5] <=  pe_out[3];

        8'd10, 8'd46, 8'd82:  conv_map1[1][0] <=  pe_out[3];
        8'd11, 8'd47, 8'd83:  conv_map1[1][1] <=  pe_out[3];
        8'd12, 8'd48, 8'd84:  conv_map1[1][2] <=  pe_out[3];
        8'd13, 8'd49, 8'd85:  conv_map1[1][3] <=  pe_out[3];
        8'd14, 8'd50, 8'd86:  conv_map1[1][4] <=  pe_out[3];
        8'd15, 8'd51, 8'd87:  conv_map1[1][5] <=  pe_out[3];

        8'd16, 8'd52, 8'd88:  conv_map1[2][0] <=  pe_out[3];
        8'd17, 8'd53, 8'd89:  conv_map1[2][1] <=  pe_out[3];
        8'd18, 8'd54, 8'd90:  conv_map1[2][2] <=  pe_out[3];
        8'd19, 8'd55, 8'd91:  conv_map1[2][3] <=  pe_out[3];
        8'd20, 8'd56, 8'd92:  conv_map1[2][4] <=  pe_out[3];
        8'd21, 8'd57, 8'd93:  conv_map1[2][5] <=  pe_out[3];

        8'd22, 8'd58, 8'd94:  conv_map1[3][0] <=  pe_out[3];
        8'd23, 8'd59, 8'd95:  conv_map1[3][1] <=  pe_out[3];
        8'd24, 8'd60, 8'd96:  conv_map1[3][2] <=  pe_out[3];
        8'd25, 8'd61, 8'd97:  conv_map1[3][3] <=  pe_out[3];
        8'd26, 8'd62, 8'd98:  conv_map1[3][4] <=  pe_out[3];
        8'd27, 8'd63, 8'd99:  conv_map1[3][5] <=  pe_out[3];

        8'd28, 8'd64, 8'd100: conv_map1[4][0] <=  pe_out[3];
        8'd29, 8'd65, 8'd101: conv_map1[4][1] <=  pe_out[3];
        8'd30, 8'd66, 8'd102: conv_map1[4][2] <=  pe_out[3];
        8'd31, 8'd67, 8'd103: conv_map1[4][3] <=  pe_out[3];
        8'd32, 8'd68, 8'd104: conv_map1[4][4] <=  pe_out[3];
        8'd33, 8'd69, 8'd105: conv_map1[4][5] <=  pe_out[3];

        8'd34, 8'd70, 8'd106: conv_map1[5][0] <=  pe_out[3];
        8'd35, 8'd71, 8'd107: conv_map1[5][1] <=  pe_out[3];
        8'd36, 8'd72, 8'd108: conv_map1[5][2] <=  pe_out[3];
        8'd37, 8'd73, 8'd109: conv_map1[5][3] <=  pe_out[3];
        8'd38, 8'd74, 8'd110: conv_map1[5][4] <=  pe_out[3];
        8'd39, 8'd75, 8'd111: conv_map1[5][5] <=  pe_out[3];


    endcase
end



/////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk ) begin
    case (count)
        8'd36, 8'd72: pe1_par_in_ch2 <= conv_map2[0][0];
        8'd37, 8'd73: pe1_par_in_ch2 <= conv_map2[0][1];
        8'd38, 8'd74: pe1_par_in_ch2 <= conv_map2[0][2];
        8'd39, 8'd75: pe1_par_in_ch2 <= conv_map2[0][3];
        8'd40, 8'd76: pe1_par_in_ch2 <= conv_map2[0][4];
        8'd41, 8'd77: pe1_par_in_ch2 <= conv_map2[0][5];

        8'd42, 8'd78: pe1_par_in_ch2 <= conv_map2[1][0];
        8'd43, 8'd79: pe1_par_in_ch2 <= conv_map2[1][1];
        8'd44, 8'd80: pe1_par_in_ch2 <= conv_map2[1][2];
        8'd45, 8'd81: pe1_par_in_ch2 <= conv_map2[1][3];
        8'd46, 8'd82: pe1_par_in_ch2 <= conv_map2[1][4];
        8'd47, 8'd83: pe1_par_in_ch2 <= conv_map2[1][5];

        8'd48, 8'd84: pe1_par_in_ch2 <= conv_map2[2][0];
        8'd49, 8'd85: pe1_par_in_ch2 <= conv_map2[2][1];
        8'd50, 8'd86: pe1_par_in_ch2 <= conv_map2[2][2];
        8'd51, 8'd87: pe1_par_in_ch2 <= conv_map2[2][3];
        8'd52, 8'd88: pe1_par_in_ch2 <= conv_map2[2][4];
        8'd53, 8'd89: pe1_par_in_ch2 <= conv_map2[2][5];

        8'd54, 8'd90: pe1_par_in_ch2 <= conv_map2[3][0];
        8'd55, 8'd91: pe1_par_in_ch2 <= conv_map2[3][1];
        8'd56, 8'd92: pe1_par_in_ch2 <= conv_map2[3][2];
        8'd57, 8'd93: pe1_par_in_ch2 <= conv_map2[3][3];
        8'd58, 8'd94: pe1_par_in_ch2 <= conv_map2[3][4];
        8'd59, 8'd95: pe1_par_in_ch2 <= conv_map2[3][5];

        8'd60, 8'd96: pe1_par_in_ch2 <= conv_map2[4][0];
        8'd61, 8'd97: pe1_par_in_ch2 <= conv_map2[4][1];
        8'd62, 8'd98: pe1_par_in_ch2 <= conv_map2[4][2];
        8'd63, 8'd99: pe1_par_in_ch2 <= conv_map2[4][3];
        8'd64, 8'd100: pe1_par_in_ch2 <= conv_map2[4][4];
        8'd65, 8'd101: pe1_par_in_ch2 <= conv_map2[4][5];

        8'd66, 8'd102: pe1_par_in_ch2 <= conv_map2[5][0];
        8'd67, 8'd103: pe1_par_in_ch2 <= conv_map2[5][1];
        8'd68, 8'd104: pe1_par_in_ch2 <= conv_map2[5][2];
        8'd69, 8'd105: pe1_par_in_ch2 <= conv_map2[5][3];
        8'd70, 8'd106: pe1_par_in_ch2 <= conv_map2[5][4];
        8'd71, 8'd107: pe1_par_in_ch2 <= conv_map2[5][5];
        default: pe1_par_in_ch2 <= 0;
    endcase
end


DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe4_mult ( .a(sa_img[0]), .b(k2_1[0][0]), .rnd(3'b000), .z(pe_reg_ch2[0]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe4_add ( .a(pe_reg_ch2[0]), .b(pe1_par_in_ch2), .rnd(3'b000), .z(pe_out_ch2[0]), .status() );

always @(posedge clk ) begin
    pe_out_seq_ch2[0] <= pe_out_ch2[0];
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe5_mult ( .a(sa_img[1]), .b(k2_1[0][1]), .rnd(3'b000), .z(pe_reg_ch2[1]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe5_add ( .a(pe_reg_ch2[1]), .b(pe_out_seq_ch2[0]), .rnd(3'b000), .z(pe_out_ch2[1]), .status() );

always @(posedge clk ) begin
    pe_out_seq_ch2[1] <= pe_out_ch2[1];
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe6_mult ( .a(sa_img[2]), .b(k2_1[1][0]), .rnd(3'b000), .z(pe_reg_ch2[2]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe6_add ( .a(pe_reg_ch2[2]), .b(pe_out_seq_ch2[1]), .rnd(3'b000), .z(pe_out_ch2[2]), .status() );

always @(posedge clk ) begin
    pe_out_seq_ch2[2] <= pe_out_ch2[2];
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe7_mult ( .a(sa_img[3]), .b(k2_1[1][1]), .rnd(3'b000), .z(pe_reg_ch2[3]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    pe7_add ( .a(pe_reg_ch2[3]), .b(pe_out_seq_ch2[2]), .rnd(3'b000), .z(pe_out_ch2[3]), .status() );

always @(posedge clk ) begin
    pe_out_seq_ch2[3] <= pe_out_ch2[3];
end

always @(posedge clk ) begin

    case (count)
        8'd0: begin 
            conv_map2[0][0] <= 0;
            conv_map2[0][1] <= 0;
            conv_map2[0][2] <= 0;
            conv_map2[0][3] <= 0;
            conv_map2[0][4] <= 0;
            conv_map2[0][5] <= 0;
            conv_map2[1][0] <= 0;
            conv_map2[1][1] <= 0;
            conv_map2[1][2] <= 0;
            conv_map2[1][3] <= 0;
            conv_map2[1][4] <= 0;
            conv_map2[1][5] <= 0;
            conv_map2[2][0] <= 0;
            conv_map2[2][1] <= 0;
            conv_map2[2][2] <= 0;
            conv_map2[2][3] <= 0;
            conv_map2[2][4] <= 0;
            conv_map2[2][5] <= 0;
            conv_map2[3][0] <= 0;
            conv_map2[3][1] <= 0;
            conv_map2[3][2] <= 0;
            conv_map2[3][3] <= 0;
            conv_map2[3][4] <= 0;
            conv_map2[3][5] <= 0;
            conv_map2[4][0] <= 0;
            conv_map2[4][1] <= 0;
            conv_map2[4][2] <= 0;
            conv_map2[4][3] <= 0;
            conv_map2[4][4] <= 0;
            conv_map2[4][5] <= 0;
            conv_map2[5][0] <= 0;
            conv_map2[5][1] <= 0;
            conv_map2[5][2] <= 0;
            conv_map2[5][3] <= 0;
            conv_map2[5][4] <= 0;
            conv_map2[5][5] <= 0;
        end
        8'd4,  8'd40, 8'd76:  conv_map2[0][0] <=  pe_out_ch2[3];
        8'd5,  8'd41, 8'd77:  conv_map2[0][1] <=  pe_out_ch2[3];
        8'd6,  8'd42, 8'd78:  conv_map2[0][2] <=  pe_out_ch2[3];
        8'd7,  8'd43, 8'd79:  conv_map2[0][3] <=  pe_out_ch2[3];
        8'd8,  8'd44, 8'd80:  conv_map2[0][4] <=  pe_out_ch2[3];
        8'd9,  8'd45, 8'd81:  conv_map2[0][5] <=  pe_out_ch2[3];

        8'd10, 8'd46, 8'd82:  conv_map2[1][0] <=  pe_out_ch2[3];
        8'd11, 8'd47, 8'd83:  conv_map2[1][1] <=  pe_out_ch2[3];
        8'd12, 8'd48, 8'd84:  conv_map2[1][2] <=  pe_out_ch2[3];
        8'd13, 8'd49, 8'd85:  conv_map2[1][3] <=  pe_out_ch2[3];
        8'd14, 8'd50, 8'd86:  conv_map2[1][4] <=  pe_out_ch2[3];
        8'd15, 8'd51, 8'd87:  conv_map2[1][5] <=  pe_out_ch2[3];

        8'd16, 8'd52, 8'd88:  conv_map2[2][0] <=  pe_out_ch2[3];
        8'd17, 8'd53, 8'd89:  conv_map2[2][1] <=  pe_out_ch2[3];
        8'd18, 8'd54, 8'd90:  conv_map2[2][2] <=  pe_out_ch2[3];
        8'd19, 8'd55, 8'd91:  conv_map2[2][3] <=  pe_out_ch2[3];
        8'd20, 8'd56, 8'd92:  conv_map2[2][4] <=  pe_out_ch2[3];
        8'd21, 8'd57, 8'd93:  conv_map2[2][5] <=  pe_out_ch2[3];

        8'd22, 8'd58, 8'd94:  conv_map2[3][0] <=  pe_out_ch2[3];
        8'd23, 8'd59, 8'd95:  conv_map2[3][1] <=  pe_out_ch2[3];
        8'd24, 8'd60, 8'd96:  conv_map2[3][2] <=  pe_out_ch2[3];
        8'd25, 8'd61, 8'd97:  conv_map2[3][3] <=  pe_out_ch2[3];
        8'd26, 8'd62, 8'd98:  conv_map2[3][4] <=  pe_out_ch2[3];
        8'd27, 8'd63, 8'd99:  conv_map2[3][5] <=  pe_out_ch2[3];

        8'd28, 8'd64, 8'd100: conv_map2[4][0] <=  pe_out_ch2[3];
        8'd29, 8'd65, 8'd101: conv_map2[4][1] <=  pe_out_ch2[3];
        8'd30, 8'd66, 8'd102: conv_map2[4][2] <=  pe_out_ch2[3];
        8'd31, 8'd67, 8'd103: conv_map2[4][3] <=  pe_out_ch2[3];
        8'd32, 8'd68, 8'd104: conv_map2[4][4] <=  pe_out_ch2[3];
        8'd33, 8'd69, 8'd105: conv_map2[4][5] <=  pe_out_ch2[3];

        8'd34, 8'd70, 8'd106: conv_map2[5][0] <=  pe_out_ch2[3];
        8'd35, 8'd71, 8'd107: conv_map2[5][1] <=  pe_out_ch2[3];
        8'd36, 8'd72, 8'd108: conv_map2[5][2] <=  pe_out_ch2[3];
        8'd37, 8'd73, 8'd109: conv_map2[5][3] <=  pe_out_ch2[3];
        8'd38, 8'd74, 8'd110: conv_map2[5][4] <=  pe_out_ch2[3];
        8'd39, 8'd75, 8'd111: conv_map2[5][5] <=  pe_out_ch2[3];

    endcase
end
//////conv finish

//////////////////////////////////////
//                 max pooling
////////////////////////////////////////////////////////////
reg [31:0] mp_1_2_1 [0:1];
reg [31:0] mp_1_2_2 [0:1];
reg [31:0] mp_1_3_1 [0:1];
reg [31:0] mp_1_4_1;

reg [31:0] mp_2_2_1 [0:1];
reg [31:0] mp_2_2_2 [0:1];
reg [31:0] mp_2_3_1 [0:1];
reg [31:0] mp_2_4_1;

reg [31:0] mp_3_2_1 [0:1];
reg [31:0] mp_3_2_2 [0:1];
reg [31:0] mp_3_3_1 [0:1];
reg [31:0] mp_3_4_1;

reg [31:0] mp_4_2_1 [0:1];
reg [31:0] mp_4_2_2 [0:1];
reg [31:0] mp_4_3_1 [0:1];
reg [31:0] mp_4_4_1;

reg [31:0] mp_5_2_1 [0:1];
reg [31:0] mp_5_2_2 [0:1];
reg [31:0] mp_5_3_1 [0:1];
reg [31:0] mp_5_4_1;

reg [31:0] mp_6_2_1 [0:1];
reg [31:0] mp_6_2_2 [0:1];
reg [31:0] mp_6_3_1 [0:1];
reg [31:0] mp_6_4_1;

reg [31:0] mp_7_2_1 [0:1];
reg [31:0] mp_7_2_2 [0:1];
reg [31:0] mp_7_3_1 [0:1];
reg [31:0] mp_7_4_1;

reg [31:0] mp_8_2_1 [0:1];
reg [31:0] mp_8_2_2 [0:1];
reg [31:0] mp_8_3_1 [0:1];
reg [31:0] mp_8_4_1;

reg [31:0] mp_map_1 [0:1][0:1];
reg [31:0] mp_map_2 [0:1][0:1];
/////1
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_1_1 ( .a(conv_map1[0][0]), .b(conv_map1[0][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_1_2 ( .a(conv_map1[0][2]), .b(conv_map1[1][0]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_1_3 ( .a(conv_map1[1][1]), .b(conv_map1[1][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_1_4 ( .a(conv_map1[2][0]), .b(conv_map1[2][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_2_1 ( .a(mp_1_2_1[0]), .b(mp_1_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_2_2 ( .a(mp_1_2_2[0]), .b(mp_1_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_3_1 ( .a(mp_1_3_1[0]), .b(mp_1_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_1_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_1_4_1 ( .a(mp_1_4_1), .b(conv_map1[2][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_1[0][0]), .status0(), .status1() );

////2
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_1_1 ( .a(conv_map1[0][3]), .b(conv_map1[0][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_1_2 ( .a(conv_map1[0][5]), .b(conv_map1[1][3]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_1_3 ( .a(conv_map1[1][4]), .b(conv_map1[1][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_1_4 ( .a(conv_map1[2][3]), .b(conv_map1[2][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_2_1 ( .a(mp_2_2_1[0]), .b(mp_2_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_2_2 ( .a(mp_2_2_2[0]), .b(mp_2_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_3_1 ( .a(mp_2_3_1[0]), .b(mp_2_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_2_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_2_4_1 ( .a(mp_2_4_1), .b(conv_map1[2][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_1[0][1]), .status0(), .status1() );


////3
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_1_1 ( .a(conv_map1[3][0]), .b(conv_map1[3][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_1_2 ( .a(conv_map1[3][2]), .b(conv_map1[4][0]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_1_3 ( .a(conv_map1[4][1]), .b(conv_map1[4][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_1_4 ( .a(conv_map1[5][0]), .b(conv_map1[5][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_2_1 ( .a(mp_3_2_1[0]), .b(mp_3_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_2_2 ( .a(mp_3_2_2[0]), .b(mp_3_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_3_1 ( .a(mp_3_3_1[0]), .b(mp_3_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_3_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_3_4_1 ( .a(mp_3_4_1), .b(conv_map1[5][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_1[1][0]), .status0(), .status1() );



////4
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_1_1 ( .a(conv_map1[3][3]), .b(conv_map1[3][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_1_2 ( .a(conv_map1[3][5]), .b(conv_map1[4][3]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_1_3 ( .a(conv_map1[4][4]), .b(conv_map1[4][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_1_4 ( .a(conv_map1[5][3]), .b(conv_map1[5][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_2_1 ( .a(mp_4_2_1[0]), .b(mp_4_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_2_2 ( .a(mp_4_2_2[0]), .b(mp_4_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_3_1 ( .a(mp_4_3_1[0]), .b(mp_4_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_4_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_4_4_1 ( .a(mp_4_4_1), .b(conv_map1[5][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_1[1][1]), .status0(), .status1() );

////////////////////////////////////
/////5
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_1_1 ( .a(conv_map2[0][0]), .b(conv_map2[0][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_1_2 ( .a(conv_map2[0][2]), .b(conv_map2[1][0]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_1_3 ( .a(conv_map2[1][1]), .b(conv_map2[1][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_1_4 ( .a(conv_map2[2][0]), .b(conv_map2[2][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_2_1 ( .a(mp_5_2_1[0]), .b(mp_5_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_2_2 ( .a(mp_5_2_2[0]), .b(mp_5_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_3_1 ( .a(mp_5_3_1[0]), .b(mp_5_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_5_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_5_4_1 ( .a(mp_5_4_1), .b(conv_map2[2][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_2[0][0]), .status0(), .status1() );



////6
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_1_1 ( .a(conv_map2[0][3]), .b(conv_map2[0][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_1_2 ( .a(conv_map2[0][5]), .b(conv_map2[1][3]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_1_3 ( .a(conv_map2[1][4]), .b(conv_map2[1][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_1_4 ( .a(conv_map2[2][3]), .b(conv_map2[2][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_2_1 ( .a(mp_6_2_1[0]), .b(mp_6_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_2_2 ( .a(mp_6_2_2[0]), .b(mp_6_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_3_1 ( .a(mp_6_3_1[0]), .b(mp_6_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_6_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_6_4_1 ( .a(mp_6_4_1), .b(conv_map2[2][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_2[0][1]), .status0(), .status1() );



////7
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_1_1 ( .a(conv_map2[3][0]), .b(conv_map2[3][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_1_2 ( .a(conv_map2[3][2]), .b(conv_map2[4][0]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_1_3 ( .a(conv_map2[4][1]), .b(conv_map2[4][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_1_4 ( .a(conv_map2[5][0]), .b(conv_map2[5][1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_2_1 ( .a(mp_7_2_1[0]), .b(mp_7_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_2_2 ( .a(mp_7_2_2[0]), .b(mp_7_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_3_1 ( .a(mp_7_3_1[0]), .b(mp_7_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_7_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_7_4_1 ( .a(mp_7_4_1), .b(conv_map2[5][2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_2[1][0]), .status0(), .status1() );


////8
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_1_1 ( .a(conv_map2[3][3]), .b(conv_map2[3][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_2_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_1_2 ( .a(conv_map2[3][5]), .b(conv_map2[4][3]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_2_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_1_3 ( .a(conv_map2[4][4]), .b(conv_map2[4][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_2_2[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_1_4 ( .a(conv_map2[5][3]), .b(conv_map2[5][4]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_2_2[1]), .status0(), .status1() );


DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_2_1 ( .a(mp_8_2_1[0]), .b(mp_8_2_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_3_1[0]), .status0(), .status1() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_2_2 ( .a(mp_8_2_2[0]), .b(mp_8_2_2[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_3_1[1]), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_3_1 ( .a(mp_8_3_1[0]), .b(mp_8_3_1[1]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_8_4_1), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
         max_pooling_8_4_1 ( .a(mp_8_4_1), .b(conv_map2[5][5]), .zctr(1'b0), .aeqb(), .altb(), .agtb(), .unordered(), .z0(), .z1(mp_map_2[1][1]), .status0(), .status1() );


//mp finish
/////////////////////////////////////////


always @(posedge clk ) begin
    case (count)
        8'd111: act_f <= mp_map_1[0][0];
        8'd112: act_f <= mp_map_1[0][1];
        8'd113: act_f <= mp_map_1[1][0];
        8'd114: act_f <= mp_map_1[1][1];
        8'd115: act_f <= mp_map_2[0][0];
        8'd116: act_f <= mp_map_2[0][1];
        8'd117: act_f <= mp_map_2[1][0];
        8'd118: act_f <= mp_map_2[1][1];
        default: act_f <= 0;
    endcase

end

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
        exp_pos1 (.a(act_f), .z(e_pos), .status() );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
        exp_neg1 (.a({~act_f[31] , act_f[30:0]}), .z(e_neg), .status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    act_f_add1 ( .a(32'b00111111100000000000000000000000), .b(e_neg), .rnd(3'b000), .z(sigmoid_d), .status() );




DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
        act_f_div1 ( .a(32'b00111111100000000000000000000000), .b(sigmoid_d), .rnd(3'b0), .z(sigmoid), .status() );



DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    act_f_add2 ( .a(e_pos), .b({~e_neg[31] , e_neg[30:0]}), .rnd(3'b000), .z(tanh_u), .status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    act_f_add3 ( .a(e_pos), .b(e_neg), .rnd(3'b000), .z(tanh_d), .status() );

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
        act_f_div2 ( .a(tanh_u), .b(tanh_d), .rnd(3'b0), .z(tanh), .status() );



always @(posedge clk ) begin
    if(current_opt_reg == 1'd0 ) begin
        act_finish_reg <= sigmoid;
    end

    else if (current_opt_reg == 1'd1 ) begin
        act_finish_reg <= tanh;
    end
end
reg [31:0] fully_in1, fully_in2, fully_in3;

reg [31:0] fc_reg1, fc_seq_out1, fc_out1;
reg [31:0] fc_reg2, fc_seq_out2, fc_out2;
reg [31:0] fc_reg3, fc_seq_out3, fc_out3;

always @(posedge clk ) begin
    case (count)
        8'd112: fully_in1 <= weight_reg[0][0];
        8'd113: fully_in1 <= weight_reg[0][1];
        8'd114: fully_in1 <= weight_reg[0][2];
        8'd115: fully_in1 <= weight_reg[0][3];
        8'd116: fully_in1 <= weight_reg[0][4];
        8'd117: fully_in1 <= weight_reg[0][5];
        8'd118: fully_in1 <= weight_reg[0][6];
        8'd119: fully_in1 <= weight_reg[0][7];
        default: fully_in1 <= 0;
    endcase
end

always @(posedge clk ) begin
    case (count)
        8'd112: fully_in2 <= weight_reg[1][0];
        8'd113: fully_in2 <= weight_reg[1][1];
        8'd114: fully_in2 <= weight_reg[1][2];
        8'd115: fully_in2 <= weight_reg[1][3];
        8'd116: fully_in2 <= weight_reg[1][4];
        8'd117: fully_in2 <= weight_reg[1][5];
        8'd118: fully_in2 <= weight_reg[1][6];
        8'd119: fully_in2 <= weight_reg[1][7];
        default: fully_in2 <= 0;
    endcase
end

always @(posedge clk ) begin
    case (count)
        8'd112: fully_in3 <= weight_reg[2][0];
        8'd113: fully_in3 <= weight_reg[2][1];
        8'd114: fully_in3 <= weight_reg[2][2];
        8'd115: fully_in3 <= weight_reg[2][3];
        8'd116: fully_in3 <= weight_reg[2][4];
        8'd117: fully_in3 <= weight_reg[2][5];
        8'd118: fully_in3 <= weight_reg[2][6];
        8'd119: fully_in3 <= weight_reg[2][7];
        default: fully_in3 <= 0;
    endcase
end


DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc1_mult ( .a(act_finish_reg), .b(fully_in1), .rnd(3'b000), .z(fc_reg1), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc1_add ( .a(fc_reg1), .b(fc_seq_out1), .rnd(3'b000), .z(fc_out1), .status() );


always @(posedge clk ) begin
    if (count == 8'd112) begin
        fc_seq_out1 <= 0;
    end
    else begin
        fc_seq_out1 <= fc_out1;
    end
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc2_mult ( .a(act_finish_reg), .b(fully_in2), .rnd(3'b000), .z(fc_reg2), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc2_add ( .a(fc_reg2), .b(fc_seq_out2), .rnd(3'b000), .z(fc_out2), .status() );


always @(posedge clk ) begin
    if (count == 8'd112) begin
        fc_seq_out2 <= 0;
    end
    else begin
        fc_seq_out2 <= fc_out2;
    end
end

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc3_mult ( .a(act_finish_reg), .b(fully_in3), .rnd(3'b000), .z(fc_reg3), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc3_add ( .a(fc_reg3), .b(fc_seq_out3), .rnd(3'b000), .z(fc_out3), .status() );


always @(posedge clk ) begin
    if (count == 8'd112) begin
        fc_seq_out3 <= 0;
    end
    else begin
        fc_seq_out3 <= fc_out3;
    end
end
////////////////////////////
///      soft max      /////
////////////////////////////
reg [31:0] soft_in, soft_out;
reg [31:0] soft_exp_out;
reg [31:0] soft_exp_out_seq, soft_exp_out_seq2, soft_exp_out_seq3, soft_out_seq;
reg [31:0] s1, s2, s3;
reg [31:0] final_out[0:2];
always @(posedge clk ) begin
    if (count == 8'd120) begin
        soft_in <= fc_out1;
    end
    else if (count == 8'd121) begin
        soft_in <= fc_out2;
    end
    else if (count == 8'd122) begin
        soft_in <= fc_out3;
    end
    else begin
        soft_in <= 0;
    end
end


DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
        exp_soft (.a(soft_in), .z(soft_exp_out), .status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
        add_soft ( .a(soft_exp_out), .b(soft_out_seq), .rnd(3'b000), .z(soft_out), .status() );


always @(posedge clk ) begin
    if (count == 8'd121 || count == 8'd122 || count == 8'd123) begin
        soft_out_seq <= soft_out;
    end
    else begin
        soft_out_seq <= 0;
    end
end

always @(posedge clk ) begin
    soft_exp_out_seq <= soft_exp_out;
end

always @(posedge clk ) begin
    soft_exp_out_seq2 <= soft_exp_out_seq;
end

always @(posedge clk ) begin
    soft_exp_out_seq3 <= soft_exp_out_seq2;
end

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
        soft_div1 ( .a(soft_exp_out_seq3), .b(soft_out_seq), .rnd(3'b0), .z(s1), .status() );

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
        soft_div2 ( .a(soft_exp_out_seq2), .b(soft_out_seq), .rnd(3'b0), .z(s2), .status() );

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
        soft_div3 ( .a(soft_exp_out_seq), .b(soft_out_seq), .rnd(3'b0), .z(s3), .status() );

always @(posedge clk ) begin
    if (count == 124) begin
        final_out[0] <= s1;
        final_out[1] <= s2; 
        final_out[2] <= s3;  
    end
    else if (count == 125) begin
        final_out[0] <= final_out[0];
        final_out[1] <= final_out[1]; 
        final_out[2] <= final_out[2];  
    end
    else if (count == 126) begin
        final_out[0] <= final_out[0];
        final_out[1] <= final_out[1]; 
        final_out[2] <= final_out[2];  
    end
    else begin
        final_out[0] <= 0;
        final_out[1] <= 0; 
        final_out[2] <= 0;  
    end
end

/*
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc3_mult ( .a(act_finish_reg), .b(fully_in3), .rnd(3'b000), .z(fc_reg3), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    fc3_add ( .a(fc_reg3), .b(fc_seq_out3), .rnd(3'b000), .z(fc_out3), .status() );


always @(posedge clk ) begin
    if (count[6:0] == 7'd112) begin
        fc_seq_out3 <= 0;
    end
    else begin
        fc_seq_out3 <= fc_out3;
    end
end
*/





/*
32'b00111111100000000000000000000000    == 1
DW_fp_exp_inst E_NEG(.inst_a({~act_in[31] , act_in[30:0]}), .z_inst(e_neg));
DW_fp_exp_inst E_POS(.inst_a(act_in), .z_inst(e_pos));
*/
        // -1 in IEEE 754 is 32'b10111111100000000000000000000000
        // +1 in IEEE 754 is 32'b00111111100000000000000000000000
        // +0 in IEEE 754 is 32'b00000000000000000000000000000000
        // +2 in IEEE 754 is 32'b01000000000000000000000000000000
always @(*) begin
    if (count == 0 && in_valid ==1) begin
        next_opt_reg = Opt;
    end
    else next_opt_reg = current_opt_reg;
end

always @(posedge clk ) begin
    current_opt_reg <= next_opt_reg;
end




////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (count == 125 || count == 126 || count == 127) begin
        out_valid <= 1;
    end
     else begin
        out_valid <= 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 0;
    end 
    else if (count == 125) begin
        out <= final_out[0];
    end
    else if (count == 126) begin
        out <= final_out[1];
    end
    else if (count == 127) begin
        out <= final_out[2];
    end
    else begin
        out <= 0;
    end
end

endmodule


/*
always @(posedge clk or posedge reset)begin
	if(reset)count<=0;
	else if(ns==READ) count<=count+1;
    else if(count==100) count<=0;
	else if(ns==WORK) count<=count+1;
    else if(count==4) count<=0;
    else if(ns==OUT) count<=count+1;
    else if(count==4) count<=0;
    else if(ns==OUTD) count<=count+1;
    else if(count==0) count<=0;
    else if(cs==IDLE) count<=0;
    else  count<=count;
end
*/



///////////////////////////////////////////
//               IP                      //
///////////////////////////////////////////
module DW_fp_mult_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [2 : 0] inst_rnd;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;
// Instance of DW_fp_mult
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule


module DW_fp_add_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [2 : 0] inst_rnd;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;
// Instance of DW_fp_add
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule


module DW_fp_cmp_inst( inst_a, inst_b, inst_zctr, aeqb_inst, altb_inst,
agtb_inst, unordered_inst, z0_inst, z1_inst, status0_inst,
status1_inst );
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input inst_zctr;
output aeqb_inst;
output altb_inst;
output agtb_inst;
output unordered_inst;
output [inst_sig_width+inst_exp_width : 0] z0_inst;
output [inst_sig_width+inst_exp_width : 0] z1_inst;
output [7 : 0] status0_inst;
output [7 : 0] status1_inst;
// Instance of DW_fp_cmp
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U1 ( .a(inst_a), .b(inst_b), .zctr(inst_zctr), .aeqb(aeqb_inst), 
.altb(altb_inst), .agtb(agtb_inst), .unordered(unordered_inst), 
.z0(z0_inst), .z1(z1_inst), .status0(status0_inst),
.status1(status1_inst) );
endmodule



// division of floating point
module DW_fp_div_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_faithful_round = 0;

input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [2 : 0] inst_rnd;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;
// Instance of DW_fp_div
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) U1
( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst)
);
endmodule

module DW_fp_exp_inst( inst_a, z_inst, status_inst );
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;

input [inst_sig_width+inst_exp_width : 0] inst_a;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;
// Instance of DW_fp_exp
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U1 (
.a(inst_a),
.z(z_inst),
.status(status_inst) );
endmodule
