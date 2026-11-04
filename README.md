# StreamGuard-L2

Deterministic store-and-forward Layer-2 rule filter for a 64-bit AXI4-Stream interface.

## Features

- Entire-frame forwarding or dropping based on a programmable destination MAC and/or EtherType rule.
- Frame-local rule snapshot at start of frame.
- Backpressure-safe output and bounded frame storage.
- Malformed-header rejection, oversized-frame discard, and 32-bit frame counters.
- Independently runnable self-checking SystemVerilog regression.

## Quick start

```sh
make test
```

Files: `rtl/` (synthesizable design), `tb/` (testbench), `docs/` (interface and verification records).

This is a bounded single-frame engine. It is not a wire-rate Ethernet MAC, AXI-Lite peripheral, or certified security appliance.

Project owner: Sundaram S S.
