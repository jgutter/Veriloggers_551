module UART_counter(clk, en, rst_n);


input clk, en, rst_n;

reg [7:0] count;

always@(posedge clk, negedge rst_n) begin

if(!rst_n)begin
  count <= 8'h00;
end

else if (en) begin
  count <= count+1;
end

end

endmodule
