# Technical design

## Architecture

One clock domain; an input frame is stored into a finite beat memory. The first 14 bytes identify destination MAC and EtherType. The current rule is sampled when the first beat is accepted. After the frame terminates, a valid nonmatching frame is replayed to the output; matching frames are suppressed. Oversized input is drained before a fresh frame is admitted.

## State transition rules

| State | Condition | Next state |
|---|---|---|
| CAPTURE | Last beat and valid nonmatching frame | FORWARD |
| CAPTURE | Last beat and matching/malformed frame | CAPTURE |
| CAPTURE | Capacity reached before last beat | DISCARD |
| FORWARD | Final output handshake | CAPTURE |
| DISCARD | Input last-beat handshake | CAPTURE |

The output remains stable while `m_axis_tvalid=1` and `m_axis_tready=0`. Input is backpressured for the entire forwarding phase.

## Limitations

- This revision handles untagged Ethernet II headers only; VLAN EtherType interpretation requires an extension.
- One full frame is buffered at a time. Throughput depends on capture and replay cycles.
- Configuration is a direct control port, not an AXI-Lite slave.
- Only basic first-14-byte structural validation is performed.
