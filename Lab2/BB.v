module BB(
    //Input Ports
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] inning,   // Current inning number
    input half,           // 0: top of the inning, 1: bottom of the inning
    input [2:0] action,   // Action code

    //Output Ports
    output reg out_valid,  // Result output valid
    output reg [7:0] score_A,  // Score of team A (guest team)
    output reg [7:0] score_B,  // Score of team B (home team)
    output reg [1:0] result    // 0: Team A wins, 1: Team B wins, 2: Darw
);

//==============================================//
//             Action Memo for Students         //
// Action code interpretation:
// 3’d0: Walk (BB)
// 3’d1: 1H (single hit)
// 3’d2: 2H (double hit)
// 3’d3: 3H (triple hit)
// 3’d4: HR (home run)
// 3’d5: Bunt (short hit)
// 3’d6: Ground ball
// 3’d7: Fly ball
//==============================================//

//==============================================//
//             Parameter and Integer            //
//==============================================//
// State declaration for FSM
// Example: parameter IDLE = 3'b000;



//==============================================//
//                 reg declaration              //
//==============================================//
reg [2:0] cs, ns;
reg [1:0] cout, nout;
reg [2:0] score;
reg [2:0] action_1;
reg in_one, half_1;


localparam NULL = 3'b000;
localparam ONE = 3'b001;
localparam TWO = 3'b010;
localparam ONETWO  = 3'b011;
localparam THREE  = 3'b100;
localparam ONETHREE  = 3'b101;
localparam TWOTHREE  = 3'b110;
localparam FULL  = 3'b111;
//You can modify the FSM state



//==============================================//
//             Current State Block              //
//==============================================//
always @(posedge clk ) begin
 in_one <= in_valid;
end

always @(posedge clk ) begin
 if (in_valid ==1) begin
        half_1 <= half;
    end
    else half_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        action_1 <= 0;
    end
    else if (in_valid ==1) begin
        action_1 <= action;
    end
    else action_1 <= 0;
end


always @(posedge clk) begin
if (nout == 3) begin
        cs <= NULL;
    end 
    else begin
        cs <= ns;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cout <= 0;
    end
    else if (nout == 3) begin
        cout <= 0;
    end
    else begin
        cout <= nout;
    end
end





//==============================================//
//              Next State Block                //
//==============================================//


always @(*) begin
    if (in_one ==1) begin
        case (cs)
NULL: begin
    case (action_1)
        3'd0, 3'd1: begin // walk or single
            ns = ONE;
            nout = cout;
            score = 0;
        end
        3'd2: begin // double
            ns = TWO;
            nout = cout;
            score = 0;
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 0;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 1;
        end
        default: begin // bunt, ground ball, fly ball
            ns = NULL;
            nout = cout + 1;
            score = 0;
        end
    endcase
