`timescale 1ns/1ns
/* ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ 
Filename ﹕ clock_gen.v
Author ﹕ lxxu
Description ﹕ some different clock generate
Called by ﹕Top module
Revision History ﹕
Revision 1.0
Email ﹕ liexuan.xu@robsense.com
Company ﹕ Robsense Technology .Inc
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ */

module clock_gen(
    input wire              clk,
    input wire              rst_n,
    output wire             divide_clk,
    output wire             divide_clk_en
);

parameter DEVIDE_CNT;

reg [31:0]      cnt;
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
        cnt <= 32'b0;
    else 
        cnt <= cnt + DEVIDE_CNT;
end

reg cnt_equal;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        cnt_equal <= 1'b0;
    else if (cnt < 32'h7FFF_FFFF) //7FFF_FFFF is 2^32 -1 half
        cnt_equal <= 1'b0;
    else 
        cnt_equal <= 1'b1;
end

//posedge detection
reg cnt_equal_r;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        cnt_equal_r <= 1'b0;
    else
        cnt_equal_r <= cnt_equal;
end
assign divide_clk = cnt_equal_r;
assign divide_clk_en = (~cnt_equal_r & cnt_equal)? 1'b1 : 1'b0;

endmodule 