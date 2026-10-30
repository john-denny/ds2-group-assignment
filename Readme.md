## Digital Systems 2 - Mini Project
**Group Number** 15 - Custom Error Detection and Correction

**Objective**: Design and simulate an (15,11) Hamming Encoder and Decoder
module.

**Requirements:**
- Detect and correct single-bit errors and identify uncorrectable double-bit errors.
- Display intermediate parity and syndrome results in waveform.
- For FPGA demonstration, enter the information word using switches, inject a selected error using board controls, and display the decoded data/syndrome/error status using LEDs/seven-segment display.

### Background
**What are Hamming Encoders & Decoders?**
Hamming encoders add Parity bits to data to create a codeword. These parity bits allow us to detect errors that may have occurred in transmission.
A (15,11) hamming encoder takes 11 bits of data and adds 4 parity bits to create a 15 bit total codeword.

**How do you determine a parity bit's coverage set?**
A parity bit at bit $2^k$ covers every position who's binary index has a $1$ in it's bit $k$

The coverage sets are as follows
- $p_0$ - 1,3,5,7,9,11,13,15
- $p_1$ - 2,3,6,7,10,11,14,15
- $p_2$ - 4,5,6,7,12,13,14,15
- $p_3$ - 8,9,10,11,12,13,14,15

**How are parity bits evaluated?**
Parity bits are obtained by getting the XOR of all the bits in the coverage set.