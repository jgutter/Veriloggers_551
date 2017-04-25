module cmd_ctrl( cmd, cmd_rdy, OK2Move, ID, ID_vld, clk, rst_n, 
	clr_cmd_rdy, clr_ID_vld, in_transit, go, buzz, buzz_n);

// inputs
input [7:0]cmd; // command from the UART
input cmd_rdy; // command is ready to be used
input OK2Move; // set if there is an obstabcle, otherwise 0
input [7:0]ID; // station ID
input ID_vld; // validates the station ID
input clk, rst_n;

// outputs
output clr_cmd_rdy;
output clr_ID_vld;
output reg in_transit; // set when state is changed from GO to STOP
output go; // controls motion controller to move forward
output buzz; //signal used when an obstacle is found
output buzz_n; // inverse of the above signal, 

// reg
reg [5:0]dest_ID;
reg ld_dest_ID;
reg set_transit;
reg clr_transit;

// states
reg state;
reg nxt_state;

// parameter
localparam STOP_STATE = 1'b0;
localparam GO_STATE = 1'b1;

localparam STOP_SIG = 2'b00;
localparam GO_SIG = 2'b01;

// state transitions
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= STOP_STATE;
	else 
		state <= nxt_state;
end

// flip flop for in transit
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		in_transit <= 1'b0;
	else begin
		if (set_transit)
			in_transit <= 1'b1;
		else if(clr_transit)
			in_transit <= 1'b0;
	end
end

// flip flop for dest_ID
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		dest_ID <= 6'b000000;
	else begin
		if (ld_dest_ID)
			dest_ID <= cmd[5:0];
	end
end

// flip flop for clr_cmd_rdy
/*always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		clr_cmd_rdy <= 1'b0;
	else begin
		if (ld_clr_cmd_rdy)
			clr_cmd_rdy <= 1'b1;
	end
end*/

// flip flops for Piezo Buzzer divider
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		go <= 1'b0;
		buzz <= 1'b0;
		buzz_n <= 1'b1;
	end
	else begin
		go <= in_transit & OK2Move;
		buzz <= (~OK2Move & in_transit);
		buzz_n <= ~(~OK2Move & in_transit);
	end
end


always@(*) begin

case(state)
	STOP_STATE: begin
		if (cmd_rdy && cmd[7:6] == GO_SIG) begin
			set_transit = 1'b1;
			ld_dest_ID = 1'b1;
			clr_cmd_rdy = 1'b1;
			nxt_state = GO_STATE;
		end
		//else if
	
	end

	GO_STATE: begin
		if () begin
		end
		else if (cmd_rdy && cmd[7:6] == GO_SIG)

	end

	default: begin
		ld_in_transit = 1'b0;
		clr_cmd_rdy = 1'b0;
		set_transit = 1'b0;
		clr_transit = 1'b0;
	end


endcase

end


endmodule
