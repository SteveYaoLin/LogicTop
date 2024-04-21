`timescale 1ns / 1ps

module tb_pulse;

    // Parameters
    localparam _RAM_WIDTH = 32;

    // Inputs
    reg io_clk;
    reg io_rst;
    reg io_en;
    reg io_defaultLevel;
    reg [_RAM_WIDTH - 1:0] io_pulseWidth;
    reg [_RAM_WIDTH - 1:0] io_unaccessWidth;
    reg [_RAM_WIDTH - 1:0] io_pusle_times;

    // Outputs
    wire io_pulseOut;
    wire pulse_valid;
    wire pulse_busy;

    // Instantiate the Unit Under Test (UUT)
    pwm_pulse uut (
        .io_clk(io_clk),
        .io_rst(io_rst),
        .io_en(io_en),
        .io_pulseOut(io_pulseOut),
        .io_defaultLevel(io_defaultLevel),
        .io_pulseWidth(io_pulseWidth),
        .io_unaccessWidth(io_unaccessWidth),
        .io_pusle_times(io_pusle_times),
        .pulse_valid(pulse_valid),
        .pulse_busy(pulse_busy)
    );

    // Clock generation
    initial begin
        io_clk = 0;
        forever #50 io_clk = ~io_clk; // Assuming a clock period of 10 ns (100 MHz)
    end

    // Task to start a finite pulse
    task start_finite_pulse;
        input [_RAM_WIDTH - 1:0] pulse_times;
        input [_RAM_WIDTH - 1:0] pulse_width;
        input [_RAM_WIDTH - 1:0] unaccess_width;
    begin
        io_en = 1'b1;
        io_pulseWidth = pulse_width;
        io_unaccessWidth = unaccess_width;
        io_pusle_times = pulse_times;
        #10; // Wait for the clock edge
    end
    endtask

    // Task to stop the pulse
    task stop_pulse;
    begin
        io_en = 1'b0;
        #10; // Wait for the clock edge
    end
    endtask

    // Task to start a continuous pulse
    task start_continuous_pulse;
    begin
        io_en = 1'b1;
        io_pusle_times = 0; // Set to 0 for continuous pulse
        #10; // Wait for the clock edge
    end
    endtask

    // Testbench Stimulus
    initial begin
        // Initialize Inputs
        io_rst = 1'b1;
        io_en = 1'b0;
        io_defaultLevel = 0; // Set to 0 or 1 based on your design
        io_pulseWidth = 0;
        io_unaccessWidth = 0;
        io_pusle_times = 0;

        // Add stimulus here
        #20; // Wait for global reset
        io_rst = 1'b0;
        
        // Start finite pulse
        start_finite_pulse(10, 25, 15);
        #100;
        
        // // Stop pulse
        // stop_pulse();
        // #20;
        
        // // Start continuous pulse
        // start_continuous_pulse();
        // #100;
        
        // Finish simulation
        //$finish;
    end

endmodule