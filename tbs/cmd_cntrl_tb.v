module cmd_cntrl_tb();

//Registers
reg cmd_rdy, OK2Move, ID_vld, clk, rst_n;
reg [7:0] cmd, ID;
wire clr_cmd_rdy, in_transit, go, buzz, buzz_n, clr_ID_vld; 

//Instantiate cmd_cntrl
cmd_cntrl iDUT(.cmd(cmd), .cmd_rdy(cmd_rdy), .OK2Move(OK2Move), .ID(ID), .ID_vld(ID_vld), .clk(clk), .rst_n(rst_n), 
	.clr_cmd_rdy(clr_cmd_rdy), .clr_ID_vld(clr_ID_vld), .in_transit(in_transit), .go(go), .buzz(buzz), .buzz_n(buzz_n));


//Instantiate the global clock
always begin
  #5 clk = ~clk;
end

//Control the inputs
initial begin

  cmd_rdy = 0; 
  OK2Move = 0; 
  ID_vld = 0;
  clk = 0;
  rst_n = 0;
  cmd = 8'b11010111; // expected to remain in the STOP state 
  ID = 8'b00101101; 

  // tests the state transitions in the SM as well as the expected output values

  @(negedge clk) 
	rst_n = 1; // asynchronous reset, values expected to be zero

  repeat (3) begin
  @(posedge clk);
  end

  @(negedge clk);
  cmd_rdy = 1; // expected to remain in the STOP state 
  cmd = 8'b01110011; // expected to go to the GO state
  ID = 8'b01001001;
  @(negedge clk);
  cmd_rdy = 0; 
  
  repeat (3) begin
  	@(negedge clk); // expected to remain in the GO state 
  end
  @(posedge clk);
  cmd_rdy = 0;
  ID_vld = 1;
  repeat (3) begin
  @(posedge clk); 
  end
  
  cmd_rdy = 1;
  cmd = 8'b01001001; // expected to go to the STOP state
  ID = 8'b00001001;
  @ (posedge clk);
  @ (negedge clk);
  
  cmd_rdy = 0;
  repeat (3) begin
  @(posedge clk); 
  end

  cmd_rdy = 1;
  cmd = 8'b01011111; // expected to go to the GO state 
  ID = 8'b11101111;
  repeat (3) begin
  @(posedge clk); 
  end

  cmd = 8'b01011111; // expected to go to the STOP state 
  repeat (3) begin
  @(posedge clk); 
  end

  // tests the Piezo buzzer
  OK2Move = 0; // expected for the buzzer to be set high

  repeat (3) begin
  @(posedge clk); 
  end

  OK2Move = 0; // expected for the buzzer to be set low
	repeat (5000) begin
	@(posedge clk);
	end
	$stop;

end

endmodule
