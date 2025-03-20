//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab01 Exercise		: Snack Shopping Calculator
//   Author     		  : Yu-Hsiang Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SSC.v
//   Module Name : SSC
//   Release version : V1.0 (Release Date: 2024-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SSC(
    // Input signals
    card_num,
    input_money,
    snack_num,
    price, 
    // Output signals
    out_valid,
    out_change
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [63:0] card_num;
input [8:0] input_money;
input [31:0] snack_num;
input [31:0] price;
output out_valid;
output [8:0] out_change;    

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

reg [7:0] sum;
reg [3:0] card_1,card_2,card_3,card_4,card_5,card_6,card_7,card_8;

reg [7:0] snack [7:0];

//reg valid_num;

wire [7:0] ab_max, ab_min, cd_max, cd_min;
wire [7:0] a_smaller_than_max, a_bigger_than_min;
wire [7:0] a_sort_max, a_sort_sec, a_sort_thd, a_sort_min;

wire [7:0] ef_max, ef_min, gh_max, gh_min;
wire [7:0] b_smaller_than_max, b_bigger_than_min;
wire [7:0] b_sort_max, b_sort_sec, b_sort_thd, b_sort_min;

wire [7:0] c_sort_min, c_sort_thd, d_sort_max, d_sort_sec;

wire [7:0] c_smaller_than_max, c_bigger_than_min;
wire [7:0] d_smaller_than_max, d_bigger_than_min;
wire [7:0] e_smaller_than_max, e_bigger_than_min;


wire [7:0] max, sec, thd, forth, fifth, sixth, seventh, min;


//================================================================
//    DESIGN
//================================================================

function [3:0] transform_card(input [3:0] card);
    begin
        case (card)
            4'b1001: transform_card = 4'b1001;
            4'b1000: transform_card = 4'b0111;
            4'b0111: transform_card = 4'b0101;
            4'b0110: transform_card = 4'b0011;
            4'b0101: transform_card = 4'b0001;
            4'b0100: transform_card = 4'b1000;
            4'b0011: transform_card = 4'b0110;
            4'b0010: transform_card = 4'b0100;
            4'b0001: transform_card = 4'b0010;
            default: transform_card = 4'b0000;
        endcase
    end
endfunction

always @(*) begin
    card_1 = transform_card(card_num[63:60]);
    card_2 = transform_card(card_num[55:52]);
    card_3 = transform_card(card_num[47:44]);
    card_4 = transform_card(card_num[39:36]);
    card_5 = transform_card(card_num[31:28]);
    card_6 = transform_card(card_num[23:20]);
    card_7 = transform_card(card_num[15:12]);
    card_8 = transform_card(card_num[7:4]);
end



always @(*) begin
    sum = card_1+card_2+card_3+card_4+card_5+card_6+card_7+card_8+card_num[59:56]+card_num[51:48]+card_num[43:40]+card_num[35:32]+card_num[27:24]+card_num[19:16]+card_num[11:8]+card_num[3:0];
end



always @(*) begin
    case (snack_num[31:28])
        4'd1: snack[7] = price[31:28];
        4'd2: snack[7] = price[31:28] << 1; // *2
        4'd3: snack[7] = (price[31:28] << 1) + price[31:28]; // *3
        4'd4: snack[7] = price[31:28] << 2; // *4
        4'd5: snack[7] = (price[31:28] << 2) + price[31:28]; // *5
        4'd6: snack[7] = (price[31:28] << 2) + (price[31:28] << 1); // *6
        4'd7: snack[7] = (price[31:28] << 2) + (price[31:28] << 1) + price[31:28]; // *7
        4'd8: snack[7] = price[31:28] << 3; // *8
        4'd9: snack[7] = (price[31:28] << 3) + price[31:28]; // *9
        4'd10: snack[7] = (price[31:28] << 3) + (price[31:28] << 1); // *10
        4'd11: snack[7] = (price[31:28] << 3) + (price[31:28] << 1) + price[31:28]; // *11
        4'd12: snack[7] = (price[31:28] << 3) + (price[31:28] << 2); // *12
        4'd13: snack[7] = (price[31:28] << 3) + (price[31:28] << 2) + price[31:28]; // *13
        4'd14: snack[7] = (price[31:28] << 3) + (price[31:28] << 2) + (price[31:28] << 1); // *14
        4'd15: snack[7] = (price[31:28] << 3) + (price[31:28] << 2) + (price[31:28] << 1) + price[31:28]; // *15
        default: snack[7] = 8'd0;
    endcase
end


always @(*) begin
    case (snack_num[27:24])
        4'd1: snack[6] = price[27:24];                                // 1 * price
        4'd2: snack[6] = price[27:24] << 1;                           // 2 * price
        4'd3: snack[6] = (price[27:24] << 1) + price[27:24];          // 3 * price
        4'd4: snack[6] = price[27:24] << 2;                           // 4 * price
        4'd5: snack[6] = (price[27:24] << 2) + price[27:24];          // 5 * price
        4'd6: snack[6] = (price[27:24] << 2) + (price[27:24] << 1);   // 6 * price
        4'd7: snack[6] = (price[27:24] << 2) + (price[27:24] << 1) + price[27:24]; // 7 * price
        4'd8: snack[6] = price[27:24] << 3;                           // 8 * price
        4'd9: snack[6] = (price[27:24] << 3) + price[27:24];          // 9 * price
        4'd10: snack[6] = (price[27:24] << 3) + (price[27:24] << 1);  // 10 * price
        4'd11: snack[6] = (price[27:24] << 3) + (price[27:24] << 1) + price[27:24]; // 11 * price
        4'd12: snack[6] = (price[27:24] << 3) + (price[27:24] << 2);  // 12 * price
        4'd13: snack[6] = (price[27:24] << 3) + (price[27:24] << 2) + price[27:24]; // 13 * price
        4'd14: snack[6] = (price[27:24] << 3) + (price[27:24] << 2) + (price[27:24] << 1); // 14 * price
        4'd15: snack[6] = (price[27:24] << 3) + (price[27:24] << 2) + (price[27:24] << 1) + price[27:24]; // 15 * price
        default: snack[6] = 8'd0;
    endcase
end


