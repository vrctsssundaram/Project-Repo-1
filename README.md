# Layer 2 Ethernet frame filter

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

**Architecture:** Single-frame Ethernet II capture, destination MAC/EtherType policy evaluation and AXI4-Stream replay.

Project owner: Sundaram S S.
