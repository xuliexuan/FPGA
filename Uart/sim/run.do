quit -sim
.main clear

vlib work
vmap work work

vlog ./../uart_top.v 
vlog ./../clock_gen.v
vlog ./tb_clock_gen.v
vlog ./../uart_receiver.v
vlog ./../uart_transfer.v


vsim -voptargs=+acc work.tb_clock_gen  

add wave tb_clock_gen/uart_top_inst/clock_gen_inst/*
add wave tb_clock_gen/uart_top_inst/uart_receiver_inst/*
add wave tb_clock_gen/uart_top_inst/uart_transfer_inst/*
add wave tb_clock_gen/*

run 4ms