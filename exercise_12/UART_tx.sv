module UART_tx(clk, rst_n, TX, trmt, tx_data, tx_done);

input clk, rst_n, trmt;
input [7:0] tx_data;
output TX;
output reg tx_done;
reg load, shift, transmitting, set_done, clr_done;
reg [11:0] baud_cntr;	//counts up to 2603
reg [9:0] shift_reg;	//holds start, stop, and transmission data
reg [3:0] index_cntr;	//0 to 9 for bit transmitted

typedef enum reg {IDLE, TRANSMIT} state_t; //enumeration of states

state_t state, next_state; //state and next state for mealy machine



always @ (posedge clk, negedge rst_n) begin		// 16 bit shift register
	if (!rst_n)
		shift_reg <= 10'h3FF; //asynch reset shift register
	else begin
		if (load)
			shift_reg <= {1'b1, tx_data, 1'b0}; //load stop bit, start bit, and data to be transmitted when load is asserted
		else if (shift)
			shift_reg <= {1'b1, shift_reg[9:1]}; //right shift register on shift assertion
	end
end

always  @(posedge clk, negedge rst_n) begin //index counter
	if (!rst_n)
		index_cntr <= 4'h0;
	else begin
		if (load || (|index_cntr == 0))
			index_cntr <= 4'h9;
		else if (shift)
			index_cntr <= index_cntr - 1'b1;
	end
end

always @ (posedge clk, negedge rst_n) begin //baud counter
	if (!rst_n)
		baud_cntr <= 12'h000;
	else begin
		if (load || shift)
			baud_cntr <= 12'h000;
		else if (transmitting)
			baud_cntr <= baud_cntr + 1'b1;
	end
end


always @ (posedge clk, negedge rst_n) begin //tx_done flop
	if (!rst_n)
		tx_done <= 1'b0; //asynch reset
	else begin
		if(set_done)
			tx_done <= 1'b1; //tx_done is high when set_done is asserted
		else if (clr_done)
			tx_done <= 1'b0; //tx_done is low when clr_done is asserted
	end
end

assign shift = (baud_cntr == 12'hA2B); //assert shift when baud cnt reaches 50Mhz / 19.2k = 2603

assign TX = shift_reg[0]; //Transmitting data as LSB of shift reg

always @ (posedge clk, negedge rst_n) begin //state machine sequential behavior
	if (!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end

always @ (*) begin			//state transition and output logic
	set_done = 1'b0; //default outputs
	clr_done = 1'b0;
	load = 1'b0;
	transmitting = 1'b0;
	next_state = IDLE;
	case (state)
		IDLE:	
			if (trmt) begin			//if ready to transmit
				next_state = TRANSMIT;	//transition to TRANSMIT
				load = 1'b1;		//load shift reg 
				transmitting = 1'b1;	//set baud counter
				clr_done = 1'b1;	//clear tx_done flop with clr_done
			end
		TRANSMIT:

			if (|index_cntr == 0) begin	//if all 9 bits have been transmitted
				set_done = 1'b1;	//tx_done will be asserted on next clock edge
				next_state = IDLE; 	//return to idle state
			end
			else begin
				next_state = TRANSMIT; //continue transmitting if index cnt has not timed out
				transmitting = 1'b1;	//keep transmitting signal high
			end
	endcase
end



endmodule
