//=============================================================================
// Testbench: tb_fsm_clk_div_3_50pct
// Description: Testbench for Dual-FSM Divide-by-3 Clock Generator with 
//              waveform dumping ($dumpfile/$dumpvars) and real-time monitoring ($monitor)
//=============================================================================
`timescale 1ns / 1ps

module tb_fsm_clk_div_3_50pct;

    // Testbench Signals
    reg  clk;
    reg  rst_n;
    wire clk_out;

    // Instantiate Design Under Test (DUT)
    fsm_clk_div_3_50pct dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .clk_out (clk_out)
    );

    //-------------------------------------------------------------------------
    // 1. Clock Generation (100 MHz clock -> 10ns period)
    //-------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //-------------------------------------------------------------------------
    // 2. Waveform Dumping ($dumpvars) and Console Logging ($monitor)
    //-------------------------------------------------------------------------
    initial begin
        // Generate VCD file for GTKWave or ModelSim viewer
        $dumpfile("clk_div_3.vcd");
        $dumpvars(0, tb_fsm_clk_div_3_50pct);

        // Print header and set up real-time console signal monitoring
        $display("-----------------------------------------------------------------------");
        $display(" TIME(ns) | clk | rst_n | pos_state | pos_out | neg_state | neg_out | clk_out");
        $display("-----------------------------------------------------------------------");
        $monitor("%8t |  %b  |   %b   |    %2b     |    %b    |    %2b     |    %b    |    %b", 
                 $time, clk, rst_n, dut.pos_state, dut.pos_out, dut.neg_state, dut.neg_out, clk_out);
    end

    //-------------------------------------------------------------------------
    // 3. Test Stimulus Sequence
    //-------------------------------------------------------------------------
    initial begin
        // Initial state
        rst_n = 0;

        // Hold reset active for 12ns
        #12;
        rst_n = 1;
        $display("[%0t ns] Reset released.", $time);

        // Run simulation for 150ns (enough for multiple divide-by-3 cycles)
        #150;

        $display("-----------------------------------------------------------------------");
        $display("[%0t ns] Simulation Complete.", $time);
        $finish;
    end

endmodule
