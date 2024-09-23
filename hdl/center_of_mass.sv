`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

    logic [31:0] sum_x, sum_y, count, avg_x, avg_y;
    //make 2 variables to know when the division process is over
    logic divide_x_done, divide_y_done;
    logic x_ready, y_ready; 
    
    typedef enum {IDLE=0, ACCUMULATE=1, START_DIVIDING=2, OUTPUT=3} major_fsm_s;
    major_fsm_s major_fsm_state;


    divider #(32) divide_x (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .dividend_in(sum_x),
        .divisor_in(count),
        .data_valid_in(major_fsm_state == START_DIVIDING),
        .quotient_out(avg_x),
        .remainder_out(),
        .data_valid_out(divide_x_done),
        .error_out(),
        .busy_out()
    );

    divider #(32) divide_y (
        .clk_in(clk_in),
        .rst_in(rst_in),
        .dividend_in(sum_y),
        .divisor_in(count),
        .data_valid_in(major_fsm_state == START_DIVIDING),
        .quotient_out(avg_y),
        .remainder_out(),
        .data_valid_out(divide_y_done),
        .error_out(),
        .busy_out()
    );

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            major_fsm_state <= IDLE;
            sum_x <= 0;
            sum_y <= 0;
            x_out <= 0;
            y_out <= 0;
            count <= 0;
            valid_out <= 0;
            x_ready <= 0;
            y_ready <= 0; 
        end else begin
            case (major_fsm_state)
                IDLE: begin
                    //for every valid pixel, start accumulating a x running sum and a y running sum
                    if (valid_in) begin
                        major_fsm_state <= ACCUMULATE;
                        sum_x <= x_in;
                        sum_y <= y_in;
                        count <= 1; //count the # of 'on' pixels 
                    end
                end
                ACCUMULATE: begin
                    if (valid_in) begin
                        sum_x <= sum_x + x_in;
                        sum_y <= sum_y + y_in;
                        count <= count + 1;
                    end
                    if (tabulate_in) begin
                        major_fsm_state <= START_DIVIDING;
                    end
                end
                START_DIVIDING: begin

                    //we need to check if new data is coming in. 
                    // if (valid_in) begin
                    //     sum_x <= sum_x + x_in;
                    //     sum_y <= sum_y + y_in;
                    //     count <= count + 1;
                    // end

                    if (divide_x_done) begin 
                      x_ready <= 1; 
                    end 

                    if (divide_y_done) begin
                      y_ready <= 1; 
                    end 

                    if (x_ready && y_ready) begin
                        major_fsm_state <= OUTPUT;
                    end
                end
                OUTPUT: begin
                    major_fsm_state <= IDLE;
                    x_out <= avg_x;
                    y_out <= avg_y;
                    valid_out <= 1;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