always @(*) begin
    case (snack_num[23:20])
        4'd1: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd1;
                4'd2: snack[5] = 8'd2;
                4'd3: snack[5] = 8'd3;
                4'd4: snack[5] = 8'd4;
                4'd5: snack[5] = 8'd5;
                4'd6: snack[5] = 8'd6;
                4'd7: snack[5] = 8'd7;
                4'd8: snack[5] = 8'd8;
                4'd9: snack[5] = 8'd9;
                4'd10: snack[5] = 8'd10;
                4'd11: snack[5] = 8'd11;
                4'd12: snack[5] = 8'd12;
                4'd13: snack[5] = 8'd13;
                4'd14: snack[5] = 8'd14;
                4'd15: snack[5] = 8'd15;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd2: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd2;
                4'd2: snack[5] = 8'd4;
                4'd3: snack[5] = 8'd6;
                4'd4: snack[5] = 8'd8;
                4'd5: snack[5] = 8'd10;
                4'd6: snack[5] = 8'd12;
                4'd7: snack[5] = 8'd14;
                4'd8: snack[5] = 8'd16;
                4'd9: snack[5] = 8'd18;
                4'd10: snack[5] = 8'd20;
                4'd11: snack[5] = 8'd22;
                4'd12: snack[5] = 8'd24;
                4'd13: snack[5] = 8'd26;
                4'd14: snack[5] = 8'd28;
                4'd15: snack[5] = 8'd30;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd3: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd3;
                4'd2: snack[5] = 8'd6;
                4'd3: snack[5] = 8'd9;
                4'd4: snack[5] = 8'd12;
                4'd5: snack[5] = 8'd15;
                4'd6: snack[5] = 8'd18;
                4'd7: snack[5] = 8'd21;
                4'd8: snack[5] = 8'd24;
                4'd9: snack[5] = 8'd27;
                4'd10: snack[5] = 8'd30;
                4'd11: snack[5] = 8'd33;
                4'd12: snack[5] = 8'd36;
                4'd13: snack[5] = 8'd39;
                4'd14: snack[5] = 8'd42;
                4'd15: snack[5] = 8'd45;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd4: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd4;
                4'd2: snack[5] = 8'd8;
                4'd3: snack[5] = 8'd12;
                4'd4: snack[5] = 8'd16;
                4'd5: snack[5] = 8'd20;
                4'd6: snack[5] = 8'd24;
                4'd7: snack[5] = 8'd28;
                4'd8: snack[5] = 8'd32;
                4'd9: snack[5] = 8'd36;
                4'd10: snack[5] = 8'd40;
                4'd11: snack[5] = 8'd44;
                4'd12: snack[5] = 8'd48;
                4'd13: snack[5] = 8'd52;
                4'd14: snack[5] = 8'd56;
                4'd15: snack[5] = 8'd60;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd5: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd5;
                4'd2: snack[5] = 8'd10;
                4'd3: snack[5] = 8'd15;
                4'd4: snack[5] = 8'd20;
                4'd5: snack[5] = 8'd25;
                4'd6: snack[5] = 8'd30;
                4'd7: snack[5] = 8'd35;
                4'd8: snack[5] = 8'd40;
                4'd9: snack[5] = 8'd45;
                4'd10: snack[5] = 8'd50;
                4'd11: snack[5] = 8'd55;
                4'd12: snack[5] = 8'd60;
                4'd13: snack[5] = 8'd65;
                4'd14: snack[5] = 8'd70;
                4'd15: snack[5] = 8'd75;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd6: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd6;
                4'd2: snack[5] = 8'd12;
                4'd3: snack[5] = 8'd18;
                4'd4: snack[5] = 8'd24;
                4'd5: snack[5] = 8'd30;
                4'd6: snack[5] = 8'd36;
                4'd7: snack[5] = 8'd42;
                4'd8: snack[5] = 8'd48;
                4'd9: snack[5] = 8'd54;
                4'd10: snack[5] = 8'd60;
                4'd11: snack[5] = 8'd66;
                4'd12: snack[5] = 8'd72;
                4'd13: snack[5] = 8'd78;
                4'd14: snack[5] = 8'd84;
                4'd15: snack[5] = 8'd90;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd7: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd7;
                4'd2: snack[5] = 8'd14;
                4'd3: snack[5] = 8'd21;
                4'd4: snack[5] = 8'd28;
                4'd5: snack[5] = 8'd35;
                4'd6: snack[5] = 8'd42;
                4'd7: snack[5] = 8'd49;
                4'd8: snack[5] = 8'd56;
                4'd9: snack[5] = 8'd63;
                4'd10: snack[5] = 8'd70;
                4'd11: snack[5] = 8'd77;
                4'd12: snack[5] = 8'd84;
                4'd13: snack[5] = 8'd91;
                4'd14: snack[5] = 8'd98;
                4'd15: snack[5] = 8'd105;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd8: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd8;
                4'd2: snack[5] = 8'd16;
                4'd3: snack[5] = 8'd24;
                4'd4: snack[5] = 8'd32;
                4'd5: snack[5] = 8'd40;
                4'd6: snack[5] = 8'd48;
                4'd7: snack[5] = 8'd56;
                4'd8: snack[5] = 8'd64;
                4'd9: snack[5] = 8'd72;
                4'd10: snack[5] = 8'd80;
                4'd11: snack[5] = 8'd88;
                4'd12: snack[5] = 8'd96;
                4'd13: snack[5] = 8'd104;
                4'd14: snack[5] = 8'd112;
                4'd15: snack[5] = 8'd120;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd9: begin
            case (price[23:20])
                4'd1: snack[5] = 8'd9;
                4'd2: snack[5] = 8'd18;
                4'd3: snack[5] = 8'd27;
                4'd4: snack[5] = 8'd36;
                4'd5: snack[5] = 8'd45;
                4'd6: snack[5] = 8'd54;
                4'd7: snack[5] = 8'd63;
                4'd8: snack[5] = 8'd72;
                4'd9: snack[5] = 8'd81;
                4'd10: snack[5] = 8'd90;
                4'd11: snack[5] = 8'd99;
                4'd12: snack[5] = 8'd108;
                4'd13: snack[5] = 8'd117;
                4'd14: snack[5] = 8'd126;
                4'd15: snack[5] = 8'd135;
                default: snack[5] = 8'd0;
            endcase
        end
        4'd10: begin
    case (price[23:20])
        4'd1: snack[5] = 8'd10;
        4'd2: snack[5] = 8'd20;
        4'd3: snack[5] = 8'd30;
        4'd4: snack[5] = 8'd40;
        4'd5: snack[5] = 8'd50;
        4'd6: snack[5] = 8'd60;
        4'd7: snack[5] = 8'd70;
        4'd8: snack[5] = 8'd80;
        4'd9: snack[5] = 8'd90;
        4'd10: snack[5] = 8'd100;
        4'd11: snack[5] = 8'd110;
        4'd12: snack[5] = 8'd120;
        4'd13: snack[5] = 8'd130;
        4'd14: snack[5] = 8'd140;
        4'd15: snack[5] = 8'd150;
        default: snack[5] = 8'd0;
    endcase
end
4'd11: begin
    case (price[23:20])
        4'd1: snack[5] = 8'd11;
        4'd2: snack[5] = 8'd22;
        4'd3: snack[5] = 8'd33;
        4'd4: snack[5] = 8'd44;
        4'd5: snack[5] = 8'd55;
        4'd6: snack[5] = 8'd66;
        4'd7: snack[5] = 8'd77;
        4'd8: snack[5] = 8'd88;
        4'd9: snack[5] = 8'd99;
        4'd10: snack[5] = 8'd110;
        4'd11: snack[5] = 8'd121;
        4'd12: snack[5] = 8'd132;
        4'd13: snack[5] = 8'd143;
        4'd14: snack[5] = 8'd154;
        4'd15: snack[5] = 8'd165;
        default: snack[5] = 8'd0;
    endcase
end
4'd12: begin
    case (price[23:20])
        4'd1: snack[5] = 8'd12;
        4'd2: snack[5] = 8'd24;
        4'd3: snack[5] = 8'd36;
        4'd4: snack[5] = 8'd48;
        4'd5: snack[5] = 8'd60;
        4'd6: snack[5] = 8'd72;
        4'd7: snack[5] = 8'd84;
        4'd8: snack[5] = 8'd96;
        4'd9: snack[5] = 8'd108;
        4'd10: snack[5] = 8'd120;
        4'd11: snack[5] = 8'd132;
        4'd12: snack[5] = 8'd144;
        4'd13: snack[5] = 8'd156;
        4'd14: snack[5] = 8'd168;
        4'd15: snack[5] = 8'd180;
        default: snack[5] = 8'd0;
    endcase
end
4'd13: begin
    case (price[23:20])
        4'd1: snack[5] = 8'd13;
        4'd2: snack[5] = 8'd26;
        4'd3: snack[5] = 8'd39;
        4'd4: snack[5] = 8'd52;
        4'd5: snack[5] = 8'd65;
        4'd6: snack[5] = 8'd78;
        4'd7: snack[5] = 8'd91;
        4'd8: snack[5] = 8'd104;
        4'd9: snack[5] = 8'd117;
        4'd10: snack[5] = 8'd130;
        4'd11: snack[5] = 8'd143;
        4'd12: snack[5] = 8'd156;
        4'd13: snack[5] = 8'd169;
        4'd14: snack[5] = 8'd182;
        4'd15: snack[5] = 8'd195;
        default: snack[5] = 8'd0;
    endcase
end
4'd14: begin
    case (price[23:20])
        4'd1: snack[5] = 8'd14;
        4'd2: snack[5] = 8'd28;
        4'd3: snack[5] = 8'd42;
        4'd4: snack[5] = 8'd56;
        4'd5: snack[5] = 8'd70;
        4'd6: snack[5] = 8'd84;
        4'd7: snack[5] = 8'd98;
        4'd8: snack[5] = 8'd112;
        4'd9: snack[5] = 8'd126;
        4'd10: snack[5] = 8'd140;
        4'd11: snack[5] = 8'd154;
        4'd12: snack[5] = 8'd168;
        4'd13: snack[5] = 8'd182;
        4'd14: snack[5] = 8'd196;
        4'd15: snack[5] = 8'd210;
        default: snack[5] = 8'd0;
    endcase
end
4'd15: begin
    case (price[23:20])
        4'd1: snack[5] = 8'd15;
        4'd2: snack[5] = 8'd30;
        4'd3: snack[5] = 8'd45;
        4'd4: snack[5] = 8'd60;
        4'd5: snack[5] = 8'd75;
        4'd6: snack[5] = 8'd90;
        4'd7: snack[5] = 8'd105;
        4'd8: snack[5] = 8'd120;
        4'd9: snack[5] = 8'd135;
        4'd10: snack[5] = 8'd150;
        4'd11: snack[5] = 8'd165;
        4'd12: snack[5] = 8'd180;
        4'd13: snack[5] = 8'd195;
        4'd14: snack[5] = 8'd210;
        4'd15: snack[5] = 8'd225;
        default: snack[5] = 8'd0;
    endcase
end

        default: snack[5] = 8'd0;
    endcase
end


