`timescale 1ns / 1ps
`default_nettype none

module scale_tb;

    logic clk;
    logic rst;
    logic [1:0] scale_in;
    logic [10:0] hcount_in;
    logic [9:0] vcount_in;
    logic [10:0] scaled_hcount_out;
    logic [9:0] scaled_vcount_out;
    logic valid_addr_out;

    scale uut (
        .scale_in(scale_in),
        .hcount_in(hcount_in),
        .vcount_in(vcount_in),
        .scaled_hcount_out(scaled_hcount_out),
        .scaled_vcount_out(scaled_vcount_out),
        .valid_addr_out(valid_addr_out)
    );

  
    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("scale.vcd"); 
        $dumpvars(0, scale_tb); 
        $display("Starting Simulation");
        clk = 0; 
        rst = 0; 
        hcount_in = 0;
        vcount_in = 0;
        scale_in = 2'b00;
        #10;  
        rst = 1;
        #10;
        rst = 0;
        #10;
        scale_in = 2'b00; //1x scaling for now
        for (hcount_in = 0; hcount_in < 240; hcount_in = hcount_in + 1) begin
            for (vcount_in = 0; vcount_in < 320; vcount_in = vcount_in + 1) begin
                #1; 
            end
        end
        #10;
        $display("Finishing Simulation"); 
        $finish;
    end
endmodule

`default_nettype wire
