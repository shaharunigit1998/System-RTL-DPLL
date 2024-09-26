`timescale 1ps/1fs
module DPD( 
	input wire clk,
	// 6 int 10 frac
	input wire [15:0] edges1,
	input wire [15:0] edges2,
	input wire [15:0] eff_period,
	
	input wire inv_dpd,
	// 16 bit frac
	input wire [15:0] frac,
	
	input wire openLoop,
	input wire rst_l,
	input wire [18:0] overwrite_dpd,
	
	//6 int 10 frac 
	output reg [15:0] finst1,
	output reg [15:0] finst2,
	output reg [15:0] ferror1,
	output reg [15:0] ferror2,
	//9 int 10 frac
	output reg signed [18:0] dpd_out,
	//6 int 10 frac
	output reg [15:0] prev_edges1,
	output reg [15:0] prev_edges2,
	//counts
	output reg [2:0]counter,
	input wire rst_cnt
);
// diffrence between the edges 7 int 10 frac
wire [16:0] diff1;
wire [16:0] diff2;

//frac*edges 6 integer 26 frac
wire [31:0] fracper;

//registers for the mod 7 int 26 frac
wire [32:0] extfracper;
wire [32:0] extper;
wire [32:0] exthalfper;
wire [32:0] extfinst1;
wire [32:0] extfinst2;
wire [32:0] sum1;
wire [32:0] sum2;
wire [32:0] extferror1;
wire [32:0] negextferror1;
wire [32:0] extferror2;
wire [32:0] negextferror2;

// 6 in 10 frac
wire signed [16:0] avgerror;
// 9 int 11 frac
wire signed [19:0] avgerror2;

// 6 in 10 frac
wire signed [15:0] cferror1;
wire signed [15:0] cferror2;
// 9 int 11 frac
wire signed [19:0] pdpd_out;
wire signed [19:0] rdpd_out;
wire signed [19:0] extdpd_out;
wire signed [19:0] ndpd_out;


//9 int 10 frac
wire signed [18:0] cdpd_out2;


//6 int 10 frac
wire [15:0] cfinst1;
wire [15:0] cfinst2;


//calculate the diffrences between this edges to the previous one
assign diff1=(inv_dpd)?{1'b0,edges1}-{1'b0,prev_edges1}:{1'b0,prev_edges1}-{1'b0,edges1};
assign diff2=(inv_dpd)?{1'b0,edges2}-{1'b0,prev_edges2}:{1'b0,prev_edges2}-{1'b0,edges2};

//Calculate instanteneous noremalized (to fRef) fractional  frequency
assign cfinst1=(diff1[16]) ? (diff1 + {1'b0, eff_period}) :(diff1[15:0] > eff_period) ? (diff1 - {1'b0, eff_period}) : diff1[15:0];			
assign cfinst2=(diff2[16]) ? (diff2 + {1'b0, eff_period}) :(diff2[15:0] > eff_period) ? (diff2 - {1'b0, eff_period}) : diff2[15:0];


// multiply effective period with the fraction 
//frac*edges 6 integer 25 frac

assign fracper =eff_period*frac;

//expand the vectors to calculate the frequency error
//registers for the modulo 7 int 25 frac

assign extfracper={1'b0,fracper};
assign extper={1'b0,eff_period,16'h0000};
assign exthalfper={2'b00,eff_period,15'h0000};
assign extfinst1={1'b0,cfinst1,16'h0000};
assign extfinst2={1'b0,cfinst2,16'h0000};

//make the sum to calculate the frequency error

assign sum1=extfinst1-extfracper+exthalfper;
assign sum2=extfinst2-extfracper+exthalfper;

// calculate the extended frequency error1
assign extferror1=(sum1>extper)?sum1-extper-exthalfper:sum1-exthalfper;
assign negextferror1=-extferror1;

// round the vector and make sure it's in the right resolution
//registers for the modulo 7 int 26 frac to 6 int 10 frac
assign cferror1 = (extferror1[32])?-(negextferror1[31:16]+negextferror1[15]):extferror1[31:16]+extferror1[15];

// calculate the extended frequency error2
assign extferror2=(sum2>extper)?sum2-extper-exthalfper:sum2-exthalfper;
assign negextferror2=-extferror2;

// round the vector and make sure it's in the right resolution
//registers for the modulo 7 int 26 frac to 6 int 10 frac
assign cferror2 = (extferror2[32])?-(negextferror2[31:16]+negextferror2[15]):extferror2[31:16]+extferror2[15];

//calculate the average error and put it in the right resolution

assign avgerror={cferror2[15],cferror2} + {cferror1[15],cferror1};
assign avgerror2={{3{avgerror[16]}},avgerror};

//extend dpd_out
assign extdpd_out=(rst_cnt)? 0 : {dpd_out,1'b0};


// put initial values when rst and then calculate dpd_out and 
// make sure it dos'nt go out of it's max/min values
assign rdpd_out = extdpd_out+avgerror2;
assign pdpd_out = (rst_cnt)? 0: (~rdpd_out[19]&extdpd_out[19]&avgerror2[19]) ? -20'd524286 : rdpd_out[19]&~extdpd_out[19]&~avgerror2[19] ? 20'd524286 :rdpd_out;
assign ndpd_out = -pdpd_out;
assign cdpd_out2 =(counter>0)?0:(pdpd_out>0)?pdpd_out[19:1]+pdpd_out[0]:-(ndpd_out[19:1]+ndpd_out[0]); 

always @(posedge clk or posedge rst_cnt) begin
	
		//put initial values in prev_edges when rst
		if (rst_cnt) begin
			prev_edges1 <= 0;
			prev_edges2 <= 0;
			finst1 <= 0;
			finst2 <= 0;
			ferror1 <= 0;
			ferror2 <= 0;
			counter <= 1;
			dpd_out <= 0;
		end else begin
			//keep all the values for next iteration
			finst1 <= cfinst1;
			finst2 <= cfinst2;
			ferror1 <= cferror1;
			ferror2 <= cferror2;
			prev_edges1 <= edges1;
			prev_edges2 <= edges2;

			// Counter control logic
			if (counter == 1) begin
				counter <= 2;
			end else if (counter == 2) begin
				counter <= 0;
			end else begin
				counter <= 0;
			end

			// DPD control logic
			if ((openLoop==1)|(counter > 0)) begin
				dpd_out <= 0;
			end else if (rst_l==1) begin
				dpd_out <= overwrite_dpd;
			end  else begin
				dpd_out <= cdpd_out2;
			end
		end
	
end
endmodule