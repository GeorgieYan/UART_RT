`timescale 1ns / 1ps

module transmitter(
    input clk, 
    input reset, 
    input transmit_signal, //btn signal to trigger the UART communication
    input [7:0] data, // data transmitted
    output reg TxD // Transmitter serial output. TxD will be held high during reset, or when no transmissions aretaking place. 
    );

    reg state, next_state, shift, load, clear; // initial & next state variable
    reg [3:0] bitcounter; //4 bits counter to count up to 10
    reg [13:0] counter; //14 bits counter to count the baud rate, counter = clock / baud rate
    reg [9:0] reg_shift; 
    
    // transmitter 
    always @(posedge clk) begin 
        if(reset) begin // reset 
            state <= 0; 
            counter <= 0; 
            bitcounter <= 0; 
        end
        else begin
            counter <= counter + 1; // counter for baud rate generator 
            if (counter >= 10415) begin // 10415 for 100 MHz Basys 3 board 
                state <= next_state; 
                counter <= 0; 
            	if(load) 
            	   reg_shift <= {1'b1, data, 1'b0}; // load the data 
		        if(clear) 
		           bitcounter <=0; // reset 
                if(shift) begin 
                   reg_shift <= reg_shift >> 1; // shift right one bit 
                   bitcounter <= bitcounter + 1; 
                end
            end
        end
    end 
    
    // state machine 
    always @(posedge clk) begin 
        load <= 0; 
        shift <= 0; 
        clear <= 0; 
        TxD <= 1; 
        case(state)
            0: begin // idle state
                if (transmit_signal) begin 
                    next_state <= 1; // set to transmitting state
                    load <= 1; // set load to high 
                    shift <= 0; // no shift 
                    clear <= 0; // no clearing counter 
                end 
		        else begin // back to idle state
                    next_state <= 0; 
                    TxD <= 1; 
                end
            end
           
            1: begin // transmitting state 
                if (bitcounter >= 10) begin // transmission is complete 
                    next_state <= 0; // set back to idle state
                    clear <= 1; // set clear high to clear counters
                end 
		        else begin // tranismitting is not complete 
                    next_state <= 1; // continue in transmitting state 
                    shift <= 1; // set shift to high 
                    TxD <= reg_shift[0]; // shift the bit 
                end
           end
           
           default: next_state <= 0;                      
        endcase
end    

endmodule

