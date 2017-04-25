module uart_rcv(rx_data, clk, RX, clr_rx_rdy, rx_rdy, rst_n);

input clk, rst_n, clr_rx_rdy, RX;
output logic [7:0]rx_data;
output logic rx_rdy;
logic RX_1, RX_synch, rx_done;		//double flop RX to synch the signal
logic [9:0] shift_reg; //shift register to sample RX
logic [11:0] baud_counter; //1302 after falling edge start bit; 2604 for remaining byte
logic shift, receiving, load_start; //signal to load baud counter for standard 2604 and load_start for 1302
logic [3:0] index_cnt; //count number of shifts completed

typedef enum logic {IDLE, RECEIVE} state_t; //enumeration of states
state_t state, next_state;

always @ (posedge clk, negedge rst_n) begin //10 bit shift register
	if (!rst_n)
		shift_reg <= 10'h000; //asynch reset
	else begin
		if(shift || load_start)
			shift_reg <= {RX_synch, shift_reg[9:1]}; //shift in synched RX
	end
end

always @ (negedge clk, negedge rst_n) begin //double flop to synch RX
	if (!rst_n) begin		//asynch reset both flops
		RX_1 <= 1'b1;
		RX_synch <= 1'b1;
	end
	else begin
		RX_1 <= RX;
		RX_synch <= RX_1;
	end
end

always @ (posedge clk, negedge rst_n) begin //baud counter register (count down)
	if (!rst_n)
		baud_counter <= 12'hFFF; //asynch reset baud register
	else begin
		if (load_start)				//1302 baud rate for start bit cycle
			baud_counter <= 12'h516;
		else if (shift)				//2604 baud rate for received byte
			baud_counter <= 12'hA2C;
		else if (receiving)
			baud_counter <= baud_counter - 1'b1; //decrement baud counter when receiving
	end
end

always @ (posedge clk, negedge rst_n) begin //cmd flop & rx_rdy; assigned when all 10 bits have been received
	if (!rst_n) begin
		rx_data <= 7'h00; //asynch reset cmd reg
		rx_rdy <= 1'b0;
	end
	else begin
		if (clr_rx_rdy)
			rx_rdy <= 1'b0;
		if (rx_done) begin //if all 10 bits of RX signal has been received
			rx_data <= shift_reg[8:1]; //send byte of data to cmd register
			rx_rdy <= 1'b1;
		end
	end

end

always @ (posedge clk, negedge rst_n) begin //index count register
	if (!rst_n)
		index_cnt <= 4'hA; //asynch reset for next received signal
	else begin
		if (load_start)
			index_cnt <= 4'hA;
		else if (shift)
			index_cnt <= index_cnt - 1'b1;
	end
end

assign shift = (baud_counter == 12'h000);
/*
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)

end
*/
always @ (posedge clk, negedge rst_n) begin //sequential state logic
	if (!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end

always_comb begin
	receiving = 1'b0;
	load_start = 1'b0;
	rx_done = 1'b0;
	next_state = IDLE;
	case (state)
		IDLE:
			if (RX_synch == 1'b0) begin
				load_start = 1'b1; //load index
				next_state = RECEIVE; //enter receive state
				receiving = 1'b1; //start counting down baud
			end
		RECEIVE:
			if (|index_cnt == 0) begin //if all bits have been received
				rx_done = 1'b1;		//assert signal to send byte to cmd
				next_state = IDLE;	//enter idle state
			end
			else begin
				next_state = RECEIVE;		//continue receiving if not done
				receiving = 1'b1;
			end
	endcase

end




endmodule
