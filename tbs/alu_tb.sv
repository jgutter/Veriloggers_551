module alu_tb();

reg [15:0] Accum, Pcomp;
reg [11:0] Icomp, Iterm, Fwd, A2D_res, Error, Intgrl;
reg [13:0] Pterm;
reg [2:0] src0sel, src1sel;
reg multiply, sub, mult2, mult4, saturate;

wire[15:0] dst;

alu iDUT(.dst(dst), .accum(Accum), .pcomp(pcomp), .icomp(Icomp), .pterm(Pterm), .iterm(Iterm),
	.fwd(Fwd), .a2d_res(A2D_res), .error(Error), .intgrl(Intgrl), .src0sel(src0sel), .src1sel(src1sel),
	.multiply(multiply), .sub(sub), .mult2(mult2), .mult4(mult4), .saturate(saturate));

initial begin
	Accum = 16'h0080; //initialize accum signal 
	Pcomp = 16'h0070; //initialize pcomp signal
	Icomp = 12'h003; //initialize Icomp signal
	Pterm = 14'h3fff; //initialize Pterm signal
	Iterm = 12'h0F0; //initialize Iterm signal
	Fwd = 12'h008; //initialize Fwd signal
	A2D_res = 12'h006; //initialize A2D_res signal
	Error = 12'h040; //initialize error signal
	Intgrl = 12'h010; //initialize intgrl signal
	
	#5;
	src0sel = 3'b011; //first test to add Accum and pcomp; saturate result if necessary
	src1sel = 3'b000; 
	sub = 1'b0;
	mult2 = 1'b0;
	mult4 = 1'b0;
	multiply = 1'b0;
	saturate = 1'b1; //result should be 0x00F0

	#5;
	src0sel = 3'b100; //second test to subtract pterm*2 from Fwd; does not saturate result
	src1sel = 3'b100;
	sub = 1'b1;
	mult2 = 1'b1;
	mult4 = 1'b0;
	multiply = 1'b0;
	saturate = 1'b0; //result should x70
end

endmodule