end

     
ONE: begin
    case (action_1)
        3'd0: begin // walk
            ns = ONETWO;
            nout = cout;
            score = 0;
        end
        3'd1: begin // single
            ns = (cout == 2'd2) ? ONETHREE : ONETWO;
            nout = cout;
            score = 0;
        end
        3'd2: begin // double
            ns = (cout == 2'd2) ? TWO : TWOTHREE;
            nout = cout;
            score = (cout == 2'd2) ? 1 : 0;
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 1;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 2;
        end
        3'd5: begin // bunt
            ns = TWO;
            nout = cout + 1; 
            score = 0;
        end
        3'd6, 3'd7: begin 
            ns = (action_1 == 3'd6) ? (cout == 2'd2 ? cs : NULL) : cs;
            nout = (action_1 == 3'd6) ? (cout == 2'd2 ? cout + 1 : cout + 2) : cout + 1; 
            if (action_1 == 3'd6 && cout == 2'd1) nout = 3; 
            score = 0;
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end




        TWO: begin        
    case (action_1)
        3'd0: begin // walk
            ns = ONETWO;
            nout = cout;
            score = 0;
        end
        3'd1: begin // single
            ns = (cout == 2'd2) ? ONE : ONETHREE;
            nout = cout;
            score = (cout == 2'd2) ? 1 : 0;
        end
        3'd2: begin // double
            ns = cs;
            nout = cout;
            score = 1;                             
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 1;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 2;
        end
        3'd5: begin // bunt
            ns = THREE;
            nout = cout + 1;
            score = 0;
        end
        3'd6: begin // ground ball
            if (cout == 2'd2) begin
                ns = cs;
            end else begin
                ns = THREE;
            end
            nout = cout + 1;
            score = 0;
        end
        3'd7: begin // fly ball
            ns = cs;
            nout = cout + 1;
            score = 0;
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end


ONETWO: begin 
    case (action_1)
        3'd0: begin // walk
            ns = FULL;
            nout = cout;
            score = 0;
        end
        3'd1: begin // single
            ns = (cout == 2'd2) ? ONETHREE : FULL;
            nout = cout;
            score = (cout == 2'd2) ? 1 : 0;
        end
        3'd2: begin // double
            ns = (cout == 2'd2) ? TWO : TWOTHREE;
            nout = cout;
            score = (cout == 2'd2) ? 2 : 1;
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 2;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 3;
        end
        3'd5: begin // bunt
            ns = TWOTHREE;
            nout = cout + 1;
            score = 0;
        end
        3'd6: begin // ground ball
            if (cout == 2'd2) begin
                ns = cs;
                nout = cout + 1;
                score = 0;
            end else begin
                ns = (cout == 2'd1) ? THREE : THREE;
                nout = cout + 2;
                score = 0;
            end
        end
        3'd7: begin // fly ball
            ns = cs;
            nout = cout + 1;
            score = 0;
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end


THREE: begin /////*////
    case (action_1)
        3'd0: begin // walk
            ns = ONETHREE;
            nout = cout;
            score = 0;
        end
        3'd1: begin // single
            ns = ONE;
            nout = cout;
            score = 1;       
        end
        3'd2: begin // double
            ns = TWO;
            nout = cout;
            score = 1;                         
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 1;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 2;
        end
        3'd5: begin // bunt
            ns = NULL;
            nout = cout + 1;
            score = 1;
        end
        3'd6, 3'd7: begin // ground ball or fly ball
            if (cout == 2'd2) begin
                ns = cs;
                nout = cout + 1;
                score = 0;
            end else begin
                ns = NULL;
                nout = cout + 1;
                score = 1;
            end
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end


ONETHREE: begin 
    case (action_1)
        3'd0: begin // walk
            ns = FULL;
            nout = cout;
            score = 0;
        end
        3'd1: begin // single
            ns = (cout == 2'd2) ? cs : ONETWO;
            nout = cout;
            score = 1;
        end
        3'd2: begin // double
            ns = (cout == 2'd2) ? TWO : TWOTHREE;
            nout = cout;
            score = (cout == 2'd2) ? 2 : 1;
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 2;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 3;
        end
        3'd5: begin // bunt
            ns = TWO;
            nout = cout + 1;
            score = 1;
        end
        3'd6: begin // ground ball
            if (cout == 2'd2) begin
                ns = cs;
                nout = cout + 1;
                score = 0;
            end else if (cout == 2'd1) begin
                ns = THREE;
                nout = 3;
                score = 0;
            end else begin
                ns = NULL;
                nout = 2;
                score = 1;
            end
        end
        3'd7: begin // fly ball
            if (cout == 2'd2) begin
                ns = cs;
                nout = cout + 1;
                score = 0;
            end else begin
                ns = ONE;
                nout = cout + 1;
                score = 1;
            end
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end



TWOTHREE: begin 
    case (action_1)
        3'd0: begin // walk
            ns = FULL;
            nout = cout;
            score = 0;
        end
        3'd1: begin // single
            ns = (cout == 2'd2) ? ONE : ONETHREE;
            nout = cout;
            score = (cout == 2'd2) ? 2 : 1;
        end
        3'd2: begin // double
            ns = TWO;
            nout = cout;
            score = 2;                         
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 2;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 3;
        end
        3'd5: begin // bunt
            ns = THREE;
            nout = cout + 1;
            score = 1;
        end
        3'd6: begin // ground ball
            ns = (cout == 2'd2) ? cs : THREE;
            nout = cout + 1;
            score = (cout == 2'd2) ? 0 : 1;
        end
        3'd7: begin // fly ball
            ns = (cout == 2'd2) ? cs : TWO;
            nout = cout + 1;
            score = (cout == 2'd2) ? 0 : 1;
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end



FULL: begin
    case (action_1)
        3'd0: begin // walk
            ns = cs;
            nout = cout;
            score = 1;
        end
        3'd1: begin // single
            ns = (cout == 2'd2) ? ONETHREE : cs;
            nout = cout;
            score = (cout == 2'd2) ? 2 : 1;
        end
        3'd2: begin // double
            ns = (cout == 2'd2) ? TWO : TWOTHREE;
            nout = cout;
            score = (cout == 2'd2) ? 3 : 2;
        end
        3'd3: begin // triple
            ns = THREE;
            nout = cout;
            score = 3;
        end
        3'd4: begin // home run
            ns = NULL;
            nout = cout;
            score = 4;
        end
        3'd5: begin // bunt
            ns = TWOTHREE;
            nout = cout + 1;
            score = 1;
        end
        3'd6: begin // ground ball
            case (cout)
                2'd2: begin
                    ns = cs;
                    nout = cout + 1;
                    score = 0;
                end
                2'd1: begin
                    ns = TWOTHREE;
                    nout = cout + 2;
                    score = 0;
                end
                default: begin
                    ns = THREE;
                    nout = cout + 2;
                    score = 1;
                end
            endcase
        end
        3'd7: begin // fly ball
            ns = (cout == 2'd2) ? cs : ONETWO;
            nout = cout + 1;
            score = (cout == 2'd2) ? 0 : 1;
        end
        default: begin
            ns = cs;
            nout = cout;
            score = 0;
        end
    endcase
end


        default: begin
            ns = NULL;
            nout = cout;
            score = 0;

        end
        endcase
    end
    else begin
        ns = NULL;
            nout = cout;
            score = 0;
    end
end


//==============================================//
//             Base and Score Logic             //
//==============================================//
// Handle base runner movements and score calculation.
// Update bases and score depending on the action:
// Example: Walk, Hits (1H, 2H, 3H), Home Runs, etc.
reg lock_score_BB; 

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (in_valid == 0 && in_one == 1)begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        score_A <= 0;
    end
    else if (in_one == 1 && half_1 == 0)begin 
        score_A <= score_A + score;
    end
    else if (half_1 == 1)begin 
        score_A <= score_A ;
    end
    else begin
        score_A <= 0;
    end
end



always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        score_B <= 0;
    end
 else if (in_one == 1) begin    
        if (half_1 == 1) begin
            if (!lock_score_BB) begin
                score_B <= score_B + score;
            end
            else begin
                score_B <= score_B;
            end
        end
        else if (half_1 == 0) begin
            if (inning == 3  && score_B > score_A) begin
                lock_score_BB <= 1; 
            end
            else begin
                lock_score_BB <= 0;
            end
        end
    end
    else begin
        score_B <= 0;
        lock_score_BB <= 0; 
    end
end



//==============================================//
//                Output Block                  //
//==============================================//
// Decide when to set out_valid high, and output score_A, score_B, and result.


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 0;
    end 
    else if (in_one == 1 && in_valid == 0 && score_A > score_B) result <= 0;
    else if (in_one == 1 && in_valid == 0 && score_A < score_B) result <= 1;
    else if (in_one == 1 && in_valid == 0 && score_A == score_B) result <= 2;

end




endmodule
