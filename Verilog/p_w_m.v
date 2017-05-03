module p_w_m(PWM_sig, duty, clk, rst_n);

input [9:0] duty;
input clk; 
input rst_n;
reg reset, set; 
reg [9:0] cnt;
output reg PWM_sig;

always @ (posedge clk, negedge rst_n) begin

if (!rst_n)begin
   cnt <= 10'b0000000000;
end
else
cnt <= cnt+1;
end


always @ (posedge clk, negedge rst_n) begin
if(!rst_n) begin
set <=0;
reset <= 0;
end
else if (cnt == 10'b0000000000) begin
 set <= 1'b1;
 reset <=1'b0;
end
else if (cnt==duty) begin 
 set <= 1'b0;
 reset = 1'b1;
end

end




always @ (posedge clk, negedge rst_n) begin

if (!rst_n)begin
  PWM_sig <=1'b0; 
end


else begin
if (reset) begin
   PWM_sig <= 1'b0;
end

else if(set)begin
   PWM_sig <= 1'b1;
end
end

end








endmodule
