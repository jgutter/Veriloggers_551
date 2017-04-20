motion_cntrl_tb();

//Inputs
reg go, cnv_cmplt, clk, rst_n;
reg [11:0] A2D_res;

//Outputs
wire start_conv, cnv_cmplt, IR_in_en, IR_mid_en, IR_out_en;
wire [7:0] LEDs;
wire [10:0] lft, rht;

//Instantiate the DUT
motion_cntrl iDUT();


//Instantiate the global clock
always begin
  #5 clk = ~clk;
end

//Controll the inputs
initial begin
  clk = 0;
  rst_n = 0;
  go = 0;              //Initial Values
  cnv_cmplt = 0;
  A2D_res = 12'h000;

  #20 rst_n = 1;  //Test 1 A2D_res = h000
  #100 go = 1; 
  #5 go = 0;
  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop

  A2D_res = 12'hA1B;

  #10 go = 1;
  #5 go = 0;

  #6000 cnv_cmplt = 1; //Test 2 A2D_res = hA1B
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;

  #6000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #2000 cnv_cmplt = 1;
  #2 cnv_cmplt = 0;
  #10 $stop;
end

endmodule
