module UART_reciever_tb();

reg clk, rst_n, RX, rx_rdy_clr;
wire [7:0] cmd;
wire rx_rdy;

UART_rcv iDUT(.clk(clk), .rst_n(rst_n), .RX(RX), .cmd(cmd), .rx_rdy(rx_rdy), .rx_rdy_clr(rx_rdy_clr));

initial begin
// send 111 0101011011
RX = 1;
rx_rdy_clr = 1'b0;
rst_n = 0;
clk = 1;
#10 rst_n = 1;

#26040 RX=1;  //Idle bits
#26040 RX=1;

#26040 RX=0;  //Start Bit
#26040 RX=1;  // 8 bit word(10110101) shifted every 2604 clk cycles
#26040 RX=0;  
#26040 RX=1;
#26040 RX=0;
#26040 RX=1;   
#26040 RX=1;
#26040 RX=0;
#26040 RX=1;
#26040 RX=1; //Stop bit


//Expected LED output = 10110101
 
#26040 RX=1;  //Idle
#26040 RX=1;
#26040 RX=1;
#26040 RX=1;
#26040 RX=1;
#26040 RX=1;

#26040 RX=0;  //Start Bit
rx_rdy_clr= 1'b1; // clear received ready signal
@(posedge clk);
@(negedge clk);
rx_rdy_clr = 1'b0;

#26040 RX=1;  // 8 bit word(11011101) shifted every 2604 clk cycles
#26040 RX=0;  
#26040 RX=1;
#26040 RX=1;
#26040 RX=1;   
#26040 RX=0;
#26040 RX=1;
#26040 RX=1;
#26040 RX=1; //Stop bit


#26040 RX=1; //Idle
#26040 RX=1;

#26040 RX=0;  //Start Bit
rx_rdy_clr= 1'b1; // clear received ready signal
@(posedge clk);
@(negedge clk);
rx_rdy_clr = 1'b0;
#26040 RX=0;  // 8 bit word(0000_0000) shifted every 2604 clk cycles
#26040 RX=0;  
#26040 RX=0;
#26040 RX=0;
#26040 RX=0;   
#26040 RX=0;
#26040 RX=0;
#26040 RX=0;
#26040 RX=1; //Stop bit




#26040 RX=1; //Idle
#26040 RX=1;

#26040 RX=0;  //Start Bit
rx_rdy_clr= 1'b1; // clear received ready signal
@(posedge clk);
@(negedge clk);
rx_rdy_clr = 1'b0;
#26040 RX=1;  // 8 bit word(1111_1111) shifted every 2604 clk cycles
#26040 RX=1;  
#26040 RX=1;
#26040 RX=1;
#26040 RX=1;   
#26040 RX=1;
#26040 RX=1;
#26040 RX=1;
#26040 RX=1; //Stop bit


#26040 RX=1;
#26040 RX=1; //Idle

$stop;
end



always begin
#5 clk = ~clk;  //Global Clock
end

endmodule 
