# Verification record

Date: 04 November 2026
Source revision tested: `fa9685d99518f7f0d49b32493e62113585354d9a`
Hosted regression: https://github.com/vrctsssundaram/Project-Repo-1/actions/runs/41873313422
FPGA-family mapping: https://github.com/vrctsssundaram/Project-Repo-1/actions/runs/41873312860

| Measurement | Recorded result |
|---|---|
| SystemVerilog compilation | **PASS** (`iverilog -g2012 -Wall`) |
| Self-checking simulation | **PASS** (`vvp`, exit code 0) |
| Directed checks | forwarding, backpressure, input `TREADY` during buffer load, drop, malformed, oversize, disabled rule |
| Generic Yosys synthesis | **PASS** |
| XC7-family Yosys technology mapping | **PASS**; see primitive counts below |

## XC7-family mapped primitives (default MAX_BEATS=256)

| Primitive family | Count |
|---|---:|
| RAMB36E1 | 1 |
| RAM64M | 16 |
| LUT1–LUT6, combined | 158 |
| FDCE + FDPE + FDRE | 301 |
| CARRY4 | 41 |

**Evidence:** Tool-reported Icarus Verilog regression and Yosys synthesis results for the source revision cited above.
