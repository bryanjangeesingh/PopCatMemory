`timescale 1ns / 1ps
`default_nettype none

module scale(
  input wire [1:0] scale_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  output logic [10:0] scaled_hcount_out,
  output logic [9:0] scaled_vcount_out,
  output logic valid_addr_out
);
  //always just default to scale 1
  //(you need to update/modify this to spec)!
  always_comb begin
    scaled_hcount_out = hcount_in;
    scaled_vcount_out = vcount_in;

    case (scale_in) 
    2'b00: begin 
      //1x scaling do nothing
    end 
    2'b01: begin 
      //undefined do nothing
    end 
    2'b10: begin
      scaled_hcount_out = hcount_in >> 2; //divide by 4 
      scaled_vcount_out = vcount_in >> 1; //divide by 2  
    end 
    2'b11: begin
      scaled_hcount_out = hcount_in >> 1; //divide by 2
      scaled_vcount_out = vcount_in >> 1; //divide by 2   
    end 
    endcase 
   
    valid_addr_out = ((scaled_hcount_out < 240) && (scaled_vcount_out < 320)); 
  end
  

endmodule


`default_nettype wire

