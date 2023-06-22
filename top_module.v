`timescale 1ns / 1ps

module top_module(
    input clk,
    input [7:0] sw, //8 bits input
    input btn0, //reset button
    input btn1, //transmit button
    input RxD, //received data
    input reset,
    output TxD, //transmitted data
    output [7:0] led_data, //8 bits output display
    output transmit,
    output clk_o
    ); 
    
    wire transmit_signal; 
    assign transmit_signal = transmit;
    assign clk_o = clk;
    
    transmitter_top T3(.clk_debug(clk_o), .btn0(btn0), .btn1(btn1), .transmit_debug(transmit_signal), .TxD_debug(TxD), .sw(sw));
    receiver R1(.clk(clk_o), .RxD(RxD), .reset(reset), .led_data(led_data));
    
endmodule
