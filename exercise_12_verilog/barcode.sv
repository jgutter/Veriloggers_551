module barcode(clk, rst_n, BC, ID_vld, clr_ID_vld, ID);

input clk, rst_n, BC, clr_ID_vld;
output logic ID_vld;
output logic [7:0] ID;

typedef enum reg [3:0] {IDLE, GET_TIME, SAMPLE, WAIT} state_t;
state_t state, next_state;
logic set_ID_vld, get_half_period, shift, done, sampling, load, full_time;
logic BC_1, BC_sync;
logic [21:0] bit_half_period; //22 bit counter to hold period of BC signal & sample timer
logic [22:0] bit_period, sample_timer;
logic [7:0] shift_reg;
logic [3:0] index_cnt; //count number of shifts that has occurred



always @(posedge clk, negedge rst_n) begin //ID_vld flop
	if(!rst_n)
		ID_vld <= 1'b0;
	else begin
		if (clr_ID_vld)
			ID_vld <= 1'b0;
		else if (set_ID_vld)
			ID_vld <= 1'b1;
	end
end

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		BC_1 <= 1'b0;
		BC_sync <= 1'b0;
	end
	else begin
		BC_1 <= BC;
		BC_sync <= BC_1;
	end
end

always @(posedge clk, negedge rst_n) begin //state machine sequential logic
	if(!rst_n)
		state <= IDLE;
	else begin
		state <= next_state;
	end
end

always @(posedge clk, negedge rst_n) begin //initial half period determined by duration of low start bit
	if(!rst_n)
		bit_half_period <= 22'h000000;
	else begin
		if (done)
			bit_half_period <= 22'h000000;
		else if (get_half_period)
			bit_half_period <= bit_half_period + 1'b1;
	end
end

assign bit_period = bit_half_period + bit_half_period - 2'h2; //full bit period = half_period + half_period

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		shift_reg <= 8'h00;
	else begin
		if (shift)
			shift_reg <= {shift_reg[6:0], BC_sync}; //Sample BC into LSB on shift signal
	end
end

always @(posedge clk, negedge rst_n) begin //output ID flop
	if(!rst_n)
		ID <= 8'h00;
	else begin
		if (done)			//load ID with shift register if done decoding
			ID <= shift_reg;
	end
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		index_cnt <= 4'h8;
	else begin
		if (get_half_period)	//reset index count on start bit condition
			index_cnt <= 4'h8;
		if (shift)		//decrement index count on shift signal
			index_cnt <= index_cnt - 1'b1;
	end
end

always @(posedge clk, negedge rst_n) begin //sample timer
	if(!rst_n)
		sample_timer <= 22'h3FFFFF;
	else begin
		if (done)
			sample_timer <= 22'h3FFFFF;
		else if (load)
			sample_timer <= bit_period;
		else if (sampling)
			sample_timer <= sample_timer - 1'b1;
	end
end

assign shift = (sample_timer == bit_half_period);
assign full_time = (|sample_timer == 0);

always_comb begin
	set_ID_vld = 1'b0;
	next_state = IDLE;
	get_half_period = 1'b0;
	done = 1'b0;
	sampling = 1'b0;
	load = 1'b0;
	case (state)
		IDLE:
			if (BC == 1'b0) begin	//if start bit has occured
				get_half_period = 1'b1; //start timing duration of a half period
				next_state = GET_TIME;	//transition to GET_TIME to determine bit period
			end
		GET_TIME:
			if (BC == 1'b1) begin 		//when BC goes high
				next_state = WAIT; 	//go to WAIT state 
			end
			else begin 			//if BC is still low
				get_half_period = 1'b1;
				next_state = GET_TIME;
			end
		WAIT:
			if (|index_cnt == 0) begin //if all 8 bits have been read
				done = 1'b1;
				set_ID_vld = 1'b1;
				next_state = IDLE;
			end
			else if (BC == 1'b0) begin	//if all 8 bits have not been read and BC goes low
				next_state = SAMPLE;	//transition to SAMPLE
				sampling = 1'b1;	//start sampling timer
				load = 1'b1;
			end
			else begin
				next_state = WAIT;	//stay in wait state until BC goes low
			end
		SAMPLE:
			if (full_time) begin//when BC is sampled (shift is asserted) transition to WAIT state
				next_state = WAIT;
			end
			else begin
				sampling = 1'b1;	//continue sampling until sampling timer matches bit_half_period
				next_state = SAMPLE;
			end
	endcase
end


endmodule
