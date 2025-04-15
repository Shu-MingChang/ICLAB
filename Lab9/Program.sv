module Program(input clk, INF.Program_inf inf);
import usertype::*;
typedef enum logic [3:0]{
    IDLE_S,
	INDEX_CHECK_S,
    UPDATE_S,
    CHECK_VALID_DATE_S,
    INDEX_S,
    OUT_DATE_S,
    CAL_S,
    WAIT_DRAM_S,
    WRITE_S,
    OUT_INDEX_CHECK_S,
    OUT_S   
} state ;

state               cs, ns ;
Action              action;
Formula_Type        formula;
Mode                mode;
Date                date;
Date                dram_date;
Data_No             data_no;
Index [3:0]         index;
logic signed [11:0]     var_index;
logic [11:0]        before_index;
logic signed [13:0] sum;
Index               result;
Index [3:0]         dram_index;
logic [2:0]         count_index;
logic               count_read_dram_ar;
logic               read_finish;
logic [8:0]         count_write;
logic               up_data_war;

Index               G_A,G_B,G_C,G_D;
Index   [3:0]               sort;
Index   sort_02_max,sort_02_min,sort_13_max,sort_13_min,sort_max,sort_sec_s,sort_min,sort_sec_b,sort_sec,sort_thd;
logic   ee [0:3];
logic   sort_dd0,sort_dd1,sort_dd2,sort_dd3;
Index   r;
Index   threshold;
always_comb begin
    if (cs == CAL_S) begin
        if (dram_index[0] >= index[0]) begin
            G_A = dram_index[0] - index[0];
            ee[0] = 1; 
        end
        else begin
            G_A = index[0] - dram_index[0];
            ee[0] = 0;
        end
    end
    else begin
        G_A = 0;
        ee[0] = 0;
    end
end
always_comb begin
    if (cs == CAL_S) begin
        if (dram_index[1] >= index[1]) begin
            G_B = dram_index[1] - index[1];
            ee[1] = 1;
        end
        else begin
            G_B = index[1] - dram_index[1];
            ee[1] = 0;
        end
    end
    else begin
        G_B = 0;
        ee[1] = 0;
    end
end
always_comb begin
    if (cs == CAL_S) begin
        if (dram_index[2] >= index[2]) begin
            G_C = dram_index[2] - index[2];
            ee[2] = 1;
        end
        else begin
            G_C = index[2] - dram_index[2];
            ee[2] = 0;
        end
    end
    else begin
        G_C = 0;
        ee[2] = 0;
    end
end

always_comb begin
    if (cs == CAL_S) begin
        if (dram_index[3] >= index[3]) begin
            G_D = dram_index[3] - index[3];
            ee[3] = 1;
        end
        else begin
            G_D = index[3] - dram_index[3];
            ee[3] = 0;
        end
    end
    else begin
        G_D = 0;
        ee[3] = 0;
    end
end

always_comb begin
    if (cs == CAL_S) begin
        if (formula == Formula_B || formula == Formula_C) begin
            sort[0] = dram_index[0];
            sort[1] = dram_index[1];
            sort[2] = dram_index[2];
            sort[3] = dram_index[3];
        end
        else if (formula == Formula_F || formula == Formula_G) begin
            sort[0] = G_A;
            sort[1] = G_B;
            sort[2] = G_C;
            sort[3] = G_D;
        end
        else begin
            sort[0] = 0;
            sort[1] = 0;
            sort[2] = 0;
            sort[3] = 0;
        end
    end
    else begin
            sort[0] = 0;
            sort[1] = 0;
            sort[2] = 0;
            sort[3] = 0;
        end
end

assign sort_02_max = (sort[0] >= sort[2])? sort[0]  :   sort[2];
assign sort_02_min = (sort[0] < sort[2])?  sort[0]  :   sort[2];
assign sort_13_max = (sort[1] >= sort[3])? sort[1]  :   sort[3];
assign sort_13_min = (sort[1] < sort[3])?  sort[1]  :   sort[3];

assign sort_max    = (sort_02_max >= sort_13_max)? sort_02_max : sort_13_max;
assign sort_sec_s    = (sort_02_max < sort_13_max)? sort_02_max : sort_13_max;
assign sort_min    = (sort_02_min < sort_13_min)?    sort_02_min:sort_13_min;
assign sort_sec_b    = (sort_02_min >= sort_13_min)?    sort_02_min:sort_13_min;

