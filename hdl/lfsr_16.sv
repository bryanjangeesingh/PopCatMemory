module lfsr_16 ( input wire clk_in, input wire rst_in,
                    input wire [15:0] seed_in,
                    output logic [15:0] q_out);

    always_ff @(posedge clk_in) begin
    if (rst_in) begin 
      q_out <= seed_in; 
    end else begin
      //q_out <= {q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[], q_out[]};
      q_out <= {q_out[14] ^ q_out[15], q_out[13:2], q_out[1] ^ q_out[15], q_out[0], q_out[15]};
    end 
  end 

endmodule

