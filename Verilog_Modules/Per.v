`timescale 1ps/1fs
module Per( 
	input wire clk,
	input wire [11:0] edges1,
	input wire [11:0] edges2,
	input wire [2:0] alpha,
	input wire rst,
	input wire rst_l,
	input wire [11:0] overwrite_effp,
	output reg [11:0] r2f,
	output reg [11:0] f2r,
	output wire [11:0] eff_period
);

//difference between the edges 6 int 6 frac
wire [19:0] diff1;
wire [19:0] diff2;
//extended vector of f2r or r2f 6 int 6 frac
wire [19:0] ext1;
wire [19:0] ext2;
//the avg sum of r2f/f2r and current diff 6 int  frac
wire [19:0] sum1;
wire [19:0] sum2;

wire [11:0] cr2f;
wire [11:0] cf2r;

wire bt;
wire isZero;
wire roz;
//check which edges is bigger? rise or fall
assign bt =	(edges2 > edges1);

//check if the edges are 0
assign isZero=(edges1==0)&(edges2==0);

//measure the difference between the edges
assign diff1  = {edges2 - edges1,8'b0};
//extend the vector for calculation
assign ext1 = (rst)? {12'h800,8'b0}  :{f2r,8'b0};  
//calculate the average f2r
assign sum1 = (diff1 >> alpha) + ext1 - (ext1 >> alpha);

//measure the difference between the edges
assign diff2  = {edges1 - edges2,8'b0};
//extend the vector for calculation
assign ext2 = (rst)? {12'h800,8'b0}  :{r2f,8'b0};
//calculate the average r2f
assign sum2 = (diff2 >> alpha) + ext2 - (ext2 >> alpha);

// put the right value to f2r/r2f
assign cr2f = (~bt) ? sum2[19:8]+sum2[7] : ((~rst)|(~isZero)) ? r2f : 12'h800;
assign cf2r = (bt) ? sum1[19:8]+sum1[7]  : ((~rst)|(isZero)) ? f2r : 12'h800;

assign roz=rst|isZero;
//sum both to get eff_period
assign eff_period=(rst_l)?overwrite_effp:cr2f+cf2r;

always @(posedge clk or posedge rst) begin
	// Asynchronous reset logic
	if (rst) begin
		r2f <= 12'h800;
		f2r <= 12'h800;
	end 
	else begin
		if (isZero) begin
			r2f <= 12'h800;
			f2r <= 12'h800;
		end else begin
			r2f <= cr2f;
			f2r <= cf2r;
		end		
	end

end

endmodule