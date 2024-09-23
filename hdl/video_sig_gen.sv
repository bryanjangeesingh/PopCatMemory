module video_sig_gen
#(
  parameter ACTIVE_H_PIXELS = 1280,
  parameter H_FRONT_PORCH = 110,
  parameter H_SYNC_WIDTH = 40,
  parameter H_BACK_PORCH = 220,
  parameter ACTIVE_LINES = 720,
  parameter V_FRONT_PORCH = 5,
  parameter V_SYNC_WIDTH = 5,
  parameter V_BACK_PORCH = 20)
(
  input wire clk_pixel_in,
  input wire rst_in,
  output logic [$clog2(TOTAL_PIXELS)-1:0] hcount_out,
  output logic [$clog2(TOTAL_LINES)-1:0] vcount_out,
  output logic vs_out,
  output logic hs_out,
  output logic ad_out,
  output logic nf_out,
  output logic [5:0] fc_out);

  localparam TOTAL_PIXELS = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH; 
  localparam TOTAL_LINES = ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH; 

   logic [$clog2(TOTAL_PIXELS)-1:0] hcount; 
   logic [$clog2(TOTAL_LINES)-1:0] vcount; 
   logic [5:0] frame_count; 
   logic new_frame; 

   always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
        hcount <= 0; 
        vcount <= 0; 
        frame_count <= 0; 
        new_frame <= 0; 
        hcount_out <= 0;
        vcount_out <= 0;
        hs_out <= 0;
        nf_out <= 0;
        fc_out <= 0;
        ad_out <= 0;

    end else begin 
        if (hcount == TOTAL_PIXELS - 1) begin
            hcount <= 0;
            if (vcount == TOTAL_LINES - 1) begin
                vcount <= 0; 
            end else begin
                vcount <= vcount + 1; 
                new_frame <= 0;  
            end 
        end else begin 
            hcount <= hcount + 1; 
            new_frame <= 0; 
        end 
        if (vcount == ACTIVE_LINES && hcount == ACTIVE_H_PIXELS - 1) begin
            new_frame <= 1; 
            frame_count <= frame_count + 1; 
        end else begin
            new_frame <= 0;
        end
        vcount_out <= vcount;
        hcount_out <= hcount; 
        nf_out <= new_frame; 
        fc_out <= frame_count; 

        vs_out <= (vcount > (ACTIVE_LINES + V_FRONT_PORCH - 1)) && (vcount < (ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH));
        hs_out <= (hcount > (ACTIVE_H_PIXELS + H_FRONT_PORCH - 1)) && (hcount < (ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH));
        ad_out <= (hcount < ACTIVE_H_PIXELS) && (vcount < ACTIVE_LINES);
    end 
   end


endmodule
