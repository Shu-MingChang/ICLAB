//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/10
//		Version		: v1.0
//   	File Name   : HAMMING_IP.v
//   	Module Name : HAMMING_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module HAMMING_IP #(parameter IP_BIT = 8) (
    // Input signals
    IN_code,
    // Output signals
    OUT_code
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_BIT+4-1:0]  IN_code;

output reg [IP_BIT-1:0] OUT_code;

// ===============================================================
// Design
// ===============================================================
genvar  i;
//wire [3:0] add_out [1:IP_BIT+4];
reg [IP_BIT+4-1:0]  OUT_with_hamming;


generate
if (IP_BIT == 5) begin: ip_5
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_5.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_5.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_5.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_5.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_5.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9]};
        end
    end
end

else if (IP_BIT == 6) begin: ip_6
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_6.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_6.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_6.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_6.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_6.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10]};
        end
        else if (add_sum == 10) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],~IN_code[IP_BIT+4-10]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10]};
        end
    end
end

else if (IP_BIT == 7) begin: ip_7
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_7.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_7.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_7.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_7.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_7.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
        else if (add_sum == 10) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],~IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
        else if (add_sum == 11) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],~IN_code[IP_BIT+4-11]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11]};
        end
    end
end

else if (IP_BIT == 8) begin: ip_8
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_8.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_8.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_8.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_8.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_8.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 0 || add_sum == 1 || add_sum == 2 || add_sum == 4 || add_sum == 8) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 10) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],~IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 11) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],~IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
        else if (add_sum == 12) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],~IN_code[IP_BIT+4-12]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12]};
        end
    end
end

else if (IP_BIT == 9) begin: ip_9
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_9.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_9.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_9.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_9.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_9.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 10) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],~IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 11) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],~IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 12) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],~IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
        else if (add_sum == 13) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],~IN_code[IP_BIT+4-13]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13]};
        end
    end
end

else if (IP_BIT == 10) begin: ip_10
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_10.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_10.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_10.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_10.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_10.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 10) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],~IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 11) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],~IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 12) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],~IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 13) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],~IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
        else if (add_sum == 14) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],~IN_code[IP_BIT+4-14]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14]};
        end
    end
end

else if (IP_BIT == 11) begin: ip_11
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin: add_1bit
        wire [3:0] temp_result;
        //wire [3:0] add_out[1:IP_BIT+4];
        wire [3:0] add_out;
        assign temp_result = (IN_code[IP_BIT+4-i] == 1)?  i : 0;
        if (i == 1) begin
            assign add_out[0] = temp_result[0];
            assign add_out[1] = temp_result[1];
            assign add_out[2] = temp_result[2];
            assign add_out[3] = temp_result[3];
        end
        else begin
            assign add_out[0] = temp_result[0] + ip_11.add_1bit[i-1].add_out[0];
            assign add_out[1] = temp_result[1] + ip_11.add_1bit[i-1].add_out[1];
            assign add_out[2] = temp_result[2] + ip_11.add_1bit[i-1].add_out[2];
            assign add_out[3] = temp_result[3] + ip_11.add_1bit[i-1].add_out[3];
        end
    end
    wire [3:0] add_sum = ip_11.add_1bit[IP_BIT+4].add_out;
    always @(*) begin
        if (add_sum == 3) begin
            OUT_code = {~IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 5) begin
            OUT_code = {IN_code[IP_BIT+4-3],~IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 6) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],~IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 7) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],~IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 9) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],~IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 10) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],~IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 11) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],~IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 12) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],~IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 13) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],~IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 14) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],~IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
        else if (add_sum == 15) begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],~IN_code[IP_BIT+4-15]};
        end
        else begin
            OUT_code = {IN_code[IP_BIT+4-3],IN_code[IP_BIT+4-5],IN_code[IP_BIT+4-6],IN_code[IP_BIT+4-7],IN_code[IP_BIT+4-9],IN_code[IP_BIT+4-10],IN_code[IP_BIT+4-11],IN_code[IP_BIT+4-12],IN_code[IP_BIT+4-13],IN_code[IP_BIT+4-14],IN_code[IP_BIT+4-15]};
        end
    end
end
endgenerate




//assign OUT_code = 0;

endmodule