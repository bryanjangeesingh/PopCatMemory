`timescale 1ns / 1ps
`default_nettype none

module com_tb;

    //make logics for inputs and outputs!
    logic clk_in;
    logic rst_in;
    logic [10:0] x_in;
    logic [9:0] y_in;
    logic valid_in;
    logic tabulate_in;
    logic [10:0] x_out;
    logic [9:0] y_out;
    logic valid_out;

    center_of_mass uut(.clk_in(clk_in), .rst_in(rst_in),
                         .x_in(x_in),
                         .y_in(y_in),
                         .valid_in(valid_in),
                         .tabulate_in(tabulate_in),
                         .x_out(x_out),
                         .y_out(y_out),
                         .valid_out(valid_out));
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_in = !clk_in;
    end

    //initial block...this is our test simulation
    initial begin
        $dumpfile("com.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,com_tb); //store everything at the current level and below
        $display("Starting Sim"); //print nice message
        clk_in = 0; //initialize clk (super important)
        rst_in = 0; //initialize rst (super important)
        x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;

        //test case 1: frames one after the other - works 

        // for (int frame = 0; frame < 2; frame = frame + 1) begin
        //     for (int i = 0; i < 700; i = i + 1) begin
        //         x_in = i;
        //         y_in = 10;
        //         valid_in = 1;
        //         #10;
        //     end
        //     valid_in = 0;
        //     #100;
        //     tabulate_in = 1;
        //     #10;
        //     tabulate_in = 0;
        //     while (!valid_out) #10;
        // end

        //test case 2: 1 valid single pixel in a frame - works

        // x_in = 11'b10111011101; //random x pixel 
        // y_in = 10'b1111101010;  //random y pixel 
        // valid_in = 1;
        // #10;
        // valid_in = 0;
        // tabulate_in = 1;
        // #10000;
        // tabulate_in = 0;
        // #10000;

        //test case 3: maximum number of valid pixels in frame - works

        // for (int i = 0; i < 1024*768; i = i + 1) begin
        //     x_in = i % 1024;
        //     y_in = i % 768;
        //     valid_in = 1;
        //     #10;
        // end
        // valid_in = 0;
        // #100;
        // tabulate_in = 1;
        // #10000;

        //test case 4: no valid pixels with tabulate asserted - works

        // tabulate_in = 1;
        // #10;
        // tabulate_in = 0;
        // #100;  

        //test case 5: different x and y values - works 

        // for (int i = 0; i < 700; i = i + 1) begin
        //     x_in = i;
        //     y_in = 700 - i;
        //     valid_in = 1;
        //     #10;
        // end
        // valid_in = 0;
        // tabulate_in = 1;
        // #10;
        // tabulate_in = 0;
        // while (!valid_out) #10; 

        //joe's recommended test case

        // for (int i = 0; i<700; i = i+1)begin
        //   x_in = i;
        //   y_in = 10;
        //   valid_in = 1;
        //   #10;
        // end
        // valid_in = 0;
        // #100;
        // tabulate_in = 1;
        // #10000;

        $display("Finishing Sim"); //print nice message
        $finish;

    end
endmodule //counter_tb

`default_nettype wire