always @(*) begin
    case (snack_num[19:16])
        4'd1: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd1;
                4'd2: snack[4] = 8'd2;
                4'd3: snack[4] = 8'd3;
                4'd4: snack[4] = 8'd4;
                4'd5: snack[4] = 8'd5;
                4'd6: snack[4] = 8'd6;
                4'd7: snack[4] = 8'd7;
                4'd8: snack[4] = 8'd8;
                4'd9: snack[4] = 8'd9;
                4'd10: snack[4] = 8'd10;
                4'd11: snack[4] = 8'd11;
                4'd12: snack[4] = 8'd12;
                4'd13: snack[4] = 8'd13;
                4'd14: snack[4] = 8'd14;
                4'd15: snack[4] = 8'd15;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd2: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd2;
                4'd2: snack[4] = 8'd4;
                4'd3: snack[4] = 8'd6;
                4'd4: snack[4] = 8'd8;
                4'd5: snack[4] = 8'd10;
                4'd6: snack[4] = 8'd12;
                4'd7: snack[4] = 8'd14;
                4'd8: snack[4] = 8'd16;
                4'd9: snack[4] = 8'd18;
                4'd10: snack[4] = 8'd20;
                4'd11: snack[4] = 8'd22;
                4'd12: snack[4] = 8'd24;
                4'd13: snack[4] = 8'd26;
                4'd14: snack[4] = 8'd28;
                4'd15: snack[4] = 8'd30;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd3: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd3;
                4'd2: snack[4] = 8'd6;
                4'd3: snack[4] = 8'd9;
                4'd4: snack[4] = 8'd12;
                4'd5: snack[4] = 8'd15;
                4'd6: snack[4] = 8'd18;
                4'd7: snack[4] = 8'd21;
                4'd8: snack[4] = 8'd24;
                4'd9: snack[4] = 8'd27;
                4'd10: snack[4] = 8'd30;
                4'd11: snack[4] = 8'd33;
                4'd12: snack[4] = 8'd36;
                4'd13: snack[4] = 8'd39;
                4'd14: snack[4] = 8'd42;
                4'd15: snack[4] = 8'd45;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd4: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd4;
                4'd2: snack[4] = 8'd8;
                4'd3: snack[4] = 8'd12;
                4'd4: snack[4] = 8'd16;
                4'd5: snack[4] = 8'd20;
                4'd6: snack[4] = 8'd24;
                4'd7: snack[4] = 8'd28;
                4'd8: snack[4] = 8'd32;
                4'd9: snack[4] = 8'd36;
                4'd10: snack[4] = 8'd40;
                4'd11: snack[4] = 8'd44;
                4'd12: snack[4] = 8'd48;
                4'd13: snack[4] = 8'd52;
                4'd14: snack[4] = 8'd56;
                4'd15: snack[4] = 8'd60;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd5: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd5;
                4'd2: snack[4] = 8'd10;
                4'd3: snack[4] = 8'd15;
                4'd4: snack[4] = 8'd20;
                4'd5: snack[4] = 8'd25;
                4'd6: snack[4] = 8'd30;
                4'd7: snack[4] = 8'd35;
                4'd8: snack[4] = 8'd40;
                4'd9: snack[4] = 8'd45;
                4'd10: snack[4] = 8'd50;
                4'd11: snack[4] = 8'd55;
                4'd12: snack[4] = 8'd60;
                4'd13: snack[4] = 8'd65;
                4'd14: snack[4] = 8'd70;
                4'd15: snack[4] = 8'd75;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd6: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd6;
                4'd2: snack[4] = 8'd12;
                4'd3: snack[4] = 8'd18;
                4'd4: snack[4] = 8'd24;
                4'd5: snack[4] = 8'd30;
                4'd6: snack[4] = 8'd36;
                4'd7: snack[4] = 8'd42;
                4'd8: snack[4] = 8'd48;
                4'd9: snack[4] = 8'd54;
                4'd10: snack[4] = 8'd60;
                4'd11: snack[4] = 8'd66;
                4'd12: snack[4] = 8'd72;
                4'd13: snack[4] = 8'd78;
                4'd14: snack[4] = 8'd84;
                4'd15: snack[4] = 8'd90;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd7: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd7;
                4'd2: snack[4] = 8'd14;
                4'd3: snack[4] = 8'd21;
                4'd4: snack[4] = 8'd28;
                4'd5: snack[4] = 8'd35;
                4'd6: snack[4] = 8'd42;
                4'd7: snack[4] = 8'd49;
                4'd8: snack[4] = 8'd56;
                4'd9: snack[4] = 8'd63;
                4'd10: snack[4] = 8'd70;
                4'd11: snack[4] = 8'd77;
                4'd12: snack[4] = 8'd84;
                4'd13: snack[4] = 8'd91;
                4'd14: snack[4] = 8'd98;
                4'd15: snack[4] = 8'd105;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd8: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd8;
                4'd2: snack[4] = 8'd16;
                4'd3: snack[4] = 8'd24;
                4'd4: snack[4] = 8'd32;
                4'd5: snack[4] = 8'd40;
                4'd6: snack[4] = 8'd48;
                4'd7: snack[4] = 8'd56;
                4'd8: snack[4] = 8'd64;
                4'd9: snack[4] = 8'd72;
                4'd10: snack[4] = 8'd80;
                4'd11: snack[4] = 8'd88;
                4'd12: snack[4] = 8'd96;
                4'd13: snack[4] = 8'd104;
                4'd14: snack[4] = 8'd112;
                4'd15: snack[4] = 8'd120;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd9: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd9;
                4'd2: snack[4] = 8'd18;
                4'd3: snack[4] = 8'd27;
                4'd4: snack[4] = 8'd36;
                4'd5: snack[4] = 8'd45;
                4'd6: snack[4] = 8'd54;
                4'd7: snack[4] = 8'd63;
                4'd8: snack[4] = 8'd72;
                4'd9: snack[4] = 8'd81;
                4'd10: snack[4] = 8'd90;
                4'd11: snack[4] = 8'd99;
                4'd12: snack[4] = 8'd108;
                4'd13: snack[4] = 8'd117;
                4'd14: snack[4] = 8'd126;
                4'd15: snack[4] = 8'd135;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd10: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd10;
                4'd2: snack[4] = 8'd20;
                4'd3: snack[4] = 8'd30;
                4'd4: snack[4] = 8'd40;
                4'd5: snack[4] = 8'd50;
                4'd6: snack[4] = 8'd60;
                4'd7: snack[4] = 8'd70;
                4'd8: snack[4] = 8'd80;
                4'd9: snack[4] = 8'd90;
                4'd10: snack[4] = 8'd100;
                4'd11: snack[4] = 8'd110;
                4'd12: snack[4] = 8'd120;
                4'd13: snack[4] = 8'd130;
                4'd14: snack[4] = 8'd140;
                4'd15: snack[4] = 8'd150;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd11: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd11;
                4'd2: snack[4] = 8'd22;
                4'd3: snack[4] = 8'd33;
                4'd4: snack[4] = 8'd44;
                4'd5: snack[4] = 8'd55;
                4'd6: snack[4] = 8'd66;
                4'd7: snack[4] = 8'd77;
                4'd8: snack[4] = 8'd88;
                4'd9: snack[4] = 8'd99;
                4'd10: snack[4] = 8'd110;
                4'd11: snack[4] = 8'd121;
                4'd12: snack[4] = 8'd132;
                4'd13: snack[4] = 8'd143;
                4'd14: snack[4] = 8'd154;
                4'd15: snack[4] = 8'd165;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd12: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd12;
                4'd2: snack[4] = 8'd24;
                4'd3: snack[4] = 8'd36;
                4'd4: snack[4] = 8'd48;
                4'd5: snack[4] = 8'd60;
                4'd6: snack[4] = 8'd72;
                4'd7: snack[4] = 8'd84;
                4'd8: snack[4] = 8'd96;
                4'd9: snack[4] = 8'd108;
                4'd10: snack[4] = 8'd120;
                4'd11: snack[4] = 8'd132;
                4'd12: snack[4] = 8'd144;
                4'd13: snack[4] = 8'd156;
                4'd14: snack[4] = 8'd168;
                4'd15: snack[4] = 8'd180;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd13: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd13;
                4'd2: snack[4] = 8'd26;
                4'd3: snack[4] = 8'd39;
                4'd4: snack[4] = 8'd52;
                4'd5: snack[4] = 8'd65;
                4'd6: snack[4] = 8'd78;
                4'd7: snack[4] = 8'd91;
                4'd8: snack[4] = 8'd104;
                4'd9: snack[4] = 8'd117;
                4'd10: snack[4] = 8'd130;
                4'd11: snack[4] = 8'd143;
                4'd12: snack[4] = 8'd156;
                4'd13: snack[4] = 8'd169;
                4'd14: snack[4] = 8'd182;
                4'd15: snack[4] = 8'd195;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd14: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd14;
                4'd2: snack[4] = 8'd28;
                4'd3: snack[4] = 8'd42;
                4'd4: snack[4] = 8'd56;
                4'd5: snack[4] = 8'd70;
                4'd6: snack[4] = 8'd84;
                4'd7: snack[4] = 8'd98;
                4'd8: snack[4] = 8'd112;
                4'd9: snack[4] = 8'd126;
                4'd10: snack[4] = 8'd140;
                4'd11: snack[4] = 8'd154;
                4'd12: snack[4] = 8'd168;
                4'd13: snack[4] = 8'd182;
                4'd14: snack[4] = 8'd196;
                4'd15: snack[4] = 8'd210;
                default: snack[4] = 8'd0;
            endcase
        end
        4'd15: begin
            case (price[19:16])
                4'd1: snack[4] = 8'd15;
                4'd2: snack[4] = 8'd30;
                4'd3: snack[4] = 8'd45;
                4'd4: snack[4] = 8'd60;
                4'd5: snack[4] = 8'd75;
                4'd6: snack[4] = 8'd90;
                4'd7: snack[4] = 8'd105;
                4'd8: snack[4] = 8'd120;
                4'd9: snack[4] = 8'd135;
                4'd10: snack[4] = 8'd150;
                4'd11: snack[4] = 8'd165;
                4'd12: snack[4] = 8'd180;
                4'd13: snack[4] = 8'd195;
                4'd14: snack[4] = 8'd210;
                4'd15: snack[4] = 8'd225;
                default: snack[4] = 8'd0;
            endcase
        end
        default: snack[4] = 8'd0;
    endcase
end

