module UART_tx_tb();

reg clk, rst_n, trmt;
reg [7:0] tx_data;
wire tx_done, TX;


//initiailize DUT
UART_tx DUT(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));
//UART_test DUT(.clk(clk), .RST_n(rst_n), .TX(TX));
initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	tx_data = 8'h9A; //transmitted data 1001 1010
	rst_n = 0;	//assert reset
	@ (posedge clk);
	@ (negedge clk);
	rst_n = 1; 	//deassert reset
	trmt = 1'b1; 	//start tranmission procedure
	@ (negedge clk);
	trmt = 1'b0; 	//deassert transmission signal
	#268000;	//wait until transmission is complete
	tx_data = 8'b10110010;
	@ (negedge clk);
	trmt = 1'b1;	//start up next tranmission
	@ (negedge clk);
	trmt = 1'b0;	//deassert tranmission signal
	#268000;	//wait until tranmission is complete
	$stop;


end



endmodule
