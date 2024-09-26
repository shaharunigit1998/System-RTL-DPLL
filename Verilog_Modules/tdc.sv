`timescale 1ps/1fs

module tdc (
	input wire ref_clk, // Reference clock input for the TDC
	input wire dco, //DCO clock input for the TDC
	output logic [63:0] sampled_tdc //samples output from the tdc that will enter the loop
);

	parameter real dt = 4;//delay of the flip-flops
	parameter NTDC = 64;//number of flip flops

	integer i;
	logic [NTDC-1:0] clk_chain;//array of flip-flop chains
//create a delayed version of ref clock in the tdc
	always @(*) begin
		for (i = 0; i < NTDC; i++) begin
			clk_chain[i] <= #(i*dt*1ps) ref_clk;            
		end
	end 
//generate samples
	genvar n;
	generate
		for (n = 0; n < NTDC; n++) begin : FF_GEN
			always @(posedge clk_chain[n]) begin
				sampled_tdc[n] <= dco;
			end
		end
	endgenerate
endmodule
