#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/hdl-testbenches.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT

shopt -s nullglob
testbenches=("$repo_root"/testbench/*_tb.v)
if (( ${#testbenches[@]} == 0 )); then
    echo "No test benches found in testbench/*_tb.v" >&2
    exit 1
fi

for testbench in "${testbenches[@]}"; do
    top_module="$(basename "$testbench" .v)"
    output="$build_dir/$top_module.vvp"

    echo "== Running $top_module =="
    iverilog -g2012 -s "$top_module" -o "$output" \
        "$repo_root"/src/*.v \
        "$testbench"
    (cd "$build_dir" && vvp "$output")
done

if [[ -f "$build_dir/out.vcd" ]]; then
    cp "$build_dir/out.vcd" "$repo_root/out.vcd"
    echo "Saved decoder waveform to $repo_root/out.vcd"
fi

echo "All test benches passed."
