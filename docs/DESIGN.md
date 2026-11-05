# Technical design

## Architecture

One clock domain; an input frame is stored into a finite beat memory. The first 14 bytes identify destination MAC and EtherType. The current rule is sampled when the first beat is accepted. After the frame terminates, a valid nonmatching frame is replayed to the output; matching frames are suppressed. Oversized input is drained before a fresh frame is admitted.

## State transition rules

| State | Condition | Next state |
|---|---|---|
| CAPTURE | Last beat and valid nonmatching frame | LOAD |
| CAPTURE | Last beat and matching/malformed frame | CAPTURE |
| CAPTURE | Capacity reached before last beat | DISCARD |
| LOAD | Read the first frame beat from synchronous memory | FORWARD |
| FORWARD | Final output handshake | CAPTURE |
| DISCARD | Input last-beat handshake | CAPTURE |

The output remains stable while `m_axis_tvalid=1` and `m_axis_tready=0`. Input is backpressured during both LOAD and FORWARD. Storage and replay use one synchronous write port and one synchronous read port per buffer.

## Integration profile

- The parser recognizes untagged Ethernet II headers with destination MAC and EtherType fields.
- One full frame is buffered at a time. Throughput depends on capture and replay cycles.
- Configuration enters through dedicated rule-control ports.
- Frame-header validation checks the first 14 Ethernet II bytes.
