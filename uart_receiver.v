`timescale 1ns/1ns
/* ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ 
Filename ﹕ uart_receiver.v
Author ﹕ lxxu
Description ﹕ receibe data 
Called by ﹕Top module
Revision History ﹕
Revision 1.0
Email ﹕ liexuan.xu@robsense.com
Company ﹕ Robsense Technology .Inc
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝ */
module uart_receiver(
    input wire              clk,
    input wire              rst_n,
    input wire              clk_16_i, // f0 x16
    input wire              rxd_i,

    output reg [7:0]        rxd_data_o,
    output reg              rxd_flag_o

);

localparam  R_IDLE = 4'b0001,
            R_START = 4'b0010,
            R_SAMPLE = 4'b0100,
            R_STOP = 4'b1000;
reg [3:0]   state;   
//sync rxd_i data 
reg     rxd_sync;
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
        rxd_sync <= 1'b1;
    else
        rxd_sync <= rxd_i;
end

//fsm
reg [3:0]   rxd_cnt;
reg [3:0]   smp_cnt;
localparam SMP_TOP  = 4'd15;
localparam SMP_GENTER = 4'd7;

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
        state <= R_IDLE;
    else begin
        case(state)
            R_IDLE:begin
                rxd_cnt <= 4'd0;
                smp_cnt <= 4'd0;
                if (rxd_sync == 1'b0)
                    state <= R_START;
                else  
                    state <= R_IDLE;
            end

            R_START:begin
                if(clk_16_i == 1'b1)begin
                    smp_cnt <= smp_cnt + 1'b1;
                    if(smp_cnt == SMP_GENTER && rxd_sync != 1'b0) begin
                        rxd_cnt <= 4'd0;
                        state <= R_IDLE;
                    end
                    else if(smp_cnt == SMP_TOP) begin
                        rxd_cnt <= 4'd1;
                        state <= R_SAMPLE;
                    end
                    else begin
                        rxd_cnt <= 4'd0;
                        rxd_cnt <= R_START;
                    end 
                end
                else begin
                    smp_cnt <= smp_cnt;
                    state <= state;
                end 
            end

            R_SAMPLE:begin
                if(clk_16_i == 1'b1) begin
                    smp_cnt <= smp_cnt + 1'b1;
                    if(smp_cnt == SMP_TOP) begin
                        if(rxd_cnt < 4'd8) begin
                            rxd_cnt <= rxd_cnt + 1'b1;
                            state <= R_SAMPLE;
                        end 
                        else begin
                            rxd_cnt <= 4'd9;
                            state <= R_STOP;
                        end
                    end
                    else begin
                        rxd_cnt <= rxd_cnt;
                        state <= state;
                    end 
                end
                else begin
                    smp_cnt <= smp_cnt;
                    rxd_cnt <= rxd_cnt;
                    state <= state;
                end
            end

            R_STOP:begin
                if(clk_16_i == 1'b1) begin
                    smp_cnt <= smp_cnt + 1'b1;
                    if(smp_cnt == SMP_TOP) begin
                        state <= R_IDLE;
                        rxd_cnt <= 1'b0;
                    end
                    else begin
                        rxd_cnt <= rxd_cnt;
                        state <= state;
                    end 
                end
                else begin
                    smp_cnt <= smp_cnt;
                    rxd_cnt <= rxd_cnt;
                    state <= state;
                end
            end
            default:
                state <= R_IDLE;
        endcase
    end 
end

reg [7:0]   rxd_data_r;
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
        rxd_data_r <= 8'd0;
    else if(state == R_SAMPLE)begin
        if(clk_16_i == 1'b1 && smp_cnt == SMP_GENTER) begin
            case(rxd_cnt)
            4'd1: rxd_data_r[0] <= rxd_sync;
            4'd2: rxd_data_r[1] <= rxd_sync;
            4'd3: rxd_data_r[2] <= rxd_sync;
            4'd4: rxd_data_r[3] <= rxd_sync;
            4'd5: rxd_data_r[4] <= rxd_sync;
            4'd6: rxd_data_r[5] <= rxd_sync;
            4'd7: rxd_data_r[6] <= rxd_sync;
            4'd8: rxd_data_r[7] <= rxd_sync;
            default:;
            endcase
        end
        else
            rxd_data_r <= rxd_data_r;
    end
    else if(state == R_STOP)
        rxd_data_r <= rxd_data_r;
    else 
        rxd_data_r <= 8'd0;
end


always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0) begin
        rxd_data_o <= 8'd0;
        rxd_flag_o <= 1'b0;
    end
    else if(clk_16_i == 1'b1 && rxd_cnt == 4'd9 && smp_cnt == SMP_TOP) begin
        rxd_data_o <= rxd_data_r;
        rxd_flag_o <= 1'b1;
    end
    else begin
        rxd_data_o <= rxd_data_o;
        rxd_flag_o <= 1'b0;
    end 
end


endmodule