module SPI_mstr(clk, rst_n, wrt, cmd,
	 done, rd_data, SCLK, SS_n, MOSI, MISO);

input clk, rst_n, wrt, MISO; //clock, asynch reset, write initiailization signal, Master input slave output signal
input [15:0] cmd;	//input cmd loaded
output reg done, MOSI, SS_n; //slave select is active low
output logic [15:0] rd_data;	//ready data; only valid when done is asserted
output reg SCLK;	//Serial clock
logic SCLK_flip;

typedef enum reg [1:0] {IDLE, WAIT1, TRANSMIT, WAIT2} state_t; //state machine state enumeration

state_t state, next_state;

reg [15:0] shift_reg;				//16 bit shift register
reg [4:0] SCLK_counter; 			//Serial clock delay counter
reg [4:0] index_cntr; 				//index register to determine number of shifts
reg [2:0] back_porch_delay; 			//3 bit back porch counter for staggering between SS_n and enabling of SCLK
reg en_SCLK; 					//SCLK enable
reg load_delay; 				//load delay for back porch


always @ (posedge clk, negedge rst_n) begin 	//shift flop
	if (!rst_n)
		shift_reg <= 16'h0000;		//asynch reset
	else begin
		if (wrt) begin 			//if write is asserted
			shift_reg <= cmd; 	//load cmd into shift register
			index_cntr <= 5'h10;	 //load index counter register
		end
		if (SCLK && SCLK_flip) begin
			shift_reg <= {shift_reg[14:0], MISO};	//Sampling of MISO; ie shift in MISO into LSB
			if(|index_cntr != 0)	
				index_cntr <= index_cntr - 1'b1; //decrement index counter on SCLK posedge
		end
	end
end

always @ (posedge clk, negedge rst_n) begin 	//SCLK and SCLK counter
	if (!rst_n) begin
		SCLK <= 1'b1;			//asynch reset SCLK to high
		SCLK_counter <= 5'h0; 		//reset counter to 0
		SCLK_flip <= 1'b0;
	end
	else begin
		if (en_SCLK) begin 					//if SCLK is enabled
			if (|SCLK_counter != 0 ) begin 			//if counter has not timed out
				SCLK_counter <= SCLK_counter - 1'b1; 	//decrement SCLK counter
				SCLK_flip <= 1'b0;
			end
			else begin			//if counter has expired
				SCLK_counter <= 5'h10; 	//reset timer
				SCLK <= ~SCLK;		//flip SCLK signal
				SCLK_flip <= 1'b1;			
			end
		end
		else
			SCLK <= 1'b1;	//SCLK will remain high when not enabled
	end
end

always @ (posedge clk, negedge rst_n) begin //back porch delay flop; used to wait 4 cycles to stagger SS_n from SCLK_en
	if (!rst_n)
		back_porch_delay <= 3'h0; 
	else begin
		if (load_delay)
			back_porch_delay <= 3'h4; //load delay register
		else begin
			if (|back_porch_delay != 0)	//decrement back porch delay counter if not timed out
				back_porch_delay <= back_porch_delay - 1'b1;
		end
	end


end

/*
always  @(posedge clk, negedge rst_n) begin //index counter; indicates when transmission is complete
	if (!rst_n)
		index_cntr <= 5'h0;
	else begin
		if (SCLK && SCLK_flip) begin
			if(|index_cntr != 0)	
				index_cntr <= index_cntr - 1'b1; //decrement index counter on SCLK posedge
		end
	end
end
*/
/*
always @ (posedge clk, negedge rst_n) begin		//Sampling of MISO; ie shift in MISO into LSB
	if (SCLK && SCLK_flip) begin
		shift_reg <= {shift_reg[14:0], MISO};
	end
end
*/

always @ (posedge clk, negedge rst_n) begin	//Sample MOSI on posedge SCLK for Slave
	if(!rst_n)
		MOSI <= 1'b0;			//asynch reset: to get MOSI in a known value on reset
	else begin
		if (!SCLK && SCLK_flip) begin
			MOSI <= shift_reg[15];		//sample MSB of shift register into MOSI
		end
	end
end

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		rd_data <= 16'h0000;
	else begin
		if (done)
			rd_data <= shift_reg;
	end
end

//assign rd_data = shift_reg;					//rd_data will be shift register; only valid when done is asserted

always @ (posedge clk, negedge rst_n) begin 			//state machine sequential logic
	if (!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end


always @ (*) begin
	SS_n = 1'b0; 						//default outputs
	done = 1'b0;
	en_SCLK = 1'b0;
	load_delay = 1'b0;
	next_state = IDLE;
	case (state)
		IDLE:
			if(wrt) begin				//if wrt is asserted
				load_delay = 1'b1; 		//load back porch delay
				SS_n = 1'b0;			//assert active low Slave Select
				next_state = WAIT1; 		//transition to WAIT1 state
			end
			else
				SS_n = 1'b1;			//keep Slave select high when idle
		WAIT1:
			if (back_porch_delay == 0) begin 	//if back porch delay has timed out
				en_SCLK = 1'b1;			//enabled SCLK
				next_state = TRANSMIT;		//transition to transmitting state
			end
			else
				next_state = WAIT1;		//stay in Wait state until porch delay has expired
		TRANSMIT:
			if (index_cntr == 0) begin 		//all 16 bits have been transmitted
				en_SCLK = 1'b0; 		//disable SCLK
				load_delay = 1'b1; 		//load back porch delay
				done = 1'b1;			//data is ready
				next_state = WAIT2; 		//transition to Wait 2 state
			end
			else begin
				next_state = TRANSMIT; 		//wait until all 16 bits hav ebeen transmitted
				en_SCLK = 1'b1; 		//enable SCLK
			end
		WAIT2:
			if (back_porch_delay == 0) begin 	//if back porch delay has expired
				SS_n = 1'b1;			//deassert active low SS_n
				next_state = IDLE;		//transition to IDLE state
			end
			else
				next_state = WAIT2; 		//wait until back porch delay expires
		
	endcase
end


endmodule
