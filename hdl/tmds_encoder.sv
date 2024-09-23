`timescale 1ns / 1ps 
module tmds_encoder(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] data_in,  // video data (red, green or blue)
  input wire [1:0] control_in, //for blue set to {vs,hs}, else will be 0
  input wire ve_in,  // video data enable, to choose between control or video signal
  output logic [9:0] tmds_out
);
 
  logic [8:0] q_m;
  logic [3:0] ones_count, zeros_count; 
  logic [4:0] disparity = 0; 
 
  tm_choice mtm(
    .data_in(data_in),
    .qm_out(q_m));

always_comb begin
    ones_count = 0; 
    zeros_count = 0; 
    for (integer i = 0; i < 8; i++) begin 
        if (q_m[i] == 1) begin 
            ones_count = ones_count + 1;
        end 
    end 

    for (integer i = 0; i < 8; i++) begin 
        if (q_m[i] == 0) begin 
            zeros_count = zeros_count + 1;
        end 
    end 
end
 
  always_ff @(posedge clk_in) begin
    if (ve_in) begin 
        if (rst_in) begin
            tmds_out <= 0; 
        end else begin
        if ((disparity == 5'b00000) || (ones_count == zeros_count)) begin 
            disparity <= disparity + (q_m[8] == 0 ? (zeros_count - ones_count) : (ones_count - zeros_count));
            tmds_out <= {~q_m[8], q_m[8], q_m[8]? q_m[7:0]: ~q_m[7:0]}; 

        end else begin  //check positive here                          //check if it's negative here
            if ((disparity[4] == 0 && (ones_count > zeros_count)) || ((disparity[4] == 1) && (zeros_count > ones_count))) begin
                tmds_out <= {1'b1, q_m[8], ~q_m[7:0]};
                disparity <= disparity + {q_m[8], 1'b0} + (zeros_count - ones_count);
            end else begin
                tmds_out <= {1'b0, q_m[8], q_m[7:0]};
                disparity <= disparity - {~q_m[8], 1'b0} + (ones_count - zeros_count);
            end
        end 
    end 

    end else begin 
      if (rst_in) begin
        tmds_out <= 0; 
    end else begin
        disparity <= 0; 
        case (control_in) 
        2'b00: begin 
            tmds_out <= 10'b1101010100;
        end
        2'b01: begin 
            tmds_out <= 10'b0010101011; 
        end 
        2'b10: begin 
            tmds_out <= 10'b0101010100; 
        end 
        2'b11: begin
            tmds_out <= 10'b1010101011;  
        end  
        endcase  
    end 
    end 
  end
endmodule
 