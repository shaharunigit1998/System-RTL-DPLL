`timescale 1ps/1ps

module dco (
		input [15:0] dlf_out,
		output logic dco_clk
);

   // Parameters
   parameter real 	 Cmin        = 170e-15;   
   parameter real 	 Course      = 36e-15;    
   parameter real 	 Fine        = 4e-15;     
   parameter real 	 SmallCap    = 33e-18;   
   parameter real 	 NsSgm       = 30e-6;     
   parameter integer 	 NumOfCourse = 0;
   parameter integer 	 NumOfFine   = 5;
   parameter real 	 Ind         = 12e-10;

   // Constants
   real 		  pi = $acos(-1);
   
   // Internal variables
   real 		  total_cap;
   real 		  fdco;
   real 		  dlf_norm;   
   integer 		  seed;
   real 		  freq_noise;

   real 		  per_real;
   real                   per_acc;
   real 		  per_grid;
			
   initial 
	 begin
	dco_clk = 1'b0;
	seed    = $urandom();
	
	per_real = 200;
	per_acc  = 0;
	per_grid = 200;	
	 end

   always @(posedge dco_clk) 
	 begin
	//calculate the noise of the tdc
	freq_noise = $itor($dist_normal(seed, 0, 1e9))/1e9;
	//normalize it
	dlf_norm   = $itor(dlf_out)/$pow(2, 8);	   		
	//calculate total capacitance  
	total_cap  = Cmin + (NumOfCourse * Course) + (NumOfFine * Fine) + (dlf_norm * SmallCap);
	//calculate fdco  
	fdco       = (1 + NsSgm*freq_noise) / (2 * pi * $sqrt(total_cap * Ind));
	//save for next  
	per_real    = (2e12 / fdco + per_acc);
	
	per_grid    = 2.0*$itor($rtoi(per_real/2.0 + 0.5)); // Round off

	per_acc     = per_real - per_grid;	
		
	 end 
//make the dco clock
   always
	 begin
	#(per_grid/2.0) dco_clk = ~dco_clk;
	 end 
endmodule