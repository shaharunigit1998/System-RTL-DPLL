`timescale 1ps/1fs
module Loop(
	input wire clk,
	input wire rst,
	input wire [63:0] samples,
	input wire inv_dir,
	input wire inv_dpd,
	input wire [2:0] alpha,
	input wire rst_l_per,
	input wire [11:0] overwrite_effp,
	input wire openLoop,
	input wire rst_l_dpd,
	input wire [18:0] overwrite_dpd,
	input wire [15:0] frac,
	input wire [3:0] beta,
	input wire [10:0] knormal,
	input wire [15:0] dlf_bias,
	output reg [15:0] dlf_out	
);
	
	// Internal wires
	wire [15:0] edges1;
	wire [15:0] edges2;
	wire [11:0] eff_period;
	wire [18:0] dpd_out;
	
	
	// Instantiate the TDC_ENCODER module
	TDC_ENCODER tdc_encoder (
		.inv_dir(inv_dir),
		.samples(samples),
		.edges1(edges1),
		.edges2(edges2)
	); 
  
  
	// Instantiate the Per module
	Per period_estimator (
		.clk(clk),
		.edges1(edges1[15:4]),
		.edges2(edges2[15:4]),
		.alpha(alpha),
		.rst(rst),
		.eff_period(eff_period),
		.rst_l(rst_l_per),
		.overwrite_effp(overwrite_effp)
	); 
  

	// Instantiate the DPD module
	DPD dpd (
		.clk(clk),
		.edges1(edges1),
		.edges2(edges2),
		.eff_period({eff_period,4'b0}),
		.frac(frac),
		.dpd_out(dpd_out),
		.rst_cnt(rst),
		.openLoop(openLoop),
		.rst_l(rst_l_dpd),
		.overwrite_dpd(overwrite_dpd),
		.inv_dpd(inv_dpd)
	);

	// Instantiate the DLF module
	DLF dlf (
		.clk(clk),
		.rst(rst),
		.dpd_out({dpd_out,1'b0}),
		.beta(beta),
		.knormal(knormal),
		.dlf_bias(dlf_bias),
		.dlf_out(dlf_out)
	);

endmodule


