# Test procedure

1. Install a SystemVerilog-capable Icarus Verilog toolchain.
2. Run `make test` from the repository root.
3. Confirm the process exits with code 0 and prints `PASS`.
4. Review the repository CI run for the same commit.

The self-checking testbench covers:

1. Successful IPv4 frame forwarding.
2. Output backpressure while the first beat is held.
3. EtherType-based frame drop.
4. Truncated-header rejection.
5. Oversized-frame drain.
6. Rule-disable behavior.

For FPGA qualification, also run synthesis, static timing, resource and power reports on the target part. These are separate from the simulation regression.