always @(*) begin
    case (snack_num[15:12])
        4'd1: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd1;
                4'd2: snack[3] = 8'd2;
                4'd3: snack[3] = 8'd3;
                4'd4: snack[3] = 8'd4;
                4'd5: snack[3] = 8'd5;
                4'd6: snack[3] = 8'd6;
                4'd7: snack[3] = 8'd7;
                4'd8: snack[3] = 8'd8;
                4'd9: snack[3] = 8'd9;
                4'd10: snack[3] = 8'd10;
                4'd11: snack[3] = 8'd11;
                4'd12: snack[3] = 8'd12;
                4'd13: snack[3] = 8'd13;
                4'd14: snack[3] = 8'd14;
                4'd15: snack[3] = 8'd15;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd2: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd2;
                4'd2: snack[3] = 8'd4;
                4'd3: snack[3] = 8'd6;
                4'd4: snack[3] = 8'd8;
                4'd5: snack[3] = 8'd10;
                4'd6: snack[3] = 8'd12;
                4'd7: snack[3] = 8'd14;
                4'd8: snack[3] = 8'd16;
                4'd9: snack[3] = 8'd18;
                4'd10: snack[3] = 8'd20;
                4'd11: snack[3] = 8'd22;
                4'd12: snack[3] = 8'd24;
                4'd13: snack[3] = 8'd26;
                4'd14: snack[3] = 8'd28;
                4'd15: snack[3] = 8'd30;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd3: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd3;
                4'd2: snack[3] = 8'd6;
                4'd3: snack[3] = 8'd9;
                4'd4: snack[3] = 8'd12;
                4'd5: snack[3] = 8'd15;
                4'd6: snack[3] = 8'd18;
                4'd7: snack[3] = 8'd21;
                4'd8: snack[3] = 8'd24;
                4'd9: snack[3] = 8'd27;
                4'd10: snack[3] = 8'd30;
                4'd11: snack[3] = 8'd33;
                4'd12: snack[3] = 8'd36;
                4'd13: snack[3] = 8'd39;
                4'd14: snack[3] = 8'd42;
                4'd15: snack[3] = 8'd45;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd4: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd4;
                4'd2: snack[3] = 8'd8;
                4'd3: snack[3] = 8'd12;
                4'd4: snack[3] = 8'd16;
                4'd5: snack[3] = 8'd20;
                4'd6: snack[3] = 8'd24;
                4'd7: snack[3] = 8'd28;
                4'd8: snack[3] = 8'd32;
                4'd9: snack[3] = 8'd36;
                4'd10: snack[3] = 8'd40;
                4'd11: snack[3] = 8'd44;
                4'd12: snack[3] = 8'd48;
                4'd13: snack[3] = 8'd52;
                4'd14: snack[3] = 8'd56;
                4'd15: snack[3] = 8'd60;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd5: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd5;
                4'd2: snack[3] = 8'd10;
                4'd3: snack[3] = 8'd15;
                4'd4: snack[3] = 8'd20;
                4'd5: snack[3] = 8'd25;
                4'd6: snack[3] = 8'd30;
                4'd7: snack[3] = 8'd35;
                4'd8: snack[3] = 8'd40;
                4'd9: snack[3] = 8'd45;
                4'd10: snack[3] = 8'd50;
                4'd11: snack[3] = 8'd55;
                4'd12: snack[3] = 8'd60;
                4'd13: snack[3] = 8'd65;
                4'd14: snack[3] = 8'd70;
                4'd15: snack[3] = 8'd75;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd6: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd6;
                4'd2: snack[3] = 8'd12;
                4'd3: snack[3] = 8'd18;
                4'd4: snack[3] = 8'd24;
                4'd5: snack[3] = 8'd30;
                4'd6: snack[3] = 8'd36;
                4'd7: snack[3] = 8'd42;
                4'd8: snack[3] = 8'd48;
                4'd9: snack[3] = 8'd54;
                4'd10: snack[3] = 8'd60;
                4'd11: snack[3] = 8'd66;
                4'd12: snack[3] = 8'd72;
                4'd13: snack[3] = 8'd78;
                4'd14: snack[3] = 8'd84;
                4'd15: snack[3] = 8'd90;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd7: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd7;
                4'd2: snack[3] = 8'd14;
                4'd3: snack[3] = 8'd21;
                4'd4: snack[3] = 8'd28;
                4'd5: snack[3] = 8'd35;
                4'd6: snack[3] = 8'd42;
                4'd7: snack[3] = 8'd49;
                4'd8: snack[3] = 8'd56;
                4'd9: snack[3] = 8'd63;
                4'd10: snack[3] = 8'd70;
                4'd11: snack[3] = 8'd77;
                4'd12: snack[3] = 8'd84;
                4'd13: snack[3] = 8'd91;
                4'd14: snack[3] = 8'd98;
                4'd15: snack[3] = 8'd105;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd8: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd8;
                4'd2: snack[3] = 8'd16;
                4'd3: snack[3] = 8'd24;
                4'd4: snack[3] = 8'd32;
                4'd5: snack[3] = 8'd40;
                4'd6: snack[3] = 8'd48;
                4'd7: snack[3] = 8'd56;
                4'd8: snack[3] = 8'd64;
                4'd9: snack[3] = 8'd72;
                4'd10: snack[3] = 8'd80;
                4'd11: snack[3] = 8'd88;
                4'd12: snack[3] = 8'd96;
                4'd13: snack[3] = 8'd104;
                4'd14: snack[3] = 8'd112;
                4'd15: snack[3] = 8'd120;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd9: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd9;
                4'd2: snack[3] = 8'd18;
                4'd3: snack[3] = 8'd27;
                4'd4: snack[3] = 8'd36;
                4'd5: snack[3] = 8'd45;
                4'd6: snack[3] = 8'd54;
                4'd7: snack[3] = 8'd63;
                4'd8: snack[3] = 8'd72;
                4'd9: snack[3] = 8'd81;
                4'd10: snack[3] = 8'd90;
                4'd11: snack[3] = 8'd99;
                4'd12: snack[3] = 8'd108;
                4'd13: snack[3] = 8'd117;
                4'd14: snack[3] = 8'd126;
                4'd15: snack[3] = 8'd135;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd10: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd10;
                4'd2: snack[3] = 8'd20;
                4'd3: snack[3] = 8'd30;
                4'd4: snack[3] = 8'd40;
                4'd5: snack[3] = 8'd50;
                4'd6: snack[3] = 8'd60;
                4'd7: snack[3] = 8'd70;
                4'd8: snack[3] = 8'd80;
                4'd9: snack[3] = 8'd90;
                4'd10: snack[3] = 8'd100;
                4'd11: snack[3] = 8'd110;
                4'd12: snack[3] = 8'd120;
                4'd13: snack[3] = 8'd130;
                4'd14: snack[3] = 8'd140;
                4'd15: snack[3] = 8'd150;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd11: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd11;
                4'd2: snack[3] = 8'd22;
                4'd3: snack[3] = 8'd33;
                4'd4: snack[3] = 8'd44;
                4'd5: snack[3] = 8'd55;
                4'd6: snack[3] = 8'd66;
                4'd7: snack[3] = 8'd77;
                4'd8: snack[3] = 8'd88;
                4'd9: snack[3] = 8'd99;
                4'd10: snack[3] = 8'd110;
                4'd11: snack[3] = 8'd121;
                4'd12: snack[3] = 8'd132;
                4'd13: snack[3] = 8'd143;
                4'd14: snack[3] = 8'd154;
                4'd15: snack[3] = 8'd165;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd12: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd12;
                4'd2: snack[3] = 8'd24;
                4'd3: snack[3] = 8'd36;
                4'd4: snack[3] = 8'd48;
                4'd5: snack[3] = 8'd60;
                4'd6: snack[3] = 8'd72;
                4'd7: snack[3] = 8'd84;
                4'd8: snack[3] = 8'd96;
                4'd9: snack[3] = 8'd108;
                4'd10: snack[3] = 8'd120;
                4'd11: snack[3] = 8'd132;
                4'd12: snack[3] = 8'd144;
                4'd13: snack[3] = 8'd156;
                4'd14: snack[3] = 8'd168;
                4'd15: snack[3] = 8'd180;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd13: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd13;
                4'd2: snack[3] = 8'd26;
                4'd3: snack[3] = 8'd39;
                4'd4: snack[3] = 8'd52;
                4'd5: snack[3] = 8'd65;
                4'd6: snack[3] = 8'd78;
                4'd7: snack[3] = 8'd91;
                4'd8: snack[3] = 8'd104;
                4'd9: snack[3] = 8'd117;
                4'd10: snack[3] = 8'd130;
                4'd11: snack[3] = 8'd143;
                4'd12: snack[3] = 8'd156;
                4'd13: snack[3] = 8'd169;
                4'd14: snack[3] = 8'd182;
                4'd15: snack[3] = 8'd195;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd14: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd14;
                4'd2: snack[3] = 8'd28;
                4'd3: snack[3] = 8'd42;
                4'd4: snack[3] = 8'd56;
                4'd5: snack[3] = 8'd70;
                4'd6: snack[3] = 8'd84;
                4'd7: snack[3] = 8'd98;
                4'd8: snack[3] = 8'd112;
                4'd9: snack[3] = 8'd126;
                4'd10: snack[3] = 8'd140;
                4'd11: snack[3] = 8'd154;
                4'd12: snack[3] = 8'd168;
                4'd13: snack[3] = 8'd182;
                4'd14: snack[3] = 8'd196;
                4'd15: snack[3] = 8'd210;
                default: snack[3] = 8'd0;
            endcase
        end
        4'd15: begin
            case (price[15:12])
                4'd1: snack[3] = 8'd15;
                4'd2: snack[3] = 8'd30;
                4'd3: snack[3] = 8'd45;
                4'd4: snack[3] = 8'd60;
                4'd5: snack[3] = 8'd75;
                4'd6: snack[3] = 8'd90;
                4'd7: snack[3] = 8'd105;
                4'd8: snack[3] = 8'd120;
                 4'd9: snack[3] = 8'd135;
                4'd10: snack[3] = 8'd150;
                4'd11: snack[3] = 8'd165;
                4'd12: snack[3] = 8'd180;
                4'd13: snack[3] = 8'd195;
                4'd14: snack[3] = 8'd210;
                4'd15: snack[3] = 8'd225;
                default: snack[3] = 8'd0;
            endcase
        end
        default: snack[3] = 8'd0;
    endcase
