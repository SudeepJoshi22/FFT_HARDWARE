\m5_TLV_version 1d: tl-x.org
\m5
   
   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================
   use(m5-1.0)   /// uncomment to use M5 macro library.
   var(size,32) //size of each complex value
   var(fft_size,16) //Size of the FFT
   var(fraction_bits,8) // Q(size-fraction_bits).(fraction_bits)
   var(stage_delay,1) //delay between the pipelined fft stages
   
   macro(fftstage, ['$1'])
\SV
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_lib/db48b4c22c4846c900b3fa307e87d9744424d916/fundamentals_lib.tlv'])

   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
                   
   wire [31:0] twiddles [0:3];
   assign twiddles[0] = 32'h0100_0000;
   assign twiddles[1] = 32'h00B5_FF4B;
   assign twiddles[2] = 32'h0000_FF00;
   assign twiddles[3] = 32'hFF4B_FF4B;
	
   wire [31:0] x [0:7];
   assign x[0] = {16'h0100, 16'hff00};
   assign x[1] = {16'h0200, 16'h0200};
   assign x[2] = {16'hfd00, 16'h0300};
   assign x[3] = {16'h0400, 16'h0400};
   assign x[4] = {16'h0500, 16'hfb00};
   assign x[5] = {16'hfa00, 16'h0600};
   assign x[6] = {16'hf900, 16'h0700};
   assign x[7] = {16'h0800, 16'hf800};
    
   wire [31:0] X0 [0:7];
   wire [31:0] X1 [0:7];
   wire [31:0] X2 [0:7];

\TLV signed_multiplier($_out, $_in1, $_in2)
   $_out = \$signed($_in1) * \$signed($_in2);

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
   $ww[31:0] = *twiddles\[$addr\];
   $wr[15:0] = $ww[31:16];
   $wi[15:0] = $ww[15:0];
   $ar[15:0] = $aa[31:16];
   $ai[15:0] = $aa[15:0];
   $br[15:0] = $bb[31:16];
   $bi[15:0] = $bb[15:0];
   $temp1[15:0] = ($ai - $bi);
   $temp2[15:0] = ($ar - $br);
   m5+signed_multiplier($temp3[31:0], $wr, $temp1)
   m5+signed_multiplier($temp4[31:0], $wi, $temp2)
   m5+signed_multiplier($temp5[31:0], $wr, $temp2)
   m5+signed_multiplier($temp6[31:0], $wi, $temp1)
   $cr[15:0] = $ar + $br;
   $ci[15:0] = $ai + $bi;
   $dr[31:0] = \$signed($temp5) - \$signed($temp6);
   $di[31:0] = \$signed($temp3) + \$signed($temp4);
   $cc[31:0] = {$cr,$ci};
   $dd[31:0] = {$dr[23:8],$di[23:8]};
   \SV_plus
      assign X\m5_strip_prefix(@_stage)[$a_index] = $cc;
      assign X\m5_strip_prefix(@_stage)[$b_index] = $dd;


\TLV stage_logic(@_stage)
   
      
   /bfus\m5_strip_prefix(@_stage)[3:0]
      @\m5_calc(\m5_strip_prefix(@_stage)-1)
         $stage[1:0] = \m5_strip_prefix(@_stage);
         $bfus[1:0] = #bfus\m5_strip_prefix(@_stage);
         $div[3:0] = ($stage == 0) ? 8:
                     ($stage  == 1) ? 4:
                     ($stage == 2) ? 2:  1;
         $addr[2:0] = (#bfus\m5_strip_prefix(@_stage) << \m5_strip_prefix(@_stage)) % $div;
         $a_index[2:0] = ($stage == 0) ? {1'b0,$bfus}:
                         ($stage == 1) ? {$bfus[1],1'b0,$bfus[0]} :
                         ($stage == 2) ? {$bfus,1'b0} : 0;
         $b_index[2:0] = ($stage == 0) ? {1'b1,$bfus}:
                         ($stage == 1) ? {$bfus[1],1'b1,$bfus[0]} :
                         ($stage == 2) ? {$bfus,1'b1}:  0;
         m5_if_eq(\m5_strip_prefix(@_stage),0,
         ['
         $aa[31:0] = *x\[$a_index\];
         '],
         ['
         $aa[31:0] = *X\m5_calc(\m5_strip_prefix(@_stage)-1)\[$a_index\];
         '])
         m5_if_eq(\m5_strip_prefix(@_stage),0,
         ['
         $bb[31:0] = *x\[$b_index\];
         '],
         ['
         $bb[31:0] = *X\m5_calc(\m5_strip_prefix(@_stage)-1)\[$b_index\];
         '])

         //dif butterfly
      m5+dif_butterfly(@_stage)


\TLV
   $reset = *reset;
   
   //for testing butterfly
   |butterfly1
      @0
         $aa[31:0] = 32'hfd2c_02d4;
         $bb[31:0] = 32'h02d4_02d4;
         $addr[1:0] = 2;
      //m5+dif_butterfly(@1) //comment this while testing |fft
   
   //8-point FFT will have 3 stages and 4 BFUs per stage
   |fft
      m5+stage_logic(@0)
      m5+stage_logic(@1)
      m5+stage_logic(@2)
      /*
      /or_parameterized
         m4+forloop(i, 0, 4,
            \TLV
               m5+stage_logic(@m4_i)
            )
      */
      
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