assign sort_sec     = (sort_sec_s >= sort_sec_b)? sort_sec_s : sort_sec_b;
assign sort_thd     = (sort_sec_s < sort_sec_b)? sort_sec_s : sort_sec_b;
assign sort_dd0     = (dram_index[0] >= 2047)?  1:0;
assign sort_dd1     = (dram_index[1] >= 2047)?  1:0;
assign sort_dd2     = (dram_index[2] >= 2047)?  1:0;
assign sort_dd3     = (dram_index[3] >= 2047)?  1:0;


always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) r <= 0;
    else begin
        if (cs == CAL_S) begin
            if (formula == Formula_A)  r <= (dram_index[0] + dram_index[1] + dram_index[2] + dram_index[3])/4;
            else if (formula == Formula_B) r <= sort_max - sort_min;
            else if (formula == Formula_C) r <= sort_min; 
            else if (formula == Formula_D) r <= sort_dd0 + sort_dd1 + sort_dd2 + sort_dd3; 
            else if (formula == Formula_E) r <= ee[0] + ee[1] + ee[2] + ee[3];
            else if (formula == Formula_F) r <= (sort_min + sort_thd + sort_sec)/3; 
            else if (formula == Formula_G) r <= (sort_min >> 1) + (sort_thd >> 2) + (sort_sec >> 2);
            else if (formula == Formula_H) r <= (G_A + G_B + G_C + G_D) /4;
        end
        else if (cs == IDLE_S)begin
            r <= 0;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) threshold <= 0;
    else begin
        if (cs == CAL_S) begin
            if (formula == Formula_A || formula == Formula_C) begin
                if (mode == Insensitive) threshold <= 2047;
                else if (mode == Normal) threshold <= 1023;
                else if (mode == Sensitive) threshold <= 511;
            end
            else if (formula == Formula_B || formula == Formula_F || formula == Formula_G || formula == Formula_H) begin
                if (mode == Insensitive) threshold <= 800;
                else if (mode == Normal) threshold <= 400;
                else if (mode == Sensitive) threshold <= 200;
            end
            else if (formula == Formula_D || formula == Formula_E) begin
                if (mode == Insensitive) threshold <= 3;
                else if (mode == Normal) threshold <= 2;
                else if (mode == Sensitive) threshold <= 1;
            end
        end
        else if (cs == IDLE_S)begin
            threshold <= 0;
        end
    end
end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) count_write <= 0;
    else if (cs == WRITE_S && count_write < 6) count_write <= count_write + 1;
    else if (cs == IDLE_S) count_write <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) var_index <= 0;
    else begin
        if (cs == WRITE_S) begin
            case (count_write)
                0: var_index <= index[0];
                1: var_index <= index[1];
                2: var_index <= index[2];
                3: var_index <= index[3];
                default: var_index <= 0;
            endcase
        end
        else begin
            var_index <= 0;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) before_index <= 0;
    else begin
        if (cs == WRITE_S) begin
            case (count_write)
                0: before_index <= dram_index[0];
                1: before_index <= dram_index[1];
                2: before_index <= dram_index[2];
                3: before_index <= dram_index[3];
                default: before_index <= 0;
            endcase
        end
        else begin
            before_index <= 0;
        end
    end
end



always_comb begin
    sum = $signed({2'b00, before_index}) + var_index;
    if (sum < 0) begin
        result = 12'd0; 
    end
    else if (sum > 4095) begin
        result = 12'd4095; 
    end
    else begin
        result = sum[11:0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) up_data_war <= 0;
    else begin
        if (cs == WRITE_S) begin
            if (sum < 0 || sum > 4095) begin
                up_data_war <= 1;
            end
        end
        else if (cs == IDLE_S) begin
            up_data_war <= 0;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) count_read_dram_ar <= 0;
    else if (inf.data_no_valid) count_read_dram_ar <= count_read_dram_ar + 1;
    else count_read_dram_ar <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) cs <= IDLE_S;
    else cs <= ns;
end