end

always @(*) begin
    case (snack_num[11:8])
        4'd1: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd1;
                4'd2: snack[2] = 8'd2;
                4'd3: snack[2] = 8'd3;
                4'd4: snack[2] = 8'd4;
                4'd5: snack[2] = 8'd5;
                4'd6: snack[2] = 8'd6;
                4'd7: snack[2] = 8'd7;
                4'd8: snack[2] = 8'd8;
                4'd9: snack[2] = 8'd9;
                4'd10: snack[2] = 8'd10;
                4'd11: snack[2] = 8'd11;
                4'd12: snack[2] = 8'd12;
                4'd13: snack[2] = 8'd13;
                4'd14: snack[2] = 8'd14;
                4'd15: snack[2] = 8'd15;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd2: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd2;
                4'd2: snack[2] = 8'd4;
                4'd3: snack[2] = 8'd6;
                4'd4: snack[2] = 8'd8;
                4'd5: snack[2] = 8'd10;
                4'd6: snack[2] = 8'd12;
                4'd7: snack[2] = 8'd14;
                4'd8: snack[2] = 8'd16;
                4'd9: snack[2] = 8'd18;
                4'd10: snack[2] = 8'd20;
                4'd11: snack[2] = 8'd22;
                4'd12: snack[2] = 8'd24;
                4'd13: snack[2] = 8'd26;
                4'd14: snack[2] = 8'd28;
                4'd15: snack[2] = 8'd30;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd3: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd3;
                4'd2: snack[2] = 8'd6;
                4'd3: snack[2] = 8'd9;
                4'd4: snack[2] = 8'd12;
                4'd5: snack[2] = 8'd15;
                4'd6: snack[2] = 8'd18;
                4'd7: snack[2] = 8'd21;
                4'd8: snack[2] = 8'd24;
                4'd9: snack[2] = 8'd27;
                4'd10: snack[2] = 8'd30;
                4'd11: snack[2] = 8'd33;
                4'd12: snack[2] = 8'd36;
                4'd13: snack[2] = 8'd39;
                4'd14: snack[2] = 8'd42;
                4'd15: snack[2] = 8'd45;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd4: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd4;
                4'd2: snack[2] = 8'd8;
                4'd3: snack[2] = 8'd12;
                4'd4: snack[2] = 8'd16;
                4'd5: snack[2] = 8'd20;
                4'd6: snack[2] = 8'd24;
                4'd7: snack[2] = 8'd28;
                4'd8: snack[2] = 8'd32;
                4'd9: snack[2] = 8'd36;
                4'd10: snack[2] = 8'd40;
                4'd11: snack[2] = 8'd44;
                4'd12: snack[2] = 8'd48;
                4'd13: snack[2] = 8'd52;
                4'd14: snack[2] = 8'd56;
                4'd15: snack[2] = 8'd60;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd5: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd5;
                4'd2: snack[2] = 8'd10;
                4'd3: snack[2] = 8'd15;
                4'd4: snack[2] = 8'd20;
                4'd5: snack[2] = 8'd25;
                4'd6: snack[2] = 8'd30;
                4'd7: snack[2] = 8'd35;
                4'd8: snack[2] = 8'd40;
                4'd9: snack[2] = 8'd45;
                4'd10: snack[2] = 8'd50;
                4'd11: snack[2] = 8'd55;
                4'd12: snack[2] = 8'd60;
                4'd13: snack[2] = 8'd65;
                4'd14: snack[2] = 8'd70;
                4'd15: snack[2] = 8'd75;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd6: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd6;
                4'd2: snack[2] = 8'd12;
                4'd3: snack[2] = 8'd18;
                4'd4: snack[2] = 8'd24;
                4'd5: snack[2] = 8'd30;
                4'd6: snack[2] = 8'd36;
                4'd7: snack[2] = 8'd42;
                4'd8: snack[2] = 8'd48;
                4'd9: snack[2] = 8'd54;
                4'd10: snack[2] = 8'd60;
                4'd11: snack[2] = 8'd66;
                4'd12: snack[2] = 8'd72;
                4'd13: snack[2] = 8'd78;
                4'd14: snack[2] = 8'd84;
                4'd15: snack[2] = 8'd90;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd7: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd7;
                4'd2: snack[2] = 8'd14;
                4'd3: snack[2] = 8'd21;
                4'd4: snack[2] = 8'd28;
                4'd5: snack[2] = 8'd35;
                4'd6: snack[2] = 8'd42;
                4'd7: snack[2] = 8'd49;
                4'd8: snack[2] = 8'd56;
                4'd9: snack[2] = 8'd63;
                4'd10: snack[2] = 8'd70;
                4'd11: snack[2] = 8'd77;
                4'd12: snack[2] = 8'd84;
                4'd13: snack[2] = 8'd91;
                4'd14: snack[2] = 8'd98;
                4'd15: snack[2] = 8'd105;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd8: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd8;
                4'd2: snack[2] = 8'd16;
                4'd3: snack[2] = 8'd24;
                4'd4: snack[2] = 8'd32;
                4'd5: snack[2] = 8'd40;
                4'd6: snack[2] = 8'd48;
                4'd7: snack[2] = 8'd56;
                4'd8: snack[2] = 8'd64;
                4'd9: snack[2] = 8'd72;
                4'd10: snack[2] = 8'd80;
                4'd11: snack[2] = 8'd88;
                4'd12: snack[2] = 8'd96;
                4'd13: snack[2] = 8'd104;
                4'd14: snack[2] = 8'd112;
                4'd15: snack[2] = 8'd120;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd9: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd9;
                4'd2: snack[2] = 8'd18;
                4'd3: snack[2] = 8'd27;
                4'd4: snack[2] = 8'd36;
                4'd5: snack[2] = 8'd45;
                4'd6: snack[2] = 8'd54;
                4'd7: snack[2] = 8'd63;
                4'd8: snack[2] = 8'd72;
                4'd9: snack[2] = 8'd81;
                4'd10: snack[2] = 8'd90;
                4'd11: snack[2] = 8'd99;
                4'd12: snack[2] = 8'd108;
                4'd13: snack[2] = 8'd117;
                4'd14: snack[2] = 8'd126;
                4'd15: snack[2] = 8'd135;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd10: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd10;
                4'd2: snack[2] = 8'd20;
                4'd3: snack[2] = 8'd30;
                4'd4: snack[2] = 8'd40;
                4'd5: snack[2] = 8'd50;
                4'd6: snack[2] = 8'd60;
                4'd7: snack[2] = 8'd70;
                4'd8: snack[2] = 8'd80;
                4'd9: snack[2] = 8'd90;
                4'd10: snack[2] = 8'd100;
                4'd11: snack[2] = 8'd110;
                4'd12: snack[2] = 8'd120;
                4'd13: snack[2] = 8'd130;
                4'd14: snack[2] = 8'd140;
                4'd15: snack[2] = 8'd150;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd11: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd11;
                4'd2: snack[2] = 8'd22;
                4'd3: snack[2] = 8'd33;
                4'd4: snack[2] = 8'd44;
                4'd5: snack[2] = 8'd55;
                4'd6: snack[2] = 8'd66;
                4'd7: snack[2] = 8'd77;
                4'd8: snack[2] = 8'd88;
                4'd9: snack[2] = 8'd99;
                4'd10: snack[2] = 8'd110;
                4'd11: snack[2] = 8'd121;
                4'd12: snack[2] = 8'd132;
                4'd13: snack[2] = 8'd143;
                4'd14: snack[2] = 8'd154;
                4'd15: snack[2] = 8'd165;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd12: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd12;
                4'd2: snack[2] = 8'd24;
                4'd3: snack[2] = 8'd36;
                4'd4: snack[2] = 8'd48;
                4'd5: snack[2] = 8'd60;
                4'd6: snack[2] = 8'd72;
                4'd7: snack[2] = 8'd84;
                4'd8: snack[2] = 8'd96;
                4'd9: snack[2] = 8'd108;
                4'd10: snack[2] = 8'd120;
                4'd11: snack[2] = 8'd132;
                4'd12: snack[2] = 8'd144;
                4'd13: snack[2] = 8'd156;
                4'd14: snack[2] = 8'd168;
                4'd15: snack[2] = 8'd180;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd13: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd13;
                4'd2: snack[2] = 8'd26;
                4'd3: snack[2] = 8'd39;
                4'd4: snack[2] = 8'd52;
                4'd5: snack[2] = 8'd65;
                4'd6: snack[2] = 8'd78;
                4'd7: snack[2] = 8'd91;
                4'd8: snack[2] = 8'd104;
                4'd9: snack[2] = 8'd117;
                4'd10: snack[2] = 8'd130;
                4'd11: snack[2] = 8'd143;
                4'd12: snack[2] = 8'd156;
                4'd13: snack[2] = 8'd169;
                4'd14: snack[2] = 8'd182;
                4'd15: snack[2] = 8'd195;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd14: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd14;
                4'd2: snack[2] = 8'd28;
                4'd3: snack[2] = 8'd42;
                4'd4: snack[2] = 8'd56;
                4'd5: snack[2] = 8'd70;
                4'd6: snack[2] = 8'd84;
                4'd7: snack[2] = 8'd98;
                4'd8: snack[2] = 8'd112;
                4'd9: snack[2] = 8'd126;
                4'd10: snack[2] = 8'd140;
                4'd11: snack[2] = 8'd154;
                4'd12: snack[2] = 8'd168;
                4'd13: snack[2] = 8'd182;
                4'd14: snack[2] = 8'd196;
                4'd15: snack[2] = 8'd210;
                default: snack[2] = 8'd0;
            endcase
        end
        4'd15: begin
            case (price[11:8])
                4'd1: snack[2] = 8'd15;
                4'd2: snack[2] = 8'd30;
                4'd3: snack[2] = 8'd45;
                4'd4: snack[2] = 8'd60;
                4'd5: snack[2] = 8'd75;
                4'd6: snack[2] = 8'd90;
                4'd7: snack[2] = 8'd105;
                4'd8: snack[2] = 8'd120;
                 4'd9: snack[2] = 8'd135;
                4'd10: snack[2] = 8'd150;
                4'd11: snack[2] = 8'd165;
                4'd12: snack[2] = 8'd180;
                4'd13: snack[2] = 8'd195;
                4'd14: snack[2] = 8'd210;
                4'd15: snack[2] = 8'd225;
                default: snack[2] = 8'd0;
            endcase
        end
        default: snack[2] = 8'd0;
    endcase
