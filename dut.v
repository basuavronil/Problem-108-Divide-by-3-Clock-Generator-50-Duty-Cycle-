//=============================================================================
// Module: fsm_clk_div_3_50pct
// Description: Divide-by-3 Clock Generator with 50% Duty Cycle 
//              using dual Posedge and Negedge FSMs (Case Statement)
//=============================================================================
module fsm_clk_div_3_50pct (
    input  wire clk,
    input  wire rst_n,
    output wire clk_out
);

    // Common State Encodings
    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    // Posedge FSM Registers
    reg [1:0] pos_state, pos_next_state;
    reg       pos_out;

    // Negedge FSM Registers
    reg [1:0] neg_state, neg_next_state;
    reg       neg_out;

    //-------------------------------------------------------------------------
    // 1. Posedge FSM: State Register
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pos_state <= S0;
        else
            pos_state <= pos_next_state;
    end

    //-------------------------------------------------------------------------
    // 2. Posedge FSM: Next-State & Output Case Statement
    //-------------------------------------------------------------------------
    always @(*) begin
        case (pos_state)
            S0: begin
                pos_next_state = S1;
                pos_out        = 1'b1;
            end
            S1: begin
                pos_next_state = S2;
                pos_out        = 1'b1;
            end
            S2: begin
                pos_next_state = S0;
                pos_out        = 1'b0;
            end
            default: begin
                pos_next_state = S0;
                pos_out        = 1 me;
            end
        endcase
    end

    //-------------------------------------------------------------------------
    // 3. Negedge FSM: State Register
    //-------------------------------------------------------------------------
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n)
            neg_state <= S0;
        else
            neg_state <= neg_next_state;
    end

    //-------------------------------------------------------------------------
    // 4. Negedge FSM: Next-State & Output Case Statement
    //-------------------------------------------------------------------------
    always @(*) begin
        case (neg_state)
            S0: begin
                neg_next_state = S1;
                neg_out        = 1'b1;
            end
            S1: begin
                neg_next_state = S2;
                neg_out        = 1'b1;
            end
            S2: begin
                neg_next_state = S0;
                neg_out        = 1'b0;
            end
            default: begin
                neg_next_state = S0;
                neg_out        = 1'b0;
            end
        endcase
    end

    //-------------------------------------------------------------------------
    // 5. Combination Gate (Trim overlap to get 1.5 cycles HIGH / 50% duty cycle)
    //-------------------------------------------------------------------------
    assign clk_out = pos_out & neg_out;

endmodule
