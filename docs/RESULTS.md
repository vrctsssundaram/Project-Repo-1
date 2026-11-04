# Verification record

Date: 04 November 2026
Source revision tested: `0bd3540495f4c2b2e8a3cf3d9293fcfb251572d8`
Hosted regression: https://github.com/vrctsssundaram/Project-Repo-1/actions/runs/41868645596

| Measurement | Recorded result |
|---|---|
| SystemVerilog compilation | **PASS** (`iverilog -g2012 -Wall`) |
| Self-checking simulation | **PASS** (`vvp`, exit code 0) |
| Directed checks | forwarding, backpressure, drop, malformed, oversize, disabled rule |
| FPGA synthesis / utilization | **Not run** |
| Static timing / Fmax | **Not measured** |
| Power and hardware throughput | **Not measured** |

The recorded checks apply to the named revision and exercise the bounded first implementation. No waveform image, fabricated timing report or estimated resource figure is presented as measured evidence.
