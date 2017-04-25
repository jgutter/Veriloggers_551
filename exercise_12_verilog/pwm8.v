module pwm8(PWM_sig, duty, clk, rst_n);

input [7:0] duty;
input clk, rst_n;
output reg PWM_sig;
reg set, reset;
reg [7:0] cnt;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		PWM_sig <= 1'b0;	//asynch reset behavior
	else begin
		if (set)
			PWM_sig <= 1'b1;	//set PWM_sig high when cnt reaches maximum value
		else if (reset)
			PWM_sig <= 1'b0;	//set PWM_sig low when cnt reaches duty value
		else
			PWM_sig <=  PWM_sig;	//recirculate if no conditions are met
	end
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		cnt <= 0;	//asynch reset of counter flop
	else
		cnt <= cnt + 1'b1;	//synchronous counter flop
end


always@ (*) begin
	set = 1'b0; //default outputs to ensure combinational logic
	reset = 1'b0;
 	if (cnt == duty) begin	//assert reset when cnt is equal to duty
		reset = 1'b1;
	end
	if (cnt == 8'hFF) begin	//assert set when cnt is equal to maximum value 10'h3FF
		set = 1'b1;	
	end	
end

endmodule
