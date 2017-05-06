module barcode_tb();

reg clk, rst_n, clr_ID_vld, send;
wire ID_vld, BC, BC_done;
wire [7:0] ID;
reg [21:0] period;
reg [7:0] station_ID;

barcode myDUT(.clk(clk), .rst_n(rst_n), .BC(BC), .ID_vld(ID_vld), .clr_ID_vld(clr_ID_vld), .ID(ID));
barcode_mimic test(.clk(clk), .rst_n(rst_n),.period(period),.send(send),.station_ID(station_ID),.BC_done(BC_done),.BC(BC));

initial begin
	rst_n = 1'b0;
	send = 1'b0;
	clr_ID_vld = 1'b0;
	station_ID = 8'h1A; 	//00011010 to be transmitted
	period = 22'h400; 	//1024 period
	@(posedge clk);
	@(negedge clk);
	rst_n = 1'b1;
	@(negedge clk);
	send = 1'b1;
	@(negedge clk);
	send = 1'b0;
	#100000;
	$stop;
	@(negedge clk);
	clr_ID_vld = 1'b1;
	period = 22'h450;	//1104 period
	station_ID = 8'h07;	//00000111 to be transmitted
	@(negedge clk);
	send = 1'b1;
	@(negedge clk);
	send = 1'b0;
	#150000;
	$stop;
end



initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

endmodule