end

always @(*) begin
    case (snack_num[7:4])
        4'd1: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd1;
                4'd2: snack[1] = 8'd2;
                4'd3: snack[1] = 8'd3;
                4'd4: snack[1] = 8'd4;
                4'd5: snack[1] = 8'd5;
                4'd6: snack[1] = 8'd6;
                4'd7: snack[1] = 8'd7;
                4'd8: snack[1] = 8'd8;
                4'd9: snack[1] = 8'd9;
                4'd10: snack[1] = 8'd10;
                4'd11: snack[1] = 8'd11;
                4'd12: snack[1] = 8'd12;
                4'd13: snack[1] = 8'd13;
                4'd14: snack[1] = 8'd14;
                4'd15: snack[1] = 8'd15;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd2: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd2;
                4'd2: snack[1] = 8'd4;
                4'd3: snack[1] = 8'd6;
                4'd4: snack[1] = 8'd8;
                4'd5: snack[1] = 8'd10;
                4'd6: snack[1] = 8'd12;
                4'd7: snack[1] = 8'd14;
                4'd8: snack[1] = 8'd16;
                4'd9: snack[1] = 8'd18;
                4'd10: snack[1] = 8'd20;
                4'd11: snack[1] = 8'd22;
                4'd12: snack[1] = 8'd24;
                4'd13: snack[1] = 8'd26;
                4'd14: snack[1] = 8'd28;
                4'd15: snack[1] = 8'd30;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd3: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd3;
                4'd2: snack[1] = 8'd6;
                4'd3: snack[1] = 8'd9;
                4'd4: snack[1] = 8'd12;
                4'd5: snack[1] = 8'd15;
                4'd6: snack[1] = 8'd18;
                4'd7: snack[1] = 8'd21;
                4'd8: snack[1] = 8'd24;
                4'd9: snack[1] = 8'd27;
                4'd10: snack[1] = 8'd30;
                4'd11: snack[1] = 8'd33;
                4'd12: snack[1] = 8'd36;
                4'd13: snack[1] = 8'd39;
                4'd14: snack[1] = 8'd42;
                4'd15: snack[1] = 8'd45;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd4: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd4;
                4'd2: snack[1] = 8'd8;
                4'd3: snack[1] = 8'd12;
                4'd4: snack[1] = 8'd16;
                4'd5: snack[1] = 8'd20;
                4'd6: snack[1] = 8'd24;
                4'd7: snack[1] = 8'd28;
                4'd8: snack[1] = 8'd32;
                4'd9: snack[1] = 8'd36;
                4'd10: snack[1] = 8'd40;
                4'd11: snack[1] = 8'd44;
                4'd12: snack[1] = 8'd48;
                4'd13: snack[1] = 8'd52;
                4'd14: snack[1] = 8'd56;
                4'd15: snack[1] = 8'd60;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd5: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd5;
                4'd2: snack[1] = 8'd10;
                4'd3: snack[1] = 8'd15;
                4'd4: snack[1] = 8'd20;
                4'd5: snack[1] = 8'd25;
                4'd6: snack[1] = 8'd30;
                4'd7: snack[1] = 8'd35;
                4'd8: snack[1] = 8'd40;
                4'd9: snack[1] = 8'd45;
                4'd10: snack[1] = 8'd50;
                4'd11: snack[1] = 8'd55;
                4'd12: snack[1] = 8'd60;
                4'd13: snack[1] = 8'd65;
                4'd14: snack[1] = 8'd70;
                4'd15: snack[1] = 8'd75;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd6: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd6;
                4'd2: snack[1] = 8'd12;
                4'd3: snack[1] = 8'd18;
                4'd4: snack[1] = 8'd24;
                4'd5: snack[1] = 8'd30;
                4'd6: snack[1] = 8'd36;
                4'd7: snack[1] = 8'd42;
                4'd8: snack[1] = 8'd48;
                4'd9: snack[1] = 8'd54;
                4'd10: snack[1] = 8'd60;
                4'd11: snack[1] = 8'd66;
                4'd12: snack[1] = 8'd72;
                4'd13: snack[1] = 8'd78;
                4'd14: snack[1] = 8'd84;
                4'd15: snack[1] = 8'd90;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd7: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd7;
                4'd2: snack[1] = 8'd14;
                4'd3: snack[1] = 8'd21;
                4'd4: snack[1] = 8'd28;
                4'd5: snack[1] = 8'd35;
                4'd6: snack[1] = 8'd42;
                4'd7: snack[1] = 8'd49;
                4'd8: snack[1] = 8'd56;
                4'd9: snack[1] = 8'd63;
                4'd10: snack[1] = 8'd70;
                4'd11: snack[1] = 8'd77;
                4'd12: snack[1] = 8'd84;
                4'd13: snack[1] = 8'd91;
                4'd14: snack[1] = 8'd98;
                4'd15: snack[1] = 8'd105;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd8: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd8;
                4'd2: snack[1] = 8'd16;
                4'd3: snack[1] = 8'd24;
                4'd4: snack[1] = 8'd32;
                4'd5: snack[1] = 8'd40;
                4'd6: snack[1] = 8'd48;
                4'd7: snack[1] = 8'd56;
                4'd8: snack[1] = 8'd64;
                4'd9: snack[1] = 8'd72;
                4'd10: snack[1] = 8'd80;
                4'd11: snack[1] = 8'd88;
                4'd12: snack[1] = 8'd96;
                4'd13: snack[1] = 8'd104;
                4'd14: snack[1] = 8'd112;
                4'd15: snack[1] = 8'd120;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd9: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd9;
                4'd2: snack[1] = 8'd18;
                4'd3: snack[1] = 8'd27;
                4'd4: snack[1] = 8'd36;
                4'd5: snack[1] = 8'd45;
                4'd6: snack[1] = 8'd54;
                4'd7: snack[1] = 8'd63;
                4'd8: snack[1] = 8'd72;
                4'd9: snack[1] = 8'd81;
                4'd10: snack[1] = 8'd90;
                4'd11: snack[1] = 8'd99;
                4'd12: snack[1] = 8'd108;
                4'd13: snack[1] = 8'd117;
                4'd14: snack[1] = 8'd126;
                4'd15: snack[1] = 8'd135;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd10: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd10;
                4'd2: snack[1] = 8'd20;
                4'd3: snack[1] = 8'd30;
                4'd4: snack[1] = 8'd40;
                4'd5: snack[1] = 8'd50;
                4'd6: snack[1] = 8'd60;
                4'd7: snack[1] = 8'd70;
                4'd8: snack[1] = 8'd80;
                4'd9: snack[1] = 8'd90;
                4'd10: snack[1] = 8'd100;
                4'd11: snack[1] = 8'd110;
                4'd12: snack[1] = 8'd120;
                4'd13: snack[1] = 8'd130;
                4'd14: snack[1] = 8'd140;
                4'd15: snack[1] = 8'd150;
                default: snack[1] = 8'd0;
            endcase
        end
                4'd11: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd11;
                4'd2: snack[1] = 8'd22;
                4'd3: snack[1] = 8'd33;
                4'd4: snack[1] = 8'd44;
                4'd5: snack[1] = 8'd55;
                4'd6: snack[1] = 8'd66;
                4'd7: snack[1] = 8'd77;
                4'd8: snack[1] = 8'd88;
                4'd9: snack[1] = 8'd99;
                4'd10: snack[1] = 8'd110;
                4'd11: snack[1] = 8'd121;
                4'd12: snack[1] = 8'd132;
                4'd13: snack[1] = 8'd143;
                4'd14: snack[1] = 8'd154;
                4'd15: snack[1] = 8'd165;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd12: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd12;
                4'd2: snack[1] = 8'd24;
                4'd3: snack[1] = 8'd36;
                4'd4: snack[1] = 8'd48;
                4'd5: snack[1] = 8'd60;
                4'd6: snack[1] = 8'd72;
                4'd7: snack[1] = 8'd84;
                4'd8: snack[1] = 8'd96;
                4'd9: snack[1] = 8'd108;
                4'd10: snack[1] = 8'd120;
                4'd11: snack[1] = 8'd132;
                4'd12: snack[1] = 8'd144;
                4'd13: snack[1] = 8'd156;
                4'd14: snack[1] = 8'd168;
                4'd15: snack[1] = 8'd180;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd13: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd13;
                4'd2: snack[1] = 8'd26;
                4'd3: snack[1] = 8'd39;
                4'd4: snack[1] = 8'd52;
                4'd5: snack[1] = 8'd65;
                4'd6: snack[1] = 8'd78;
                4'd7: snack[1] = 8'd91;
                4'd8: snack[1] = 8'd104;
                4'd9: snack[1] = 8'd117;
                4'd10: snack[1] = 8'd130;
                4'd11: snack[1] = 8'd143;
                4'd12: snack[1] = 8'd156;
                4'd13: snack[1] = 8'd169;
                4'd14: snack[1] = 8'd182;
                4'd15: snack[1] = 8'd195;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd14: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd14;
                4'd2: snack[1] = 8'd28;
                4'd3: snack[1] = 8'd42;
                4'd4: snack[1] = 8'd56;
                4'd5: snack[1] = 8'd70;
                4'd6: snack[1] = 8'd84;
                4'd7: snack[1] = 8'd98;
                4'd8: snack[1] = 8'd112;
                4'd9: snack[1] = 8'd126;
                4'd10: snack[1] = 8'd140;
                4'd11: snack[1] = 8'd154;
                4'd12: snack[1] = 8'd168;
                4'd13: snack[1] = 8'd182;
                4'd14: snack[1] = 8'd196;
                4'd15: snack[1] = 8'd210;
                default: snack[1] = 8'd0;
            endcase
        end
        4'd15: begin
            case (price[7:4])
                4'd1: snack[1] = 8'd15;
                4'd2: snack[1] = 8'd30;
                4'd3: snack[1] = 8'd45;
                4'd4: snack[1] = 8'd60;
                4'd5: snack[1] = 8'd75;
                4'd6: snack[1] = 8'd90;
                4'd7: snack[1] = 8'd105;
                4'd8: snack[1] = 8'd120;
                4'd9: snack[1] = 8'd135;
                4'd10: snack[1] = 8'd150;
                4'd11: snack[1] = 8'd165;
                4'd12: snack[1] = 8'd180;
                4'd13: snack[1] = 8'd195;
                4'd14: snack[1] = 8'd210;
                4'd15: snack[1] = 8'd225;
                default: snack[1] = 8'd0;
            endcase
        end

        // Add more cases as needed
        default: snack[1] = 8'd0;
    endcase
