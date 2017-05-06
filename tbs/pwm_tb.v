module pwm_tb();

reg [9:0] duty;
reg clk, rst_n;
wire PWM_sig;

pwm iDUT(.duty(duty), .clk(clk), .rst_n(rst_n), .PWM_sig(PWM_sig));

initial clk = 0;

always #5 clk = ~clk;	//initialize clock

initial begin
	rst_n = 1'b0;	//reset flops
	duty = 10'h005;	//set duty value
	#2;
	rst_n = 1'b1;	//deassert reset
	#10300;		//delay to observe proper PWM behavior
	$stop;
end

endmodule
