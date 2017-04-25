module pwm(duty, clk, rst_n, PWM_sig);

input [9:0]duty;
input clk, rst_n;
output reg PWM_sig;

reg [9:0]cnt;
reg set, reset;

// counter with asynchronous reset
// sequential
always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		cnt <= 1'b0;
	else
		cnt <= cnt + 1'b1;
end

// sets or resets the ouput signal based on the value of count to duty with asynchronous reset 
// sequential
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n)
		PWM_sig <= 1'b0;
	else if (set)
		PWM_sig <= set;
	else if (reset)
		PWM_sig <= 1'b0; 
	else 
		PWM_sig <= PWM_sig;
end

// combinatinal logic that sets the reset or set flag depending on the counter's value
// combinational
always @ (*) begin
	reset = 0;
	set = 0;
	if (cnt == 10'h3FF) begin
		set = 1'b1;
	end
	else if (cnt == duty) begin
		reset = 1'b1;
	end
end

endmodule