end


always @(*) begin
    case (snack_num[3:0])
        4'd1: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd1;
                4'd2: snack[0] = 8'd2;
                4'd3: snack[0] = 8'd3;
                4'd4: snack[0] = 8'd4;
                4'd5: snack[0] = 8'd5;
                4'd6: snack[0] = 8'd6;
                4'd7: snack[0] = 8'd7;
                4'd8: snack[0] = 8'd8;
                4'd9: snack[0] = 8'd9;
                4'd10: snack[0] = 8'd10;
                4'd11: snack[0] = 8'd11;
                4'd12: snack[0] = 8'd12;
                4'd13: snack[0] = 8'd13;
                4'd14: snack[0] = 8'd14;
                4'd15: snack[0] = 8'd15;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd2: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd2;
                4'd2: snack[0] = 8'd4;
                4'd3: snack[0] = 8'd6;
                4'd4: snack[0] = 8'd8;
                4'd5: snack[0] = 8'd10;
                4'd6: snack[0] = 8'd12;
                4'd7: snack[0] = 8'd14;
                4'd8: snack[0] = 8'd16;
                4'd9: snack[0] = 8'd18;
                4'd10: snack[0] = 8'd20;
                4'd11: snack[0] = 8'd22;
                4'd12: snack[0] = 8'd24;
                4'd13: snack[0] = 8'd26;
                4'd14: snack[0] = 8'd28;
                4'd15: snack[0] = 8'd30;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd3: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd3;
                4'd2: snack[0] = 8'd6;
                4'd3: snack[0] = 8'd9;
                4'd4: snack[0] = 8'd12;
                4'd5: snack[0] = 8'd15;
                4'd6: snack[0] = 8'd18;
                4'd7: snack[0] = 8'd21;
                4'd8: snack[0] = 8'd24;
                4'd9: snack[0] = 8'd27;
                4'd10: snack[0] = 8'd30;
                4'd11: snack[0] = 8'd33;
                4'd12: snack[0] = 8'd36;
                4'd13: snack[0] = 8'd39;
                4'd14: snack[0] = 8'd42;
                4'd15: snack[0] = 8'd45;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd4: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd4;
                4'd2: snack[0] = 8'd8;
                4'd3: snack[0] = 8'd12;
                4'd4: snack[0] = 8'd16;
                4'd5: snack[0] = 8'd20;
                4'd6: snack[0] = 8'd24;
                4'd7: snack[0] = 8'd28;
                4'd8: snack[0] = 8'd32;
                4'd9: snack[0] = 8'd36;
                4'd10: snack[0] = 8'd40;
                4'd11: snack[0] = 8'd44;
                4'd12: snack[0] = 8'd48;
                4'd13: snack[0] = 8'd52;
                4'd14: snack[0] = 8'd56;
                4'd15: snack[0] = 8'd60;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd5: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd5;
                4'd2: snack[0] = 8'd10;
                4'd3: snack[0] = 8'd15;
                4'd4: snack[0] = 8'd20;
                4'd5: snack[0] = 8'd25;
                4'd6: snack[0] = 8'd30;
                4'd7: snack[0] = 8'd35;
                4'd8: snack[0] = 8'd40;
                4'd9: snack[0] = 8'd45;
                4'd10: snack[0] = 8'd50;
                4'd11: snack[0] = 8'd55;
                4'd12: snack[0] = 8'd60;
                4'd13: snack[0] = 8'd65;
                4'd14: snack[0] = 8'd70;
                4'd15: snack[0] = 8'd75;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd6: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd6;
                4'd2: snack[0] = 8'd12;
                4'd3: snack[0] = 8'd18;
                4'd4: snack[0] = 8'd24;
                4'd5: snack[0] = 8'd30;
                4'd6: snack[0] = 8'd36;
                4'd7: snack[0] = 8'd42;
                4'd8: snack[0] = 8'd48;
                4'd9: snack[0] = 8'd54;
                4'd10: snack[0] = 8'd60;
                4'd11: snack[0] = 8'd66;
                4'd12: snack[0] = 8'd72;
                4'd13: snack[0] = 8'd78;
                4'd14: snack[0] = 8'd84;
                4'd15: snack[0] = 8'd90;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd7: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd7;
                4'd2: snack[0] = 8'd14;
                4'd3: snack[0] = 8'd21;
                4'd4: snack[0] = 8'd28;
                4'd5: snack[0] = 8'd35;
                4'd6: snack[0] = 8'd42;
                4'd7: snack[0] = 8'd49;
                4'd8: snack[0] = 8'd56;
                4'd9: snack[0] = 8'd63;
                4'd10: snack[0] = 8'd70;
                4'd11: snack[0] = 8'd77;
                4'd12: snack[0] = 8'd84;
                4'd13: snack[0] = 8'd91;
                4'd14: snack[0] = 8'd98;
                4'd15: snack[0] = 8'd105;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd8: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd8;
                4'd2: snack[0] = 8'd16;
                4'd3: snack[0] = 8'd24;
                4'd4: snack[0] = 8'd32;
                4'd5: snack[0] = 8'd40;
                4'd6: snack[0] = 8'd48;
                4'd7: snack[0] = 8'd56;
                4'd8: snack[0] = 8'd64;
                4'd9: snack[0] = 8'd72;
                4'd10: snack[0] = 8'd80;
                4'd11: snack[0] = 8'd88;
                4'd12: snack[0] = 8'd96;
                4'd13: snack[0] = 8'd104;
                4'd14: snack[0] = 8'd112;
                4'd15: snack[0] = 8'd120;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd9: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd9;
                4'd2: snack[0] = 8'd18;
                4'd3: snack[0] = 8'd27;
                4'd4: snack[0] = 8'd36;
                4'd5: snack[0] = 8'd45;
                4'd6: snack[0] = 8'd54;
                4'd7: snack[0] = 8'd63;
                4'd8: snack[0] = 8'd72;
                4'd9: snack[0] = 8'd81;
                4'd10: snack[0] = 8'd90;
                4'd11: snack[0] = 8'd99;
                4'd12: snack[0] = 8'd108;
                4'd13: snack[0] = 8'd117;
                4'd14: snack[0] = 8'd126;
                4'd15: snack[0] = 8'd135;
                default: snack[0] = 8'd0;
            endcase
        end
                4'd10: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd10;
                4'd2: snack[0] = 8'd20;
                4'd3: snack[0] = 8'd30;
                4'd4: snack[0] = 8'd40;
                4'd5: snack[0] = 8'd50;
                4'd6: snack[0] = 8'd60;
                4'd7: snack[0] = 8'd70;
                4'd8: snack[0] = 8'd80;
                4'd9: snack[0] = 8'd90;
                4'd10: snack[0] = 8'd100;
                4'd11: snack[0] = 8'd110;
                4'd12: snack[0] = 8'd120;
                4'd13: snack[0] = 8'd130;
                4'd14: snack[0] = 8'd140;
                4'd15: snack[0] = 8'd150;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd11: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd11;
                4'd2: snack[0] = 8'd22;
                4'd3: snack[0] = 8'd33;
                4'd4: snack[0] = 8'd44;
                4'd5: snack[0] = 8'd55;
                4'd6: snack[0] = 8'd66;
                4'd7: snack[0] = 8'd77;
                4'd8: snack[0] = 8'd88;
                4'd9: snack[0] = 8'd99;
                4'd10: snack[0] = 8'd110;
                4'd11: snack[0] = 8'd121;
                4'd12: snack[0] = 8'd132;
                4'd13: snack[0] = 8'd143;
                4'd14: snack[0] = 8'd154;
                4'd15: snack[0] = 8'd165;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd12: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd12;
                4'd2: snack[0] = 8'd24;
                4'd3: snack[0] = 8'd36;
                4'd4: snack[0] = 8'd48;
                4'd5: snack[0] = 8'd60;
                4'd6: snack[0] = 8'd72;
                4'd7: snack[0] = 8'd84;
                4'd8: snack[0] = 8'd96;
                4'd9: snack[0] = 8'd108;
                4'd10: snack[0] = 8'd120;
                4'd11: snack[0] = 8'd132;
                4'd12: snack[0] = 8'd144;
                4'd13: snack[0] = 8'd156;
                4'd14: snack[0] = 8'd168;
                4'd15: snack[0] = 8'd180;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd13: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd13;
                4'd2: snack[0] = 8'd26;
                4'd3: snack[0] = 8'd39;
                4'd4: snack[0] = 8'd52;
                4'd5: snack[0] = 8'd65;
                4'd6: snack[0] = 8'd78;
                4'd7: snack[0] = 8'd91;
                4'd8: snack[0] = 8'd104;
                4'd9: snack[0] = 8'd117;
                4'd10: snack[0] = 8'd130;
                4'd11: snack[0] = 8'd143;
                4'd12: snack[0] = 8'd156;
                4'd13: snack[0] = 8'd169;
                4'd14: snack[0] = 8'd182;
                4'd15: snack[0] = 8'd195;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd14: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd14;
                4'd2: snack[0] = 8'd28;
                4'd3: snack[0] = 8'd42;
                4'd4: snack[0] = 8'd56;
                4'd5: snack[0] = 8'd70;
                4'd6: snack[0] = 8'd84;
                4'd7: snack[0] = 8'd98;
                4'd8: snack[0] = 8'd112;
                4'd9: snack[0] = 8'd126;
                4'd10: snack[0] = 8'd140;
                4'd11: snack[0] = 8'd154;
                4'd12: snack[0] = 8'd168;
                4'd13: snack[0] = 8'd182;
                4'd14: snack[0] = 8'd196;
                4'd15: snack[0] = 8'd210;
                default: snack[0] = 8'd0;
            endcase
        end
        4'd15: begin
            case (price[3:0])
                4'd1: snack[0] = 8'd15;
                4'd2: snack[0] = 8'd30;
                4'd3: snack[0] = 8'd45;
                4'd4: snack[0] = 8'd60;
                4'd5: snack[0] = 8'd75;
                4'd6: snack[0] = 8'd90;
                4'd7: snack[0] = 8'd105;
                4'd8: snack[0] = 8'd120;
                4'd9: snack[0] = 8'd135;
                4'd10: snack[0] = 8'd150;
                4'd11: snack[0] = 8'd165;
                4'd12: snack[0] = 8'd180;
                4'd13: snack[0] = 8'd195;
                4'd14: snack[0] = 8'd210;
                4'd15: snack[0] = 8'd225;
                default: snack[0] = 8'd0;
            endcase
        end
        default: snack[0] = 8'd0;
    endcase
