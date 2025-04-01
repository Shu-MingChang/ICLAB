module FIFO_syn #(parameter WIDTH=8, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

    flag_fifo_to_clk1,
	flag_clk1_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output flag_fifo_to_clk2;
input flag_clk2_to_fifo;

output flag_fifo_to_clk1;
input flag_clk1_to_fifo;

wire [WIDTH-1:0] rdata_reg;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr; //7bit
reg [$clog2(WORDS):0] rptr;

reg [$clog2(WORDS):0] wptr_next; // gray code
reg [$clog2(WORDS):0] rptr_next; // gray code

reg [5:0] waddr, raddr ;

reg [6:0] wbin, rbin, wbin_next, rbin_next;
reg [6:0] wq2_rptr,  rq2_wptr ;
reg rinc_reg;
integer j;
integer i;



assign flag_fifo_to_clk1 = (rinc_reg);

always @ (posedge rclk or negedge rst_n) begin 
	if (!rst_n) rinc_reg <= 0;
	else begin 
		rinc_reg <= rinc;
	end
end

always @ (posedge rclk or negedge rst_n) begin 
	if (!rst_n) rdata <= 0;
	else if (rinc_reg) begin
		rdata <= rdata_reg;
    end
    else begin
        rdata <= rdata;
    end
	
end

always @ (posedge rclk or negedge rst_n) begin 
	if (!rst_n) rbin <= 0 ;
	else begin 
		rbin <= rbin_next;
	end
end

always @ (posedge rclk or negedge rst_n) begin 
	if (!rst_n) rptr <= 0 ;
	else begin 
		rptr <= rptr_next;
	end
end

always @(*) begin
    if (rinc == 1 && rempty == 0) begin
        rbin_next = rbin + 1;
    end
    else begin
        rbin_next = rbin;
    end
end

always @(*) begin
    for (j = 0; j < 6; j = j + 1) begin
        rptr_next[j] = rbin_next[j] ^ rbin_next[j+1];
    end
        rptr_next[6] = rbin_next[6];
end

always @ (posedge rclk or negedge rst_n) begin 
	if (!rst_n) begin
        rempty <= 1;
    end
	else if (rptr_next != rq2_wptr)begin 
		rempty <= 0;
	end
    else if (rptr_next == rq2_wptr)begin 
		rempty <= 1;
	end
end

NDFF_BUS_syn #(7) ndff_r2w (.D(rptr), .Q(wq2_rptr), .clk(wclk), .rst_n(rst_n));


always @ (posedge wclk or negedge rst_n) begin 
	if (!rst_n) wbin <= 0 ;
	else begin 
		wbin <= wbin_next;
	end
end

always @ (posedge wclk or negedge rst_n) begin 
	if (!rst_n) wptr <= 0 ;
	else begin 
		wptr <= wptr_next;
	end
end

always @(*) begin
    if (winc == 1 && wfull == 0) begin
        wbin_next = wbin + 1;
    end
    else begin
        wbin_next = wbin;
    end
end

always @(*) begin
    for (i = 0; i < 6; i = i + 1) begin
        wptr_next[i] = wbin_next[i] ^ wbin_next[i+1];
    end
        wptr_next[6] = wbin_next[6];
end

always @ (posedge wclk or negedge rst_n) begin 
	if (!rst_n) begin
        wfull <= 0;
    end
	else if ((wptr_next ^ wq2_rptr) == 7'b1100000)begin 
		wfull <= 1;
	end
    else begin 
		wfull <= 0;
	end
end

wire wclken;

/*
always @ (posedge wclk or negedge rst_n) begin 
	if (!rst_n) begin
        wclken <= 0;
    end
	else if (winc && ~wfull)begin 
		wclken <= 1;
	end
    else begin 
		wclken <= 0;
	end
end
*/
NDFF_BUS_syn #(7) ndff_w2r (.D(wptr), .Q(rq2_wptr), .clk(rclk), .rst_n(rst_n));




assign wclken = (winc && ~wfull);

DUAL_64X8X1BM1 u_dual_sram (
    .CKA(wclk),
    .CKB(rclk),
    .WEAN(1'b0),
    .WEBN(1'b1),
    .CSA(wclken),
    .CSB(1'b1),
    .OEA(1'b1),
    .OEB(1'b1),
    .A0(wbin[0]),
    .A1(wbin[1]),
    .A2(wbin[2]),
    .A3(wbin[3]),
    .A4(wbin[4]),
    .A5(wbin[5]),
    .B0(rbin[0]),
    .B1(rbin[1]),
    .B2(rbin[2]),
    .B3(rbin[3]),
    .B4(rbin[4]),
    .B5(rbin[5]),
    .DIA0(wdata[0]),
    .DIA1(wdata[1]),
    .DIA2(wdata[2]),
    .DIA3(wdata[3]),
    .DIA4(wdata[4]),
    .DIA5(wdata[5]),
    .DIA6(wdata[6]),
    .DIA7(wdata[7]),
    .DIB0(1'b0),
    .DIB1(1'b0),
    .DIB2(1'b0),
    .DIB3(1'b0),
    .DIB4(1'b0),
    .DIB5(1'b0),
    .DIB6(1'b0),
    .DIB7(1'b0),
    .DOB0(rdata_reg[0]),
    .DOB1(rdata_reg[1]),
    .DOB2(rdata_reg[2]),
    .DOB3(rdata_reg[3]),
    .DOB4(rdata_reg[4]),
    .DOB5(rdata_reg[5]),
    .DOB6(rdata_reg[6]),
    .DOB7(rdata_reg[7])
);

endmodule
