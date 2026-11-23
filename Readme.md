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

**What is a SECDED Encoder/Decoder?**
Single Error Correction, Double Error Detection. They carry an extra bit to a traditional Hamming Code that tracks overall parity. In the case of a 15,11 Hammer, one extra bit is used on which parity of the full set of bits is checked.

**How do you determine a Hamming parity bit's coverage set?**
A parity bit at bit $2^k$ covers every position who's binary index has a $1$ in it's bit $k$

The coverage sets are as follows
- $p_0$ at position 1 - 3,5,7,9,11,13,15
- $p_1$ at position 2 - 3,6,7,10,11,14,15
- $p_2$ at position 4 - 5,6,7,12,13,14,15
- $p_3$ at position 8  - 9,10,11,12,13,14,15

**How are parity bits evaluated?**
Parity bits are obtained by getting the XOR of all the bits in the coverage set.

## Error Detection/Correction
You can calculate the position of the error as each bit position participates in a unique combination of parity checks.

The syndrome is a calculated value to tell you where the erroneous bit is.

### Detection VS Correction in SECDED
Detection and Correction are 2 different things, as suggested by the Single Error **Correction**, Double Error **Detection** of SECDED. There are essentially 3 cases that are covered by SECDED.
- Syndrome == 0, Overall parity bit passes. This is a verification that there is no detected single, or double bit errors. (Happy path)
- Syndrome != 0, Overall parity bit fails. This is an indication that there is a single bit, correctable error. 
- Syndrome != 0, Overall parity bit fails. This is an indication there's a double bit, uncorrectable error.

### How is the syndrome calculated
The Parity bit's coverage set as well as the parity bit itself are XOR'd together. This is repeated for each parity bit to give you your syndrome bits.

Putting all these bits together gives the syndrome. If the syndrome is all 0s, the check found no error. Otherwise, the syndrome identifies the position of the single flipped bit.

## How I validated the code
I use `iverilog` and `vvp` to run and validate the code using the testbench.
```
iverilog -g2012  testbench/ham_tb.v src/main.v && vvp a.out
```

## Build
`LOC` is used as opposed to `PACKAGE_PIN` for the `.xdc` for NEXTPNR as opposed to `PACKAGE_PIN` for Vivado