module SPI_mstr_tb();

reg clk, rst_n, wrt;
reg [15:0] cmd;
wire done, SCLK, MOSI, SS_n, MISO;
wire [15:0] rd_data;

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

SPI_mstr DUT0(clk, rst_n, wrt, cmd, done, rd_data, SCLK, SS_n, MOSI, MISO); //instantiate mstr DUT
SPI_slave DUT1(clk,rst_n,SS_n,SCLK,MISO,MOSI,rdy); //instanstiate slave DUT


initial begin
	cmd = 16'hDCBA; //cmd to be shifted into slave module
	rst_n = 0;	//asynch reset
	wrt = 1'b0;	
	@(posedge clk);
	@(negedge clk);
	rst_n = 1'b1;
	@(negedge clk);
	wrt = 1'b1;	//assert wrt to begin transmitting
	@(negedge clk);
	wrt = 1'b0;
	#11200;		//wait until Transmission is complete; output should be 0xABCD
	$stop;
	@(negedge clk);
	cmd = 16'hDEAD;	//cmd to be shifted into slave module
	wrt = 1'b1;	//start transmission
	@ (negedge clk);
	wrt = 1'b0;
	#7420;		//wait until transmission is complete; output should be 0xDCBA
	$stop;
end






endmodule
