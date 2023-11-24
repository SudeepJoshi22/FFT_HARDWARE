\m5_TLV_version 1d: tl-x.org
\m4
   
   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================
   m4_var(SIZE,32) //size of each complex value
   m4_var(FFT_SIZE,8) //Size of the FFT
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   //m5_makerchip_module   // (Expanded in Nav-TLV pane.)
	
	module top
   #(parameter ADDR_W = 4)
      (
     input wire clk,
     input wire reset_n,
     input wire [31:0] a,
     input wire [31:0] b,
     input wire [ADDR_W-1:0] tw_addr,
     output wire [31:0] c_plus,
     output wire [31:0] c_minus
   );
\TLV dif_butterfly(@_stage) 
   //Butterfly Unit for RADIX-2 DIF FFT
   // C = A + B
   // D = W(A - B)
   // Dividing Complex multiplciations into real and imaginary parts
   // Cr = Ar + Br
   // Ci = Ai + Bi
   // Dr = Wr*(Ar - Br) - Wi*(Ai - Bi)
   // Di = Wr*(Ai - Bi) + Wi*(Ar - Br)
   @_stage
      \SV_plus
         wire [31:0] twiddles [0:3];
         assign twiddles[0] = 32'h00000100;
         assign twiddles[1] = 32'hFF4B00B5;
         assign twiddles[2] = 32'hFF000000;
         assign twiddles[3] = 32'hFF4BFF4B;
      $w[31:0] = *twiddles[$addr];
      $cr[15:0] = $a[31:16] + $a[31:16];
      $ci[15:0] = $a[15:0] + $b[15:0];
      $dr[15:0] = $w[31:16]*($a[31:16] - $b[31:16]) - $w[15:0]*($a[15:0] - $b[15:0]);
      $di[15:0] = $w[31:16]*($a[15:0] - $b[15:0]) + $w[15:0]*($a[31:16] - $b[31:16]);
      $c[31:0] = {$cr,$ci};
      $d[31:0] = {$dr,$di};
      

\TLV
   |butterfly1
      @0
         //$A[31:0] = 32'h00010001;
         //$B[31:0] = 32'h00020002;
         //$W[31:0] = 32'hff4b00b5;
         $a[31:0] = *a;
         $b[31:0] = *b;
         $addr[3:0] = *tw_addr;
      //after 6 delay stages
      @8
         *c_plus = $c;
         *c_mius = $d;
      
      m4+dif_butterfly(@1)

\SV
   endmodule

