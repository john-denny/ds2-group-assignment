## How the fuck do we actually make this?
- You enter the sequence on the switches. 
    - Read in from the switches
- The LEDS indicate above any erroneous bits

- Need to have 4 parity bits running
    - Read in the parity bit
    - we can likely just calculate the parity bits by XORing a shit ton of stuff together.
    - Calculate whether the parity bit is right or wrong.    

- Number of errors should be displayed on the seven segs
- If there's time, dump them to a log via one of the IOs

Plan
- We can hardcode each of the parity bits generation
- We can hardcode the syndrome generation
--- 
- Read in the user input via the switches
- Generate parity bits
- Generate the syndrome
- Display the erroneous bit calculated by the syndrome


--- 
# Reimplementation for SECDED Encoder & Decoder
The codebase's current functionality is just a hamming decoder. We'll need to add.

- The ability to switch between encode and decode.
- The actual encoder
- Update the decoder to do overall parity bit
- Figure out how we'll communicate a double bit vs single bit error.
- Figure out how inputs will work.

### UI for Encode
- User uses the rightmost switches to enter the 11 bits. 
- 16 lights will illuminate to represent the encoded sequence.

### UI for Decode
- User enters the 16 bits on the 16 switches
- Single bit errors cause an LED to be lit
- Double bit errors cause a 7 seg display.


### Nice to Haves
- Text on 7 seg explaining where the dead bit is
- Text explaining if there's a double bit error.
- Text on 7 seg explaining whether we're in Encode or decode (Mode 1 or 2)
--- 
## Implementation of the states
Looking at it, it seems it'll be easier to just implement the encoder and decoder to run all the time, then have a block that's running in parallel which switches whether it's in encode or decode.