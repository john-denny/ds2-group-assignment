# SECDED encoder and decoder

Digital Systems 2 mini project, Group 15.

This design encodes 11 data bits into a 16-bit SECDED codeword: a 15-bit Hamming code with one additional overall parity bit. The decoder detects single-bit and double-bit errors. In decoder mode, the FPGA indicates a single-bit error on the corresponding LED so the user can correct it by changing the matching switch. The decoder does not produce a separate corrected-data output.

## Using the Basys 3

- The center button resets the design to decoder mode.
- The up button toggles between decoder and encoder mode. A press must remain stable for about 10 ms; the filter also waits for a stable release before accepting another press.
- In decoder mode, switches SW15–SW0 provide the received 16-bit codeword. For a single-bit error, the matching LED indicates which switch to flip. For example, an error in input bit 0 lights LD0; an error in the overall parity bit (input bit 15) lights LD15.
- For a detected double-bit error, the decoder turns off the location LEDs and displays `d2E` on the seven-segment display. A double-bit error has no unique bit location to indicate.
- In encoder mode, switches SW10–SW0 provide the 11-bit data word, and LEDs LD15–LD0 show the encoded codeword. SW15–SW11 should be off; setting any of them indicates invalid encoder input.

The Basys 3 pin assignments are in [`src/constraints/ham-basys3.xdc`](src/constraints/ham-basys3.xdc). The seven-segment display is multiplexed. `main_tb` uses a shortened refresh interval to check all four digit selects and the displayed patterns. See [`testbench/decoder_on_device.md`](testbench/decoder_on_device.md) for decoder cases to check on the board.

## Building for the Basys 3

From the repository root, combine the Verilog sources and invoke `srinny` with the Basys 3 constraints:

```sh
{ for f in src/main.v src/decoder.v src/encoder.v src/mode.v src/seven_segment_display.v; do cat "$f"; printf '\n'; done; } > /tmp/ds2-main.v
srinny /tmp/ds2-main.v --top main --xdc "$PWD/src/constraints/ham-basys3.xdc"
```

This is the command used by [`src/scripts/program_basys3.sh`](src/scripts/program_basys3.sh).

## SECDED error cases

The four Hamming parity checks form a syndrome for codeword bits 0–14. The overall parity check covers all 16 bits. Together they distinguish these cases:

| Syndrome | Overall parity mismatch | Meaning | Decoder response |
|---|---|---|---|
| 0 | No | No detected error | No location LED |
| Nonzero | Yes | Single error in bits 0–14 | Light LED `syndrome - 1` so the user can flip that switch |
| 0 | Yes | Single error in bit 15 | Light LD15 |
| Nonzero | No | Detected double-bit error | No location LED; display `d2E` |

SECDED can locate and indicate a single-bit error for manual correction. It cannot identify which bits are wrong in a double-bit error.

## Running the test benches

Install Icarus Verilog (`iverilog` and `vvp`), then run:

```sh
./testbench/run.sh
```

The runner discovers `testbench/*_tb.v`, uses the filename without `.v` as the top-module name, compiles it with the Verilog files in `src/`, and runs it. Name each new bench and its top module consistently (for example, `display_tb.v` containing `module display_tb`). The current benches cover encoder, decoder, integration, mode-button debounce, and seven-segment outputs. The physical display and pin mapping still need board validation.

GitHub Actions runs the same script on pushes and pull requests.
