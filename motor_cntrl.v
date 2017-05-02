module motor_cntrl(clk, rst_n, lft, rht, fwd_lft, rev_lft, fwd_rht, rev_rht);

input [10:0] lft, rht;

output reg fwd_lft, fwd_rht, rev_lft, rev_rht;
input clk, rst_n;


reg sign_l, sign_r; //Sign of the incomming lft and rht sig. 0 is negative, 1 is positive
reg [9:0] mag_l, mag_r;  // mag registers keep track of the magnitude of incomming lft and rht signals.
reg pre_fl, pre_rl, pre_fr, pre_rr;  //Input logic to fwd and rev registers.
reg [10:0] two_comp_lft, two_comp_rht; //Keeps track of twos compliment of lft and rht.
wire pwm_l, pwm_r;  //PWM signals comming from left and right signals.
//DUT for pwm generator
// module p_w_m(PWM_sig, duty, clk, rst_n);
p_w_m pwml(pwm_l, mag_l, clk, rst_n);
p_w_m pwmr(pwm_r, mag_r, clk, rst_n);





//Input logic to fwd_*, rev_*

always@(*) begin

assign pre_fl = (sign_l == 1'b1) ? pwm_l:
                 1'b0;

assign pre_fr = (sign_r == 1'b1) ? pwm_r:
                 1'b0;

assign pre_rl = (sign_l == 1'b0) ? pwm_l:
                 1'b0;

assign pre_rr = (sign_r == 1'b0) ? pwm_r:
                 1'b0;


end

//Registers that controll outputs

always@(posedge clk, negedge rst_n)begin

  if(!rst_n)begin
     fwd_lft <= 1'b0;
     fwd_rht <= 1'b0;
     rev_lft <= 1'b0;
     rev_rht <= 1'b0;

  end
  else begin
     fwd_lft <= pre_fl;
     fwd_rht <= pre_fr;
     rev_lft <= pre_rl;
     rev_rht <= pre_rr;
  end
end







//Magnitude Registers

//Keeps track of the magnitude of lft.
always@(posedge clk, negedge rst_n) begin
  if(!rst_n)
     mag_l <= 10'b0000000000;
  else if ( lft[10] == 0)
     mag_l <= lft[9:0];
  else 
     mag_l <= two_comp_lft[9:0];
end

//Keeps track of the magnitude of rht.
always@(posedge clk, negedge rst_n) begin
  if(!rst_n)
     mag_r <= 10'b0000000000;
  else if ( rht[10] == 0)
     mag_r <= rht[9:0];
  else 
     mag_r <= two_comp_rht[9:0] ;
end


//Sign Registers


// Flop of sign_l, keeps track of the sign of lft.
always@(posedge clk, negedge rst_n) begin

  if(!rst_n)
     sign_l <= 1'b0;
  else if (lft[10]==0)
     sign_l <=1;
  else
     sign_l <=0;

end


// Flop of sign_r, keeps track of the sign of rht.
always@(posedge clk, negedge rst_n) begin

  if(!rst_n)
     sign_r <= 1'b0;
  else if (rht[10]==0)
     sign_r <=1;
  else
     sign_r <=0;

end


//2's compliment registers

// Keeps track of the twos compliment of the lft signal that can be used as the magnitude of negative numbers.
always@(posedge clk, negedge rst_n) begin

  if(!rst_n)
     two_comp_lft <= 11'b0000000000;
  else 
     two_comp_lft <= ~lft+1'b1;
end



// Keeps track of the twos compliment of the rht signal that can be used as the magnitude of negative numbers.
always@(posedge clk, negedge rst_n) begin

  if(!rst_n)
     two_comp_rht <= 11'b0000000000;
  else 
     two_comp_rht <= ~rht+1'b1;
end

endmodule
