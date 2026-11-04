# Interface summary

| Parameter / signal | Meaning |
|---|---|
| `MAX_BEATS` | Number of 64-bit beats in the frame buffer; minimum 2 |
| `clk`, `rst_n` | Single system clock, asynchronous active-low reset |
| `s_axis_*` | 64-bit input, 8-bit TKEEP, valid/ready, TLAST |
| `m_axis_*` | 64-bit output, 8-bit TKEEP, valid/ready, TLAST |
| `cfg_rule_enable` | Enable dropping matching frames |
| `cfg_match_dst` | Qualify the rule using destination MAC |
| `cfg_dst_mac` | Byte-order: first destination byte in bits 7:0 |
| `cfg_match_ethertype` | Qualify the rule using EtherType |
| `cfg_ethertype` | Conventional 16-bit EtherType value |
| `frames_forwarded` | Output frames completed |
| `frames_dropped` | Policy, malformed, and oversize drops |
| `frames_oversize` | Oversize subset of dropped frames |
| `frames_malformed` | Header-invalid subset of dropped frames |

Use `TKEEP=8'hff` on all non-final beats. The final beat must contain valid bytes from bit 0 upward. The first 14 bytes must be present.

No frequency, area, bandwidth, or power claim is made without implementation results.
