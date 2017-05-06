
module motion_cntrl(clk, rst_n, go, strt_cnv, chnnl, cnv_cmplt, A2D_res, IR_in_en, IR_mid_en, IR_out_en,
			LEDs, lft, rht);

input clk, rst_n, go, cnv_cmplt;
input [11:0] A2D_res;
output logic  strt_cnv;
output IR_in_en, IR_mid_en, IR_out_en;
output logic [2:0] chnnl; //IMPORTANT: chnnl sent to A2D is always staggered one cycle behind last completed conversion
output logic [7:0] LEDs;
output logic [10:0] lft, rht;

//alu registers & signals
logic [15:0] dst, Accum, pcomp;
logic [11:0] icomp, iterm, fwd, error, a2d_res, intgrl, lft_reg, rht_reg;
logic [13:0] pterm;
logic [2:0] src0sel, src1sel;
logic multiply, sub, mult2, mult4, saturate;
logic dst2Accum, dst2Err, dst2Int, dst2Icmp, dst2Pcmp, dst2lft, dst2rht;

//instantiate alu
alu ALU(.dst(dst), .Accum(Accum), .Pcomp(pcomp), .Icomp(icomp), .Pterm(pterm),
		.Iterm(iterm), .Fwd(fwd), .A2D_res(A2D_res), .Error(error), .Intgrl(intgrl), 
		.src0sel(src0sel), .src1sel(src1sel), .multiply(multiply), .sub(sub), .mult2(mult2),
		 .mult4(mult4), .saturate(saturate));

