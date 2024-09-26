`timescale 1ps/1fs

module TDC_ENCODER(
	input wire [63:0] samples,
	input wire inv_dir,
	output reg [15:0] edges1, // Updated to 16 bits to accommodate 10-bit fractional part
	output reg [15:0] edges2  // Updated to 16 bits to accommodate 10-bit fractional part
);
	// Intermediate wires
	reg [60:0] rises;
	reg [60:0] falls;
	reg [63:0] vec_samples;
	
	// Always block to call the priority encoder task
	always @(*) begin
		// Inverted samples if cb is high, otherwise original samples
		if(inv_dir) begin
			vec_samples = ~samples;
		end else begin
			vec_samples = samples;
		end
		

		// Bubble killer logic for rises and falls
		rises = ~vec_samples[60:0] & ~vec_samples[61:1] & ~vec_samples[62:2] & vec_samples[63:3];
		falls = vec_samples[60:0] & vec_samples[61:1] & vec_samples[62:2] & ~vec_samples[63:3];
		
		//makes encoder
		priority_encoder(rises, edges1);
		priority_encoder(falls, edges2);	
	end

	// Priority encoder task
	task priority_encoder(
		input [60:0] in,   // 61-bit input
		output reg [15:0] out // 16-bit output to include 10-bit fractional part
	);
		begin
			out = 16'd0; // Default output

			// Check each bit in ascending order
			if (in[1]) begin
				out = {6'd1, 10'd0};
			end else if (in[2]) begin
				out = {6'd2, 10'd0};
			end else if (in[3]) begin
				out = {6'd3, 10'd0};
			end else if (in[4]) begin
				out = {6'd4, 10'd0};
			end else if (in[5]) begin
				out = {6'd5, 10'd0};
			end else if (in[6]) begin
				out = {6'd6, 10'd0};
			end else if (in[7]) begin
				out = {6'd7, 10'd0};
			end else if (in[8]) begin
				out = {6'd8, 10'd0};
			end else if (in[9]) begin
				out = {6'd9, 10'd0};
			end else if (in[10]) begin
				out = {6'd10, 10'd0};
			end else if (in[11]) begin
				out = {6'd11, 10'd0};
			end else if (in[12]) begin
				out = {6'd12, 10'd0};
			end else if (in[13]) begin
				out = {6'd13, 10'd0};
			end else if (in[14]) begin
				out = {6'd14, 10'd0};
			end else if (in[15]) begin
				out = {6'd15, 10'd0};
			end else if (in[16]) begin
				out = {6'd16, 10'd0};
			end else if (in[17]) begin
				out = {6'd17, 10'd0};
			end else if (in[18]) begin
				out = {6'd18, 10'd0};
			end else if (in[19]) begin
				out = {6'd19, 10'd0};
			end else if (in[20]) begin
				out = {6'd20, 10'd0};
			end else if (in[21]) begin
				out = {6'd21, 10'd0};
			end else if (in[22]) begin
				out = {6'd22, 10'd0};
			end else if (in[23]) begin
				out = {6'd23, 10'd0};
			end else if (in[24]) begin
				out = {6'd24, 10'd0};
			end else if (in[25]) begin
				out = {6'd25, 10'd0};
			end else if (in[26]) begin
				out = {6'd26, 10'd0};
			end else if (in[27]) begin
				out = {6'd27, 10'd0};
			end else if (in[28]) begin
				out = {6'd28, 10'd0};
			end else if (in[29]) begin
				out = {6'd29, 10'd0};
			end else if (in[30]) begin
				out = {6'd30, 10'd0};
			end else if (in[31]) begin
				out = {6'd31, 10'd0};
			end else if (in[32]) begin
				out = {6'd32, 10'd0};
			end else if (in[33]) begin
				out = {6'd33, 10'd0};
			end else if (in[34]) begin
				out = {6'd34, 10'd0};
			end else if (in[35]) begin
				out = {6'd35, 10'd0};
			end else if (in[36]) begin
				out = {6'd36, 10'd0};
			end else if (in[37]) begin
				out = {6'd37, 10'd0};
			end else if (in[38]) begin
				out = {6'd38, 10'd0};
			end else if (in[39]) begin
				out = {6'd39, 10'd0};
			end else if (in[40]) begin
				out = {6'd40, 10'd0};
			end else if (in[41]) begin
				out = {6'd41, 10'd0};
			end else if (in[42]) begin
				out = {6'd42, 10'd0};
			end else if (in[43]) begin
				out = {6'd43, 10'd0};
			end else if (in[44]) begin
				out = {6'd44, 10'd0};
			end else if (in[45]) begin
				out = {6'd45, 10'd0};
			end else if (in[46]) begin
				out = {6'd46, 10'd0};
			end else if (in[47]) begin
				out = {6'd47, 10'd0};
			end else if (in[48]) begin
				out = {6'd48, 10'd0};
			end else if (in[49]) begin
				out = {6'd49, 10'd0};
			end else if (in[50]) begin
				out = {6'd50, 10'd0};
			end else if (in[51]) begin
				out = {6'd51, 10'd0};
			end else if (in[52]) begin
				out = {6'd52, 10'd0};
			end else if (in[53]) begin
				out = {6'd53, 10'd0};
			end else if (in[54]) begin
				out = {6'd54, 10'd0};
			end else if (in[55]) begin
				out = {6'd55, 10'd0};
			end else if (in[56]) begin
				out = {6'd56, 10'd0};
			end else if (in[57]) begin
				out = {6'd57, 10'd0};
			end else if (in[58]) begin
				out = {6'd58, 10'd0};
			end else if (in[59]) begin
				out = {6'd59, 10'd0};
			end else if (in[60]) begin
				out = {6'd60, 10'd0};
			end else begin
				out = 16'd0;
			end
		end
	endtask

endmodule