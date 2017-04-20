cmd_cntrl_tb();

//Registers
reg cmd_rdy, OK2Move, ID_vld clk, rst_n;
reg [7:0] cmd, ID;
wire clr_cmd_rdy, in_transit, go, buzz, buzz_n, clr_ID_vld; 

//Instantiate the DUT
cmd_cntrl iDUT();


//Instantiate the global clock
always begin
  #5 clk = ~clk;
end

//Controll the inputs
initial begin
  clk = 0;
  rst_n = 0;
  cmd = 8'b10010111;
  ID = 8'b01101101;
  #10 rst_n = 1;
  #20000
  cmd = 8'b11110011;
  ID = 8'b01001001;
  #20000
  cmd = 8'b11111111;
  ID = 8'b11001011;
  #20000
  cmd = 8'b00000011;
  ID = 8'b00001011;
  #20000
  cmd = 8'b00011111;
  ID = 8'b11101111;
end

endmodule
