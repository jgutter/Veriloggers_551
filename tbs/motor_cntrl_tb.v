module motor_cntrl_tb (); //Motor Control Test Bench

wire fwd_lft, rev_lft, fwd_rht, rev_rht;  //Outputs of motor_cntrl module.
reg [10:0] lft, rht; //Latched inputs to motor_cntrl module.
reg clk, rst_n;  //Global clock and active low reset.

motor_cntrl iDUT(clk, rst_n, lft, rht, fwd_lft, rev_lft, fwd_rht, rev_rht);  //Instantiate motor_cntrl iDUT


initial begin
clk =0;           //Initialize clock and assert rst_n.
rst_n =0;
lft = 11'b11001101101; //Initial values for lft and rht
rht = 11'b01101011011; 

#25 rst_n =1;  //Deasert the reset

//rev_lft and fwd_rht should be asserted here.

#200000 lft = 11'b11001101101;
rht = 11'b11101011011;

//rev_lft and rev_rht should be asserted here.

#200000 lft = 11'b00001101101;
rht = 11'b11101011011;

//fwd_lft and rev_rht should be asserted here.

#200000 lft = 11'b01001101101;
rht = 11'b01101011011;

//rwd_lft and fwd_rht should be asserted here.

#200000 lft = 11'b00000000000;
rht = 11'b00000000000;

//Breaking condition (all high) should be asserted here.

#200000 lft = 11'b01001101101;
rht = 11'b01101011011;

//rev_lft and rev_rht should be asserted here.

#200000 lft = 11'b00000000000;
rht = 11'b00000000000;

//Breaking condition (all high) should be asserted here.

#200000 $stop;  //End of testbench
end




always begin  //Instantiate global clock.
#5 clk =~clk;
end


endmodule