always_comb begin
    case(cs)
        IDLE_S: begin
            if (inf.sel_action_valid ) begin
                if ( inf.D.d_act[0] == Index_Check) ns = INDEX_CHECK_S;
                else if ( inf.D.d_act[0] == Update) ns = UPDATE_S;
                else ns = CHECK_VALID_DATE_S;
            end
            else ns = IDLE_S;
        end
        INDEX_CHECK_S: begin
            if (count_index == 4 && read_finish) ns = CAL_S;
            else ns = INDEX_CHECK_S;
        end
        UPDATE_S: begin
            if (count_index == 4 && read_finish) ns = WRITE_S;
            else ns = UPDATE_S;
        end
        CHECK_VALID_DATE_S: begin
            if (read_finish) ns = OUT_DATE_S;
            else ns = CHECK_VALID_DATE_S;
        end
        CAL_S: begin
            ns = OUT_INDEX_CHECK_S;
        end
        OUT_DATE_S: begin
            ns = IDLE_S ;
        end
        
        WRITE_S: begin
            if (inf.B_VALID) ns = OUT_S;
             else ns = WRITE_S;
        end
        OUT_S: begin
            ns = IDLE_S;
        end
        OUT_INDEX_CHECK_S: begin
            ns = IDLE_S;
        end


        default: ns = IDLE_S;
    endcase
end

///////////////////////////////////////////
/////               store           ///////
///////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        action <= Index_Check;
    end
    else begin
		if (inf.sel_action_valid) action <= inf.D.d_act[0];
		else action <= action;
	end
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        formula <= Formula_A;
    end
    else begin
		if (inf.formula_valid) formula <= inf.D.d_formula[0];
		else formula <= formula;
	end
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        mode <= Insensitive;
    end
    else begin
		if (inf.mode_valid) mode <= inf.D.d_mode[0];
		else mode <= mode;
	end
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        date.M <= 0;
        date.D <= 0;
    end
    else begin
		if (inf.date_valid) date <= inf.D.d_date[0];
		else date <= date;
	end
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        data_no <= 0;
    end
    else begin
		if (inf.data_no_valid) data_no <= inf.D.d_data_no[0];
		else data_no <= data_no;
	end
end
always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
		count_index <= 0 ;
	end
	else begin
		if (cs == IDLE_S) begin
            count_index <= 0;
        end
		else if (inf.index_valid) begin 
			count_index <= count_index + 1;
		end
		else begin 
			count_index <= count_index;
		end
	end
end
always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        index[0] <= 0;
        index[1] <= 0;
        index[2] <= 0;
        index[3] <= 0;
    end
    else begin
		if (inf.index_valid) begin
            index[count_index] <= inf.D.d_index[0];
        end
		else begin
            index[0] <= index[0];
            index[1] <= index[1];
            index[2] <= index[2];
            index[3] <= index[3];
        end
	end
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        dram_index[0] <= 0;
        dram_index[1] <= 0;
        dram_index[2] <= 0;
        dram_index[3] <= 0;
    end
    else begin
		if (inf.R_VALID) begin
            dram_index[0] <= inf.R_DATA[63:52];
            dram_index[1] <= inf.R_DATA[51:40];
            dram_index[2] <= inf.R_DATA[31:20];
            dram_index[3] <= inf.R_DATA[19:8];
        end
        else if (cs == WRITE_S) begin
            case (count_write)
                1: dram_index[0] <= result;
                2: dram_index[1] <= result;
                3: dram_index[2] <= result;
                4: dram_index[3] <= result;
            endcase
        end
		else begin
            dram_index[0] <= dram_index[0];
            dram_index[1] <= dram_index[1];
            dram_index[2] <= dram_index[2];
            dram_index[3] <= dram_index[3];
        end
	end
end
always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
        dram_date.M <= 0;
        dram_date.D <= 0;
    end
    else begin
		if (inf.R_VALID) begin
            dram_date.M <= inf.R_DATA[39:32];
            dram_date.D <= inf.R_DATA[7:0];
        end
		else begin
            dram_date.M <= dram_date.M;
            dram_date.D <= dram_date.D;
        end
	end
end