wire PWM_sig;
//instantiate PWM for reading IR sensors
pwm8 PWM(.PWM_sig(PWM_sig), .duty(8'h8C), .clk(clk), .rst_n(rst_n));
//State enumeration
typedef enum reg [3:0] {STOP, WAIT_IR, A2D_ready_R, RIGHT, WAIT2, A2D_ready_L, LEFT, PI_CALC} state_t;
state_t state, next_state;

//internal control signals
logic [2:0] chnnl_cnt, PI_calc;
logic [12:0] IR_timer, timer; 
logic load_4096, load_32, load_alu, incre_chnnl_cnt, clr_chnnl_cnt, clr_Accum, clr_PI_calc, incr_PI_calc, incr_int_dec;
logic IR_in, IR_mid, IR_out;
logic [1:0] int_dec;

always_ff @ (posedge clk, negedge rst_n) begin //timer flop
	if (!rst_n) begin
		timer <= 13'h000;
	end
	else begin
		if (load_32)
			timer <= 13'h20;
		else if (load_alu)	//timer for alu calculations
			timer <= 13'h2;
		else if (|timer != 13'h0000)
			timer <= timer - 1'b1;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin // IR sensor timer
	if (!rst_n)
		IR_timer <= 13'h000;
	else begin
		if (load_4096)
			IR_timer <= 13'h1000;
		else if (IR_timer != 13'h0000)
			IR_timer <= IR_timer - 1'b1;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //channel counter flop
	if (!rst_n)
		chnnl_cnt <= 3'h0;
	else begin
		if(clr_chnnl_cnt)
			chnnl_cnt <= 3'h0;
		else if (incre_chnnl_cnt)
			chnnl_cnt <= chnnl_cnt + 1'b1;
	end
end


always_ff @ (posedge clk, negedge rst_n) begin //Accum flop
	if (!rst_n)
		Accum <= 16'h0000;
	else begin
		if (clr_Accum)
			Accum <= 16'h0000;
		else if (dst2Accum)
			Accum <= dst;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin//Error flop
	if(!rst_n)
		error <= 12'h000;
	else begin
		if (dst2Err)
			error <= dst;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //Pcomp flop
	if(!rst_n)
		pcomp <= 16'h0000;
	else begin
		if (dst2Pcmp)
			pcomp <= dst;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //Intgrl flop
	if (!rst_n)
		intgrl <= 12'h000;
	else begin
		if (dst2Int)
			intgrl <= dst;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //Intgrl decimator flop
	if(!rst_n)
		int_dec <= 2'h0;
	else begin
		if (incr_int_dec)
			int_dec <= int_dec + 1'b1;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //Icomp flop
	if (!rst_n)
		icomp <= 12'h000;
	else begin
		if (dst2Icmp)
			icomp <= dst;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //lft_reg flop
	if (!rst_n)
		lft_reg <= 12'h000;
	else begin
		if(!go)
			lft_reg <= 12'h000;
		if (dst2lft)
			lft_reg <= dst;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //rht_reg flop
	if (!rst_n)
		rht_reg <= 12'h000;
	else begin
		if(!go)
			rht_reg <= 12'h000;
		else if (dst2rht)
			rht_reg <= dst;
	end
end

always_comb begin		//src selects
	src1sel = 3'h0;
	src0sel = 3'h0;
	if (state == PI_CALC) begin
		case (PI_calc)
			3'h0: begin
				src1sel = 3'b011; 	//ErrDiv22Src1
				src0sel = 3'b001;	//Intgrl2Src0
			end
			3'h1: begin
				src1sel = 3'b001;	//Iterm2Src1
				src0sel = 3'b001;	//Intgrl2Src0
			end
			3'h2: begin
				src1sel = 3'b010;	//Err2Src1
				src0sel = 3'b100;	//Pterm2Src0
			end
			3'h3: begin
				src1sel = 3'b100;	//Fwd2Src1
				src0sel = 3'b011;	//Pcomp2Src0
			end
			3'h4: begin
				src1sel = 3'b000;	//Accum2Src1
				src0sel = 3'b010;	//Icomp2Src0
			end
			3'h5: begin
				src1sel = 3'b100;	//Fwd2Src1
				src0sel = 3'b011;	//Pcomp2Src0
			end
			3'h6: begin
				src1sel = 3'b000;	//Accum2Src1
				src0sel = 3'b010;	//Icomp2Src0
			end
		endcase
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //PI calculation counter
	if(!rst_n)
		PI_calc <= 3'h0;
	else begin
		if (clr_PI_calc)
			PI_calc <= 3'h0;
		else if (incr_PI_calc)
			PI_calc <= PI_calc + 1'b1;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //Fwd register
	if(!rst_n)
		fwd <= 12'h000;
	else begin
		if (!go)
			fwd <= 12'h000;
		else if (dst2Int & ~&fwd[10:8])
			fwd <= fwd + 1'b1;
	end
end

always_ff @ (posedge clk, negedge rst_n) begin //chnnl flop for A2D converter
	if(!rst_n)
		chnnl <= 3'h0;
	else begin
		case (chnnl_cnt)
			3'h0: begin
				chnnl <= 3'h1;
			end
			3'h1: begin
				chnnl <= 3'h0;
			end
			3'h2: begin
				chnnl <= 3'h4;
			end
			3'h3: begin
				chnnl <= 3'h2;
			end
			3'h4: begin
				chnnl <= 3'h3;
			end
			3'h5: begin
				chnnl <= 3'h7;
			end
		endcase
	end
end
/*
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		
	else begin
		
	end
end
*/

always_ff @ (posedge clk, negedge rst_n) begin //state machine flop
	if(!rst_n)
		state <= STOP;
	else begin
		state <= next_state;
	end
end

always_comb begin
	clr_PI_calc = 1'b0;		//default outputs
	incr_PI_calc = 1'b0;
	incre_chnnl_cnt = 1'b0;
	clr_chnnl_cnt = 1'b0;
	load_4096 =  1'b0;
	load_32 = 1'b0;
	strt_cnv = 1'b0;
	IR_in = 1'b0;
	IR_mid = 1'b0;
	IR_out = 1'b0;
	sub = 1'b0;
	multiply = 1'b0;
	mult2 = 1'b0;
	mult4 = 1'b0;
	clr_Accum = 1'b0;
	saturate = 1'b0;
	load_alu = 1'b0;
	incr_int_dec = 1'b0;
	dst2Accum = 1'b0; dst2Err = 1'b0; dst2Int = 1'b0; dst2Icmp = 1'b0; dst2Pcmp = 1'b0; 
	dst2lft = 1'b0; dst2rht = 1'b0;
	next_state = STOP;
	case(state)
		STOP:
			if (go) begin			//if go is asserted
				clr_chnnl_cnt = 1'b1;	//clear channel count
				clr_Accum = 1'b1;
				load_4096 = 1'b1;	//set PWM timer
				next_state = WAIT_IR;
			end
		WAIT_IR:
			if (~|IR_timer) begin	//if PWM timer times out
				strt_cnv = 1'b1;	//start A2D conversion
				next_state = A2D_ready_R;
			end
			else begin //if PWM timer has not timed out
				next_state = WAIT_IR;
				case (chnnl_cnt)
					3'h0:			//if channel count == 0
						IR_in = 1'b1;	//enable PWM for inner IR sensors
					3'h2:			//if channel count == 2
						IR_mid = 1'b1;	//enable PWM for middle IR sensors
					3'h4:			//if channel count == 4
						IR_out = 1'b1;	//enable PWM for outer IR sensors
				endcase
			end
		A2D_ready_R:
			if (cnv_cmplt) begin
				load_alu = 1'b1;
				next_state = RIGHT;
			end
			else
				next_state = A2D_ready_R;
		RIGHT:
			if (~|timer) begin	//if ALU calculation has timed out
				incre_chnnl_cnt = 1'b1;	//increment channel counter
				dst2Accum = 1'b1;	//store dst into Accum
				load_32 = 1'b1;		//load timer
				next_state = WAIT2;
				case (chnnl_cnt)
					3'h2:
						mult2 = 1'b1; //multiply result by 2
					3'h4:
						mult4 = 1'b1; //multiply result by 4
				endcase
			end
			else
				next_state = RIGHT;
		WAIT2:
			if (~|timer) begin 	//if timer has timed out
				strt_cnv = 1'b1;	//start A2D conversion
				next_state = A2D_ready_L;
			end
			else
				next_state = WAIT2;
		A2D_ready_L:
			if (cnv_cmplt) begin
				load_alu = 1'b1;
				next_state = LEFT;
			end
			else
				next_state = A2D_ready_L;
		LEFT:
			if (~|timer) begin	//if alu timer has timed out
				if (chnnl_cnt == 5)
					dst2Err = 1'b1;
				else
					dst2Accum = 1'b1;
				incre_chnnl_cnt = 1'b1;	//increment channel counter
				sub = 1'b1;
				case (chnnl_cnt)
					3'h3:
						mult2 = 1'b1;
					3'h5:
						mult4 = 1'b1;
				endcase
				if (chnnl_cnt == 3'h5) begin	//if all channels have been converted
					next_state = PI_CALC;
				end
				else begin
					next_state = WAIT_IR;
					load_4096 = 1'b1;	//load PWM timer
				end
			end 
			else
				next_state = LEFT;
		PI_CALC:
				case(PI_calc)			//case for PI calculations
					3'h0: 	begin		//Intgrl = saturate(Error>>4 + Intgrl)	
						if (&int_dec)
							dst2Int = 1'b1;		
						incr_int_dec = 1'b1;
						saturate = 1'b1;
						next_state = PI_CALC;
						incr_PI_calc = 1'b1;
						load_alu = 1'b1;
						end
					3'h1: 	begin		//Icomp = Iterm*Intgrl
						dst2Icmp = 1'b1;
						multiply = 1'b1;	//setup for next calculation
						next_state = PI_CALC;
						if (~|timer) begin
							incr_PI_calc = 1'b1;
							load_alu = 1'b1;
							end
						end
					3'h2:	begin		//Pcomp = Error*Pterm
						dst2Pcmp = 1'b1;
						multiply = 1'b1;
						next_state = PI_CALC;
						if (~|timer) begin
							incr_PI_calc = 1'b1;
						end
						end
					3'h3:	begin		//Accum = Fwd - Pcomp
						dst2Accum = 1'b1;
						sub = 1'b1;
						next_state = PI_CALC;
						incr_PI_calc = 1'b1;
						end
					3'h4:	begin		//rht_reg = saturate(Accum - Icomp)
						dst2rht = 1'b1;
						saturate = 1'b1;
						sub = 1'b1;
						next_state = PI_CALC;
						incr_PI_calc = 1'b1;
						end
					3'h5:	begin		//Accum = Fwd + Pcomp
						dst2Accum = 1'b1;
						incr_PI_calc = 1'b1;
						next_state = PI_CALC;
						end
					3'h6:	begin		//lft_reg = saturate(Accum + Icomp)
						dst2lft = 1'b1;
						saturate = 1'b1;
						clr_PI_calc = 1'b1;
						next_state = STOP;
						end
				endcase
	endcase

end


//continuous assignments
assign LEDs = error[11:4];
assign pterm = 14'h3680;
assign iterm = 12'h500;
assign IR_in_en = IR_in ? PWM_sig : 1'b0;
assign IR_mid_en = IR_mid ? PWM_sig : 1'b0;
assign IR_out_en = IR_out ? PWM_sig : 1'b0;
assign lft =  lft_reg[11:1];
assign rht =  rht_reg[11:1];

endmodule
