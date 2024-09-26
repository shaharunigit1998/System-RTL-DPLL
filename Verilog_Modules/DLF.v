`timescale 1ps/1fs
module DLF( 
	input wire 		 clk,
	input wire 		 rst,
	//9 int 11 frac
	input wire [19:0] 	 dpd_out,
	// 5-10 int
	input wire [3:0] 	 beta,
		
	// 6 bit int 5 frac
	input wire [10:0] 	 knormal,
	
	//16 int
	input wire [15:0] 	 dlf_bias,
		
	//18 int , 11 frac
	output reg signed [28:0] dlf_int,
	
	//9 int 11 frac
	output reg signed [19:0] dlf_prop,
	// 16 int
	output reg [15:0] 	 dlf_out
);

//extended dpd_out 18 int , 11 frac
wire [28:0] w1;

// 18 int 11 frac

wire [28:0] dlf_prop_ext;

//18 int 11 frac
wire [28:0] nsumext;
wire [28:0] psumext;

//24 int 16 frac
wire [39:0] pmul;
wire [39:0] nmul;

wire lt16bit;

// 18 int 11 frac
wire signed [28:0] rdlf_int;
wire signed [28:0] cdlf_int2;
wire signed [28:0] cdlf_int3;
wire signed [28:0] cdlf_int;
//9 int 11 frac
wire signed [19:0] cdlf_prop;
//16 int
wire signed [15:0] cdlf_out;
wire [15:0] cdlf_t;
// Make sure  w1 is extended dpd_out
assign w1 = {{9{dpd_out[19]}}, dpd_out};

//calculate dlf_int
assign rdlf_int= dlf_int;
assign cdlf_int3 = dlf_int + w1;

//make sure it doesn't overflow
assign cdlf_int2=(rdlf_int[28]&w1[28]& ~cdlf_int3[28])?29'b1000000000000000000000000000:(~rdlf_int[28]&~w1[28]& cdlf_int3[28])?29'b01111111111111111111111111111:cdlf_int3; 

//dlf_porp for calculation
assign cdlf_prop=dpd_out;

// divide dlf_int by 2^beta
assign cdlf_int=cdlf_int2>>>beta;

//extend prop
assign dlf_prop_ext=(cdlf_prop[19])?-{9'b0,-cdlf_prop}:{9'b0,cdlf_prop};

//sum up dlf_prop_ext+cdlf_int and make positive sum and negative sum
assign psumext=dlf_prop_ext+cdlf_int;
assign nsumext=-psumext;

//multiply and get multiply for the positive sum and negative sum
//24 int 16 frac
assign pmul= psumext*knormal;
assign nmul= nsumext*knormal;

//check if mul is larger then 16 bit
assign lt16bit= (psumext[28]) ? (nmul>40'd2147483648) ? 1 : 0 :(pmul>40'd2147483648)? 1: 0;

//calculate dlf_out without bias
assign cdlf_out =(psumext[28]) ? (lt16bit) ? -16'd32768:-(nmul[31:16] + nmul[15]):(lt16bit)? 16'd32768 :pmul[31:16] + pmul[15];
//calculate dlf_out_t
assign cdlf_t=dlf_bias + cdlf_out;


always @(posedge clk or posedge rst) 
  begin
	
	//put the values in the relevant registers
	if(rst) begin
		dlf_int <=0;

		dlf_prop<=0;

		dlf_out <=0;
	end else begin
		dlf_int <=cdlf_int2;

		dlf_prop<=dpd_out;

		dlf_out <=cdlf_t;
	end
		
end

endmodule