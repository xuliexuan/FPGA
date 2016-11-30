`timescale 1ns/1ns
module tb_clock_gen();
reg tb_clk;
reg rst_n;
reg [7:0]   tb_txd_data_i;
reg txd_en_i;
wire clk2;
wire txd_flag_o;

//100MHZ
always #5 tb_clk = ~tb_clk;


///////testbeach receiver///////////////////
// initial begin
//     rxd_i <= 1;
//     tb_clk <= 0;
//     rst_n <= 0;
//     #100
//     rst_n <= 1;
//     #12345;
//     task_uart_txd(8'hCB);

// end



// wire uart_bps_en = clk2;
// task task_uart_txd;
//     input [7:0] uart_data;
//     begin
//         @(posedge uart_bps_en);
//         rxd_i = 0;
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[0];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[1];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[2];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[3];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[4];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[5];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[6];
//         @(posedge uart_bps_en);
//         rxd_i = uart_data[7];
//         @(posedge uart_bps_en);
//         rxd_i = 1;
//         #78;
//     end 
// endtask
///////////testbeach transfer////////////////
initial begin
    tb_clk <= 0;
    rst_n <= 0;
    txd_en_i <= 0;
    #100;
    rst_n <= 1;
end

initial begin
    #200;
    txd_en_i <= 1;
    tb_txd_data_i <= 8'hCB;
    @(posedge txd_flag_o);
    txd_en_i <= 0;
    #1500000;
    txd_en_i <= 1;
    tb_txd_data_i <= 8'h7B;
    @(posedge txd_flag_o);
    txd_en_i <= 0;
    #200;

end

clock_gen 
#(
    .DEVIDE_CNT    (32'd6597069) // 9600bps x 16
)
clock_gen_tb(
    .clk            (tb_clk),
    .rst_n          (rst_n),
    .divide_clk     (),
    .divide_clk_en  (clk2)
);

wire        txd_data;
uart_top uart_top_inst(
    .sclk           (tb_clk),
    .rst_n          (rst_n),
    .txd_data_i     (tb_txd_data_i),
    .txd_en_i       (txd_en_i),
    .txd_flag_o     (txd_flag_o),

    .rxd            (txd_data),
    .txd            (txd_data)
);

endmodule 