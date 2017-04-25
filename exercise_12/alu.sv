module alu(dst, Accum, Pcomp, Icomp, Pterm,
		Iterm, Fwd, A2D_res, Error, Intgrl, 
		src0sel, src1sel, multiply, sub, mult2, mult4, saturate);

input [15:0] Accum, Pcomp;
input [13:0] Pterm;
input [11:0] Icomp, Iterm, Fwd, A2D_res, Error, Intgrl;
input [2:0] src0sel, src1sel;
input multiply, sub, mult2, mult4, saturate;
output [15:0] dst;
wire [15:0] pre_src0, src0, src1, scaled_src0, src0_src1_sum, saturated_sum, sat_mult;
wire [29:0] signed_mult;

localparam Accum2Src1 = 3'b000;
localparam Iterm2Src1 = 3'b001;
localparam Err2Src1 = 3'b010;
localparam ErrDiv22Src1 = 3'b011;
localparam Fwd2Src1 = 3'b100;

localparam A2D2Src0 = 3'b000;
localparam Intgrl2Src0 = 3'b001;
localparam Icomp2Src0 = 3'b010;
localparam Pcomp2Src0 = 3'b011;
localparam Pterm2Src0 = 3'b100;

assign src1 = (src1sel == Accum2Src1) ? Accum : 				//Let Accum vector pass if src1sel is 000
		(src1sel == Iterm2Src1 ) ? {4'b0000,Iterm} :			//Let 16bit extended iterm pass if src1sel is 001
		(src1sel == Err2Src1 ) ? {{4{Error[11]}},Error} :		//Let sign extended error pass if src1sel is 010
		(src1sel == ErrDiv22Src1 ) ? {{8{Error[11]}},Error[11:4]} : 	//Let error divided by 16 pass if src1sel is 011
		(src1sel == Fwd2Src1) ? {4'b0000,Fwd} : 			//Let 16bit extended fwd vector if src1sel is 100
		16'hxxxx; 							//if src1sel is not any of the predetermined commands, src1 is invalid

assign pre_src0 = (src0sel == A2D2Src0 ) ? {4'b0000,A2D_res} : 		//Let 16bit extended a2d_res pass if src0sel is 000
		(src0sel == Intgrl2Src0 ) ? {{4{Intgrl[11]}},Intgrl} :	//Let sign extended intgrl pass if src0sel is 001
		(src0sel == Icomp2Src0 ) ? {{4{Icomp[11]}},Icomp} :	//Let sign extended icomp pass if src0sel is 010
		(src0sel == Pcomp2Src0 ) ? Pcomp : 			//Let Pcomp pass if src0sel is 011
		(src0sel == Pterm2Src0) ? {2'b00,Pterm} : 		//Let 16bit extended pterm vector if src0sel is 100
		16'hxxxx; 						//if src0sel is not any of the predetermined commands, pre_src0 is invalid

assign scaled_src0 = mult2 ? (pre_src0 << 1) : 		 //if mult2 is set, shift selected sr0 by 1
		(mult4 ? pre_src0 << 2 : pre_src0);	//else if mult4 is set, shift selected sr0 by 2; else let src0 pass

assign src0 = sub ? ~scaled_src0 : scaled_src0; 				//if sub is set; set sr0 to 2's complement of scaled_sr0, else let scaled_src0 pass
				
assign src0_src1_sum = src1 + src0 + sub; 					//add selected src1 and selected & modified src0

assign signed_mult = ($signed (src0[14:0]) * $signed (src1[14:0])); 				//30 bit product of src1 & src0

assign sat_mult = signed_mult[29] ? (&signed_mult[29:26] ? signed_mult[27:12] : 16'hC000) : 	//if multiplication is negaitve and below 0xC000, saturate result to 0xC000, else let 16bit result pass
				(|signed_mult[29:26] ? 16'h3FFF : signed_mult[27:12]) ; 	//if multiplication is positive and above 0x3FFF, saturate result to 0x3fff, else let 16bit result pass

assign saturated_sum = saturate ? (src0_src1_sum[15] ? (&src0_src1_sum[15:11] ? src0_src1_sum : 16'hF800) : //sum is saturated if negative and any of upper bits are low
	(|src0_src1_sum[15:11] ? 16'h07FF : src0_src1_sum)) : src0_src1_sum; 	//sum is saturated if positive and any of the upper 5 bits are high

assign dst = multiply ? sat_mult : saturated_sum; 				//choose saturated multiply if multiply is asserted, satured sum if multiply is not asserted

endmodule