end




//// sorting


assign ab_min = ( snack[7] < snack[6] )? snack[7] : snack[6];
assign ab_max = ( snack[7] < snack[6] )? snack[6] : snack[7];

assign cd_min = ( snack[5] < snack[4] )? snack[5] : snack[4];
assign cd_max = ( snack[5] < snack[4] )? snack[4] : snack[5];

assign a_sort_max = ( ab_max < cd_max )? cd_max : ab_max;
assign a_smaller_than_max = ( ab_max < cd_max )? ab_max : cd_max;

assign a_sort_min = ( ab_min < cd_min )? ab_min : cd_min;
assign a_bigger_than_min = ( ab_min < cd_min )? cd_min : ab_min;

assign a_sort_sec = ( a_smaller_than_max < a_bigger_than_min )? a_bigger_than_min : a_smaller_than_max;
assign a_sort_thd = ( a_smaller_than_max < a_bigger_than_min )? a_smaller_than_max : a_bigger_than_min;
//
assign ef_min = ( snack[3] < snack[2] )? snack[3] : snack[2];
assign ef_max = ( snack[3] < snack[2] )? snack[2] : snack[3];

assign gh_min = ( snack[1] < snack[0] )? snack[1] : snack[0];
assign gh_max = ( snack[1] < snack[0] )? snack[0] : snack[1];

assign b_sort_max = ( ef_max < gh_max )? gh_max : ef_max;
assign b_smaller_than_max = ( ef_max < gh_max )? ef_max : gh_max;

assign b_sort_min = ( ef_min < gh_min )? ef_min : gh_min;
assign b_bigger_than_min = ( ef_min < gh_min )? gh_min : ef_min;

assign b_sort_sec = ( b_smaller_than_max < b_bigger_than_min )? b_bigger_than_min : b_smaller_than_max;
assign b_sort_thd = ( b_smaller_than_max < b_bigger_than_min )? b_smaller_than_max : b_bigger_than_min;
//
assign max = ( a_sort_max < b_sort_max )? b_sort_max : a_sort_max;
assign c_smaller_than_max = ( a_sort_max < b_sort_max )? a_sort_max : b_sort_max;
assign c_sort_min = ( a_sort_sec < b_sort_sec )? a_sort_sec : b_sort_sec;
assign c_bigger_than_min = ( a_sort_sec < b_sort_sec )? b_sort_sec : a_sort_sec;
assign c_sort_thd = ( c_smaller_than_max < c_bigger_than_min)? c_smaller_than_max : c_bigger_than_min;
assign sec = ( c_smaller_than_max < c_bigger_than_min)? c_bigger_than_min : c_smaller_than_max;
//
assign min = ( a_sort_min < b_sort_min )? a_sort_min : b_sort_min;
assign d_bigger_than_min = ( a_sort_min < b_sort_min )? b_sort_min : a_sort_min;
assign d_sort_max = ( a_sort_thd < b_sort_thd)? b_sort_thd : a_sort_thd;
assign d_smaller_than_max = ( a_sort_thd < b_sort_thd)? a_sort_thd : b_sort_thd;
assign d_sort_sec = ( d_bigger_than_min < d_smaller_than_max )? d_smaller_than_max : d_bigger_than_min;
assign seventh = ( d_bigger_than_min < d_smaller_than_max )? d_bigger_than_min : d_smaller_than_max;
//
assign thd = ( c_sort_thd < d_sort_max )? d_sort_max : c_sort_thd;
assign e_smaller_than_max = ( c_sort_thd < d_sort_max )? c_sort_thd : d_sort_max;
assign sixth = ( c_sort_min < d_sort_sec )? c_sort_min : d_sort_sec;
assign e_bigger_than_min = ( c_sort_min < d_sort_sec )? d_sort_sec : c_sort_min;
assign forth = ( e_smaller_than_max < e_bigger_than_min )? e_bigger_than_min : e_smaller_than_max;
assign fifth = ( e_smaller_than_max < e_bigger_than_min )? e_smaller_than_max : e_bigger_than_min;
////



reg [8:0] out1, out2, out3, out4, out5, out6, out7, out8, out;


always @(*) begin
    if (input_money >= max) out1 = input_money - max;
    else out1 = input_money;
end
always @(*) begin
    if (out1 >= sec ) out2 = out1 - sec;
    else out2 = out1;
end
always @(*) begin
    if (out2 >= thd) out3 = out2 - thd;
    else out3 = out2;
end
always @(*) begin
    if (out3 >= forth) out4 = out3 - forth;
    else out4 = out3;
end
always @(*) begin
    if (out4 >= fifth) out5 = out4 - fifth;
    else out5 = out4;
end
always @(*) begin
    if (out5 >= sixth) out6 = out5 - sixth;
    else out6 = out5;
end
always @(*) begin
    if (out6 >= seventh) out7 = out6 - seventh;
    else out7 = out6;
end
always @(*) begin
    if (out7 >= min) out8 = out7 - min;
    else out8 = out7;
end




always @(*) begin
    if (input_money == out1) out = input_money;
    else if (out1 == out2)  out = out1;
    else if (out2 == out3)  out = out2;
    else if (out3 == out4)  out = out3;
    else if (out4 == out5)  out = out4;
    else if (out5 == out6)  out = out5;
    else if (out6 == out7)  out = out6;
    else if (out7 == out8)  out = out7;
    else out = out8;
end






assign out_valid = (sum == 0 ||sum == 10 || sum == 20 || sum == 30 || sum == 40 || sum == 50 || sum == 60 || sum == 70 || sum == 80 || sum == 90 || sum == 100 || sum == 110 || sum == 120 || sum == 130 || sum == 140)? 1:0;

assign out_change = (out_valid)? out : input_money;
endmodule