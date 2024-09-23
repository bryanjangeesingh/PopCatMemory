`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module image_sprite #(
  parameter WIDTH=256, HEIGHT=256) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire pop_in, 
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

   //################### PS10 START - delay by 4 clock cycles ####################
  
  logic [10:0] hcount_in_pipe [3:0]; 
  logic [10:0] x_in_pipe [3:0]; 

  logic [9:0] vcount_in_pipe [3:0]; 
  logic [9:0] y_in_pipe [3:0];   
  

  always_ff @(posedge pixel_clk_in) begin
    hcount_in_pipe[0] <= hcount_in; 
    vcount_in_pipe[0] <= vcount_in; 
    x_in_pipe[0] <= x_in; 
    y_in_pipe[0] <= y_in; 
    
    for (int i=1; i<4; i = i+1) begin
     hcount_in_pipe[i] <= hcount_in_pipe[i-1];
     vcount_in_pipe[i] <= vcount_in_pipe[i-1];
     x_in_pipe[i] <= x_in_pipe[i-1];
     y_in_pipe[i] <= y_in_pipe[i-1]; 
  end
  
  end
  //################### PS10 end -  ###############################################

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT*2)-1:0] base_addr;
  assign base_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic [$clog2(WIDTH*HEIGHT*2)-1:0] image_addr;
  assign image_addr = pop_in? base_addr + 17'd65536 : base_addr; 

  logic in_sprite;
  assign in_sprite = ((hcount_in_pipe[3] >= x_in_pipe[3] && hcount_in_pipe[3] < (x_in_pipe[3] + WIDTH)) &&
                      (vcount_in_pipe[3] >= y_in_pipe[3] && vcount_in_pipe[3] < (y_in_pipe[3] + HEIGHT)));


  logic [7:0] image_data; 
  logic [23:0] palette_data; 

  // Modify the module below to use your BRAMs!
  assign red_out =    in_sprite ? palette_data[23:16] : 8'h00;
  assign green_out =  in_sprite ? palette_data[15:8] : 8'h00;
  assign blue_out =   in_sprite ? palette_data[7:0] : 8'h00;

  

  // The following is an instantiation template for xilinx_single_port_ram_read_first
  //  Xilinx Single Port Read First RAM
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(8),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(image.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) image_rom (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(image_data)      // RAM output data, width determined from RAM_WIDTH
  );

   xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(24),                       // Specify RAM data width
    .RAM_DEPTH(256),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(palette.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
   ) palette_rom (
    .addra(image_data),     // Address bus, width determined from RAM_DEPTH
    .dina(24'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(palette_data)      // RAM output data, width determined from RAM_WIDTH
  );

endmodule



`default_nettype none

