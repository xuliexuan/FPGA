`timescale 1ns/1ns
/* ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ 
Filename ﹕ uart_top.v
Author ﹕ lxxu
Description ﹕ uart top docuemnt
Called by ﹕Top module
Revision History ﹕
Revision 1.0
Email ﹕ liexuan.xu@robsense.com
Company ﹕ Robsense Technology .Inc
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ */
module uart_top(
    input wire              sclk, //100mhz
    input wire              rst_n,
    input wire              rxd,
    output wire             txd,

    input wire [7:0]        txd_data_i, //wait transfer data
    input wire              txd_en_i, //transfer data flag
    output wire             txd_flag_o, //transfer successful flag
    output wire [7:0]       rxd_data_o, //receiver data
    output wire             rxd_flag_o // receiver data flag

);

wire clk_16bps_en;
wire txd_data;

clock_gen 
#(
    // sys_clk      100MHz
    // f0 = sys_clk x k / 2^32 = 9600 x 16
    //k = DEVIDE_CNT = 42.94967296 x f0
    //.DEVIDE_CNT    (32'd175921860) //256000bps x 16
    //.DEVIDE_CNT    (32'd87960930) // 128000bps x 16
    //.DEVIDE_CNT    (32'd79164837) // 115200bps x 16
    .DEVIDE_CNT    (32'd6597069) // 9600bps x 16
)
clock_gen_inst(
    .clk            (sclk),
    .rst_n          (rst_n),
    .divide_clk     (),
    .divide_clk_en  (clk_16bps_en)
);

uart_receiver uart_receiver_inst(
    .clk            (sclk), 
    .rst_n          (rst_n),
    .clk_16_i       (clk_16bps_en),
    .rxd_i          (rxd),
    
    .rxd_data_o     (rxd_data_o),
    .rxd_flag_o     (rxd_flag_o)
);

uart_transfer uart_transfer_inst(
    .clk            (sclk),
    .rst_n          (rst_n),
    .clk_16_i       (clk_16bps_en),
    .txd_data_i     (txd_data_i),
    .txd_en_i       (txd_en_i),

    .txd_o           (txd),
    .txd_flag_o      (txd_flag_o)
);

endmodule