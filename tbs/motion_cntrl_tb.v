module motion_cntrl_tb();

reg clk, rst_n;
//Inputs
reg go, cnv_cmplt;
reg [11:0] A2D_res;

//Outputs
wire start_conv, IR_in_en, IR_mid_en, IR_out_en;
wire [7:0] LEDs;
wire [10:0] lft, rht;
wire [2:0] chnnl;

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

motion_cntrl iDUT(.clk(clk), .rst_n(rst_n), .go(go), .strt_cnv(start_conv), .chnnl(chnnl), .cnv_cmplt(cnv_cmplt),
			 .A2D_res(A2D_res), .IR_in_en(IR_in_en), .IR_mid_en(IR_mid_en), .IR_out_en(IR_out_en), .LEDs(LEDs),
				 .lft(lft), .rht(rht));


initial begin
	go = 1'b0;
	cnv_cmplt = 1'b0;
	A2D_res = 12'h000;
	rst_n = 1'b0;
	@(posedge clk);
	@(negedge clk);
	rst_n = 1'b1;
	@ (negedge clk);
	@ (negedge clk);
	go = 1'b1;
	@ (negedge clk);
repeat (5) begin
	repeat (3) begin
		repeat (4200) begin	//wait for inner IR sensor polling
			@ (posedge clk);
		end
		A2D_res = 12'h020;
		@ (negedge clk);
		cnv_cmplt = 1'b1;
		@ (negedge clk);
		cnv_cmplt = 1'b0;
		repeat (50) begin
			@ (posedge clk);
		end
		A2D_res = 12'h010;
		@ (negedge clk);
		cnv_cmplt = 1'b1;
		@ (negedge clk);
		cnv_cmplt = 1'b0;
		//$stop;
	end
		//ERROR = 2 - 1 + 2*2 - 1*2 + 2*4 - 1*4 = 7
	//$stop;
	repeat (20) begin //PI_calculations
		@ (posedge clk);
	end
	//$stop;
end
$stop;
end



endmodule
