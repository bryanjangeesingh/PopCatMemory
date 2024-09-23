module tm_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out = 8'b0
  );

    
    always_comb begin
    if((data_in[7] + data_in[6] + data_in[5] + data_in[4] + data_in[3] + data_in[2] + data_in[1] + data_in[0]) > 4'd4 || ((data_in[7] + data_in[6] + data_in[5] + data_in[4] + data_in[3] + data_in[2] + data_in[1] + data_in[0]) == 4'd4 && data_in[0] == 1'b0)) begin
            for (integer i = 0; i < 8; i++) begin
                qm_out = {1'b0, ~(data_in[7:1] ^ qm_out[6:0]), data_in[0]};
            end
        end else begin
            for (integer i = 0; i < 8; i++) begin
                qm_out = {1'b1, (data_in[7:1] ^ qm_out[6:0]), data_in[0]};
            end
        end
    end


endmodule //end tm_choice

