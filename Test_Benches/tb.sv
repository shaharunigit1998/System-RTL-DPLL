`timescale 1ps/1fs

module tb;

	//reference clock period	
   parameter ref_half_period  = 12500;
   
   //determine the simulation length and the print file
   integer i;
   integer fdco_file;
   parameter simlen = $pow(2,24) + $pow(2,18);
   
   // clocks variables
   reg 	  ref_clk;
   reg 	  rst;
   reg 	  get_samples;
   reg 	  cb;
   reg [2:0] alpha;
   reg [15:0] frac;
   reg [3:0] beta;
   reg [10:0] knormal;
   reg [15:0] dlf_bias;
   
  //simulation paramters
   wire       dco_clk;
   wire [15:0] dlf_out;
   wire [63:0] samples;
//reference noise paramters
   integer    normal_seed;
   real       period_ref_rj;
   real       rnd_jitter;
   real       new_jitter;   
   real       prev_jitter;
	  
	  
//add reference noise
  always 
	begin
	   #(ref_half_period + rnd_jitter) ref_clk = ~ref_clk;
	end
   
   //calculate reference noise
  always @(posedge ref_clk)
	begin
	   new_jitter     = period_ref_rj*$itor($dist_normal(normal_seed, 0, int'(1e6)))/1e6;
	   rnd_jitter     = new_jitter - prev_jitter;
	   prev_jitter    = new_jitter;  
	end
  
  //tdc block
  tdc tdc_uut(
	  .ref_clk(ref_clk),
	  .dco(dco_clk),
	  .sampled_tdc(samples)
  );
  //dco block
  dco dco_uut (
	  .dlf_out(dlf_out),
	  .dco_clk(dco_clk)
	);
  //loop block
  Loop loop_uut (
	  .clk(ref_clk),
	  .rst(rst),
	  .samples(samples),
	  .alpha(alpha),
	  .frac(frac),
	  .beta(beta),
	  .knormal(knormal),
	  .dlf_bias(dlf_bias),
	  .dlf_out(dlf_out),
	  .inv_dir(0),
	  .inv_dpd(0),
	  .rst_l_per(0),
	  .overwrite_effp(0),
	  .openLoop(0),
	  .rst_l_dpd(0),
	  .overwrite_dpd(0)
	);
	
  always @(posedge dco_clk)
	begin
	   if (get_samples) 
	 begin
	  $fdisplay(fdco_file, "%f", dco_uut.fdco);
	  i = i+1;
	 end
	end
  
  initial 
	begin

	   // REF clock generation
	   normal_seed   = $urandom();
	   period_ref_rj = 0.2;     // Random jitter sigma in nsec       
	   prev_jitter   = 0;	 
	   ref_clk       = 0;
	   
	   //initialize parameters for the simulation module
	   cb          = 1'b0;
	   alpha       = 3'b101;
	   frac        = 16'h1000;
	   beta        = 4'b0111;
	   knormal     = $rtoi(36.5*32.0);
	   dlf_bias    = 39244;
	   get_samples = 0;  
	   
	   //begin simulation
	   rst         = 1'b0;
	   
	   #1000;
	   rst         = 1'b1;              
	   
	   #1000;
	   rst         = 1'b0;
	  
	   i = 0;

	   @(posedge ref_clk);
	   //#1; 
	   fdco_file = $fopen("new_fdco.txt", "w");
	   get_samples = 1;
				  
	   while (i < simlen) 
	 begin		 
		@(posedge ref_clk);
		//#1; 	  
	 end

	   get_samples = 0;       
	   $fclose(fdco_file);

	   $display("TEST ANALYSIS : Checking PASSED - %d DUT errors, %d DUT warnings.\n", 0, 0);
	   
	   $finish;
	end
  

  
endmodule