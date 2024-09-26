`timescale 1ps/1fs

module loop_tb;


  parameter ref_half_period  = 12500; 

 //make the variables to the loop
  reg clk;
  reg rst;
  reg [63:0] samples;
  reg [2:0] alpha;
  reg [15:0] frac;
  reg [3:0] beta;
  reg [10:0] knormal;
  wire [15:0] dlf_out;
  
  //make the variables to get the data from the samples
  integer j;
  
  integer file_samples, file_dlf_out,file_sign_dlf_out,file_dpd_out,file_sign_dpd_out;
  reg [63:0] file_input_samples;
  reg [15:0] file_input_dlf_out; 
  reg file_input_dlf_out_sign;
  
  reg [18:0] file_input_dpd_out; 
  reg file_input_dpd_out_sign;
  integer  file_edges1, file_edges2;
  reg [15:0] file_input_edges1;
  reg [15:0] file_input_edges2;
  integer file_eff_period;
  reg [11:0] file_input_eff_period;
  
  reg [15:0] copydlf_out;
  reg [18:0] copydpd_out;

  reg [15:0] copyedges1;
  reg [15:0] copyedges2;
  reg [11:0] copyeff_period;

  integer file_finst1,file_finst2,file_ferror1,file_ferror2;
  integer file_sign_ferror1,  file_sign_ferror2;
  
  
  reg [15:0] file_input_finst1;
  reg [15:0] file_input_finst2;
  reg [15:0] file_input_ferror1;
  reg [15:0] file_input_ferror2;
  reg file_input_ferror1_sign;
  reg file_input_ferror2_sign;
  
  reg [15:0] copyfinst1;
  reg [15:0] copyfinst2;
  reg [15:0] copyferror1;
  reg [15:0] copyferror2;
  reg copyferror1_sign;
  reg copyferror2_sign;
  reg copydpd_out_sign;

  // Counters
  integer success_count;
  integer error_count;

  //initialize the block
  Loop uut (
	.clk(clk),
	.rst(rst),
	.samples(samples),
	.inv_dir(0),
	.inv_dpd(0),
	.rst_l_per(0),
	.overwrite_effp(0),
	.openLoop(0),
	.rst_l_dpd(0),
	.overwrite_dpd(0),
	.alpha(alpha),
	.frac(frac),
	.beta(beta),
	.dlf_bias(0),
	.knormal(knormal),
	.dlf_out(dlf_out)
  );

  // Clock
  initial begin
	clk = 0;
	forever #(ref_half_period) clk = ~clk;
  end

  // Main Simulation
  initial begin
	samples = 0;
	copydlf_out = 0;
	success_count = 0;
	error_count = 0;
	rst = 1'b0;
	alpha =3'b101;
	frac = 16'h1000;
	beta = 4'b0111;
	knormal = 11'd1165;
	j=0;
	#150;
	rst = 1'b1;
	file_dpd_out= $fopen("dpd_out.txt", "r");
	file_sign_dpd_out = $fopen("dpd_out_sign.txt", "r");
	file_samples = $fopen("samples.txt", "r");
	file_dlf_out= $fopen("dlf_out.txt", "r");
	file_sign_dlf_out = $fopen("dlf_out_sign.txt", "r");
	file_edges1 = $fopen("edges1.txt", "r");
	file_edges2 = $fopen("edges2.txt", "r");
	file_eff_period= $fopen("eff_period.txt", "r");
	file_finst1= $fopen("finst1.txt", "r");
	file_finst2 = $fopen("finst2.txt", "r");
	file_ferror1 = $fopen("f_error1.txt", "r");
	file_ferror2 = $fopen("f_error2.txt", "r");
	file_sign_ferror1 = $fopen("f_error1_sign.txt", "r"); 
	file_sign_ferror2 = $fopen("f_error2_sign.txt", "r");
	
	#150
	
	rst=1'b0;
	// read the lines from each file
	while (!$feof(file_samples)) begin
		
	     $fscanf(file_samples, "%h\n", file_input_samples);
		 if (j>1) begin
	 	 $fscanf(file_dlf_out, "%h\n", file_input_dlf_out);
	  	 $fscanf(file_sign_dlf_out, "%h\n", file_input_dlf_out_sign);
		 end else begin
	     file_input_dlf_out=0;	 
		 file_input_dlf_out_sign=0;
		 if(j==1) begin
			 j=2;
		 end
		 end
		 if (j>0) begin
	  	 $fscanf(file_dpd_out, "%h\n", file_input_dpd_out);
	  	 $fscanf(file_sign_dpd_out, "%h\n", file_input_dpd_out_sign);
		 $fscanf(file_finst1, "%h\n", file_input_finst1);
		 $fscanf(file_finst2, "%h\n", file_input_finst2);
		 $fscanf(file_ferror1, "%h\n", file_input_ferror1);
		 $fscanf(file_sign_ferror1, "%h\n", file_input_ferror1_sign);
		 $fscanf(file_ferror2, "%h\n", file_input_ferror2);
		 $fscanf(file_sign_ferror2, "%h\n", file_input_ferror2_sign);
		 end else begin
			 file_input_dpd_out=0;
			 file_input_dpd_out_sign=0;
			 file_input_finst1=0;
			 file_input_finst2=0;
			 file_input_ferror1=0;
			 file_input_ferror1_sign=0;
			 file_input_ferror2=0;
			 file_input_ferror2_sign=0;
			 j=1;
		 end
		 
	  	 $fscanf(file_edges1, "%h\n", file_input_edges1);
	  	 $fscanf(file_edges2, "%h\n", file_input_edges2);
		 $fscanf(file_eff_period, "%h\n", file_input_eff_period);	  
	  
	  
	  apply_test_vector(file_input_samples,file_input_edges1, file_input_edges2, file_input_eff_period
			  , file_input_finst1,file_input_finst2,file_input_ferror1,file_input_ferror1_sign,
			  file_input_ferror2,file_input_ferror2_sign,file_input_dpd_out,
			  file_input_dpd_out_sign,file_input_dlf_out,file_input_dlf_out_sign);
	end

	$fclose(file_samples);
	$fclose(file_dlf_out);
	$fclose(file_sign_dlf_out); 
	$fclose(file_edges1);
	$fclose(file_edges2);
	$fclose(file_eff_period);
	$fclose(file_finst1);
	$fclose(file_finst2); 
	$fclose(file_ferror1); 
	$fclose(file_ferror2); 
	$fclose(file_dpd_out);
	$fclose(file_sign_ferror1); 
	$fclose(file_sign_ferror2);
	$fclose(file_sign_dpd_out); 

	// Display How many Successes and how many Errors we have in our simulation
	$display("Simulation completed.");
	$display("Successes: %d", success_count);
	$display("Errors: %d", error_count);
	
	
	// End simulation
	#10;
	$finish;
  end

  // task - operate tdc encoder and compare with the results
  task apply_test_vector(input [63:0] vector_samples,input [15:0] sample_edges1, input [15:0] sample_edges2 , input [11:0] sample_eff_period ,input [15:0] sample_finst1,input [15:0] sample_finst2
		  ,input [15:0] sample_ferror1,input sample_ferror1_sign,input [15:0] sample_ferror2,input sample_ferror2_sign,input [18:0] sample_dpd_out,input sample_dpd_out_sign
		  ,input [15:0] sample_dlf_out,input sample_dlf_out_sign);
	begin
	  	  
	  @(posedge clk);
	  samples = vector_samples;
	  #1; 	  
	  //Read Samples of TDC Encoder
	  copyedges1 = sample_edges1;
	  copyedges2 = sample_edges2;
	  
	  //Read Samples of Period Estimate
	  copyeff_period = sample_eff_period;
	  
	  //Read Samples of DPD
	  copyfinst1 = sample_finst1;
	  copyfinst2 = sample_finst2;
	  if(sample_ferror1_sign) begin
		  copyferror1 = -sample_ferror1;  
	  end else begin
		  copyferror1 = sample_ferror1; 
	  end
	  if(sample_ferror2_sign) begin
		  copyferror2 = -sample_ferror2;  
	  end else begin
		  copyferror2 = sample_ferror2; 
	  end
	  if(sample_dpd_out_sign) begin
		  copydpd_out = -sample_dpd_out;  
	  end else begin
		  copydpd_out = sample_dpd_out; 
	  end
	  
	  //read samples of DLF
	  if(sample_dlf_out_sign) begin
		  copydlf_out = -sample_dlf_out;  
	  end else begin
		  copydlf_out = sample_dlf_out; 
	  end
	  
	  
	  if (copydlf_out!==uut.dlf_out) begin
		error_count = error_count + 1;
		$display("error!");
	  end else begin
		success_count = success_count + 1;
		$display("success!");
	  end 
	
	end
  endtask

endmodule
