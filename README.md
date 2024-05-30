# FFT_HARDWARE
FFT Hardware written in TL-Verilog.

### Verifying the FFT Design
Following test-values have been considered to verify the FFT Design

#### Complex Numbers Transformation Table

| **Time Domain** | **Frequency Domain**  | **Frequency Domain in Hex** | **Bit-Reversal** |
|-----------------|-----------------------|-----------------------------|------------------|
| 1 - j           | 8 + 4j                | 0800_0400                   | 0400_0800        |
| 2 + 2j          | -0.48 + 2.82j         | 0624_f1dc                   | f400_0000        |
| -3 + 3j         | -32 + 4j              | 1c00_0000                   | 1c00_0000        |
| 4 + 4j          | 14.14 - 22.14j        | fd2c_107c                   | 0400_e000        |
| 5 - 5j          | 0 - 12j               | f400_0000                   | 0624_f1dc        |
| -6 + 6j         | 16.48 - 2.82j         | e9dc_0e24                   | e9dc_0e24        |
| -7 + 7j         | 0 - 28j               | 0400_e000                   | fd2c_107c        |
| 8 - 8j          | -14.14 + 6.14j        | 02d4_ff84                   | 02d4_ff84        |