///////////////////////////////////////////
///                    dram
//////////////////////////////////////////////
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AR_VALID <= 0;
    end
    else if (inf.data_no_valid ) begin
        inf.AR_VALID <= 1;
    end
    else if (inf.AR_READY) begin
        inf.AR_VALID <= 0;
    end
    else begin
        inf.AR_VALID <= inf.AR_VALID;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AR_ADDR <= 0;
    end
    else if (inf.data_no_valid ) begin
        inf.AR_ADDR <= 17'h10000 + {6'd0,inf.D.d_data_no[0],3'd0};
    end
    else if (inf.AR_READY) begin
        inf.AR_ADDR <= 0;
    end
    else begin
        inf.AR_ADDR <= inf.AR_ADDR;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.R_READY <= 0;
    end
    else if (inf.AR_READY) begin
        inf.R_READY <= 1;
    end
    else if (inf.R_VALID) begin
        inf.R_READY <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        read_finish <= 0;
    end
    else if (inf.R_VALID) begin
        read_finish <= 1;
    end
    else if (cs == IDLE_S) begin
        read_finish <= 0;
    end
end
/////////////////////////////////////////////////////////////////////
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AW_ADDR <= 0;
    end
    else if (cs == WRITE_S && count_write == 2) begin
        inf.AW_ADDR <= 17'h10000 + {6'd0,data_no,3'd0};
    end
    else if (inf.AW_READY) begin
        inf.AW_ADDR <= 0;
    end
    else begin
        inf.AW_ADDR <= inf.AW_ADDR;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AW_VALID <= 0;
    end
    else if (cs == WRITE_S && count_write == 2) begin
        inf.AW_VALID <= 1;
    end
    else if (inf.AW_READY) begin
        inf.AW_VALID <= 0;
    end
    else begin
        inf.AW_VALID <= inf.AW_VALID;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.W_VALID <= 0;
    end
    else if (inf.AW_READY) begin
        inf.W_VALID <= 1;
    end
    else if (inf.W_READY) begin
        inf.W_VALID <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.W_DATA <= 0;
    end
    else if (inf.AW_READY) begin
        inf.W_DATA[63:52] <= dram_index[0];
        inf.W_DATA[51:40] <= dram_index[1];
        inf.W_DATA[39:32] <= date.M;
        inf.W_DATA[31:20] <= dram_index[2];
        inf.W_DATA[19:8] <= dram_index[3];
        inf.W_DATA[7:0] <= date.D;

    end
    else if (inf.W_READY) begin
        inf.W_DATA <= 0;
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.B_READY <= 0;
    end
    else if (inf.AW_READY) begin
        inf.B_READY <= 1;
    end
    else if (inf.B_VALID) begin
        inf.B_READY <= 0;
    end
end
/////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) begin 
		inf.out_valid <= 0;
	end
    else if (cs == OUT_S)begin 
        inf.out_valid <= 1;
    end
    else if (cs == OUT_DATE_S)begin 
        inf.out_valid <= 1;
    end
    else if (cs == OUT_INDEX_CHECK_S)begin 
        inf.out_valid <= 1;
    end
    else inf.out_valid <= 0;
end
always_ff @( posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) begin 	
        inf.complete <= 0;   
	end
    else if (cs == OUT_S && !up_data_war)begin 
        inf.complete <= 1;  
    end
    else if (cs == OUT_DATE_S && ((date.M > dram_date.M) || (date.M == dram_date.M && date.D >= dram_date.D)))begin
        inf.complete <= 1;  
    end
    else if (cs == OUT_INDEX_CHECK_S)begin
        if ((date.M < dram_date.M) || (date.M == dram_date.M && date.D < dram_date.D)) inf.complete <= 0;
        else if (r >= threshold) inf.complete <= 0;
        else inf.complete <= 1;
    end
    else begin   
        inf.complete <= 0;
    end
end
always_ff @( posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) begin 
        inf.warn_msg <= 0;
	end
    else if (cs == OUT_S && up_data_war)begin 
        inf.warn_msg <= Data_Warn;  
    end
    else if (cs == OUT_DATE_S && ((date.M < dram_date.M) || (date.M == dram_date.M && date.D < dram_date.D)))begin
        inf.warn_msg <= Date_Warn;  
    end
    else if (cs == OUT_INDEX_CHECK_S && ((date.M < dram_date.M) || (date.M == dram_date.M && date.D < dram_date.D)))begin
        inf.warn_msg <= Date_Warn;  
    end
    else if (cs == OUT_INDEX_CHECK_S && r >= threshold)begin
        inf.warn_msg <= Risk_Warn;  
    end
    else begin 
        inf.warn_msg <= 0;
    end
end

endmodule
