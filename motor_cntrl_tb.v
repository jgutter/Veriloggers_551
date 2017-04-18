module motor_cntrl_tb ();

wire fwd_lft, rev_lft, fwd_rht, rev_rht; //Outputs of motor control module.
reg [10:0] lft, rht; //Inputs to motot control
reg clk, rst_n;  //global clk and reset

//Instantiate the DUT to the motor control module.
motor_cntrl iDUT(clk, rst_n, lft, rht, fwd_lft, rev_lft, fwd_rht, rev_rht);


initial begin
clk =0;  //Initialize values
rst_n =0;
lft = 11'b11001101101;
rht = 11'b01101011011;
#25 rst_n =1;

//Both values negative
#200000 lft = 11'b11001101101;
rht = 11'b11101011011;
// positive lft, negitive rht
#200000 lft = 11'b00001101101;
rht = 11'b11101011011;
//both values positive
#200000 lft = 11'b01001101101;
rht = 11'b01101011011;
//Brake state
#200000 lft = 11'b00000000000;
rht = 11'b00000000000;
#200000 $stop;
end

always begin
#5 clk =~clk;  //Global clock
end

endmodule
