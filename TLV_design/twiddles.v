`ifdef N
	`if (N == 4)
		   wire [31:0] twiddles [0:3];
		   assign twiddles[0] = 32'h0100_0000;
		   assign twiddles[1] = 32'h00B5_FF4B;
		   assign twiddles[2] = 32'h0000_FF00;
		   assign twiddles[3] = 32'hFF4B_FF4B;
	`else if(N == 8)
		   wire [31:0] twiddles [0:7];
		   assign twiddles[0] = 32'h0100_0000;
		   assign twiddles[1] = 32'h00B5_FF4B;
		   assign twiddles[2] = 32'h0000_FF00;
		   assign twiddles[3] = 32'hFF4B_FF4B;
		   assign twiddles[4] = 32'hFF4B_FF4B;
		   assign twiddles[5] = 32'hFF4B_FF4B;
		   assign twiddles[6] = 32'hFF4B_FF4B;
		   assign twiddles[7] = 32'hFF4B_FF4B;
	
	`endif
`endif      
