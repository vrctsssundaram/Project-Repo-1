# StreamGuard-L2

Bounded 64-bit AXI4-Stream Ethernet Layer-2 store-and-forward rule filter.

## Features

- Frame-local destination MAC and EtherType matching
- Whole-frame pass or discard, oversized frame draining
- Output backpressure and frame counters

## Run

```sh
make test
make synth-fpga
```

Design sources are in `rtl/`, directed tests in `tb/`, and interface, architecture, testing and measured results in `docs/`.

**Scope:** A single-frame buffered policy primitive; not a complete Ethernet firewall, MAC, or AXI-Lite peripheral.

Project owner: Sundaram S S.
