`timescale 1ns/1ns
/* ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ 
Filename ﹕ uart_transfer.v
Author ﹕ lxxu
Description ﹕ transfer data 
Called by ﹕Top module
Revision History ﹕
Revision 1.0
Email ﹕ liexuan.xu@robsense.com
Company ﹕ Robsense Technology .Inc
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ */
module uart_transfer(
    input wire          clk,
    input wire          rst_n,
    input wire          clk_16_i,
    input wire [7:0]    txd_data_i,
    input wire          txd_en_i,
    
    output reg          txd_o,
    output reg          txd_flag_o
);

localparam  T_IDLE = 2'b01,
            T_SEND = 2'b10;
localparam SMP_TOP  = 4'd15;
localparam SMP_GENTER = 4'd7;

reg [1:0]       state;
reg [3:0]       txd_cnt;
reg [3:0]       smp_cnt;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
        state <= T_IDLE;
    else begin
        case(state)
            T_IDLE:begin
                smp_cnt <= 4'd0;
                txd_cnt <= 4'd0;
                if(txd_en_i == 1'b1)
                    state <= T_SEND;
                else
                    state <= T_IDLE;
            end

            T_SEND:begin
                if(clk_16_i == 1'b1)begin
                    smp_cnt <= smp_cnt + 1'b1;
                    if(smp_cnt == SMP_TOP) begin
                        if(txd_cnt < 4'd9) begin
                            txd_cnt <= txd_cnt + 1'b1;
                            state <= T_SEND;
                        end
                        else begin
                            txd_cnt <= 1'b0;
                            state <= T_IDLE;
                        end
                    end
                    else begin
                        txd_cnt <= txd_cnt;
                        state <= state;
                    end
                end
                else begin
                    txd_cnt <= txd_cnt;
                    state <= state;
                end
            end
        endcase
    end
end 

always @(*)begin
    if(state == T_SEND)begin
        case(txd_cnt)
            4'd0:txd_o = 1'b0;
            4'd1:txd_o = txd_data_i[0];
            4'd2:txd_o = txd_data_i[1];
            4'd3:txd_o = txd_data_i[2];
            4'd4:txd_o = txd_data_i[3];
            4'd5:txd_o = txd_data_i[4];
            4'd6:txd_o = txd_data_i[5];
            4'd7:txd_o = txd_data_i[6];
            4'd8:txd_o = txd_data_i[7];
            4'd9:txd_o = 1'b1;
            default:txd_o = 1'b1;
        endcase
    end
    else 
        txd_o <= 1'b1;
end

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
        txd_flag_o <= 1'b0;
    else if(clk_16_i == 1'b1 && txd_cnt == 4'd9 && smp_cnt == SMP_TOP)
        txd_flag_o <= 1'b1;
    else 
        txd_flag_o <= 1'b0;
end
endmodule