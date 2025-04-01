module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output reg sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

reg [WIDTH-1:0] data;

always @ (posedge sclk or negedge rst_n) begin  
	if (!rst_n) begin
        data <= 0;
    end
	else if (sready == 1) begin
        data <= din;
    end 
    else begin
        data <= data;
    end
end

always @ (posedge sclk or negedge rst_n) begin  
	if (!rst_n) begin
        sreq <= 0;
    end
    else if (sack == 1) sreq <= 0;
	else if (sready == 1) sreq <= 1;
    else sreq <= sreq;
end



always @(*) begin
    sidle = !(sreq || sack || sready);
end


//assign sidle = !(sreq || sack || sready);

NDFF_syn dff_s2d (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));

always @ (posedge dclk or negedge rst_n) begin  
	if (!rst_n) begin
        dack <= 0;
    end
    else if (dreq == 1 && !dbusy) dack <= 1;
    else dack <= 0;
end

always @(posedge dclk or negedge rst_n)begin
    if(!rst_n) begin
        dvalid <= 0;
    end
    else begin
        dvalid <= (dreq && !dbusy) ? 1 : 0;
    end
end

always @(posedge dclk or negedge rst_n)begin
    if(!rst_n) begin
        dout <= 0;
    end
    else begin
        dout <= (dreq && !dbusy) ? data : dout;
    end
end


NDFF_syn dff_d2s (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

endmodule