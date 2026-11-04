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