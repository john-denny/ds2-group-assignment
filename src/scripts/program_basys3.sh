cd ~/Coding/ds2-group-assignment
{ for f in src/main.v src/decoder.v src/encoder.v src/mode.v src/seven_segment_display.v; do cat "$f"; printf '\n'; done; } > /tmp/ds2-main.v
srinny /tmp/ds2-main.v --top main --xdc "$PWD/src/constraints/ham-basys3.xdc"