module axis_l2_policy #(
    parameter integer MAX_BEATS = 256
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [63:0]  s_axis_tdata,
    input  wire [7:0]   s_axis_tkeep,
    input  wire         s_axis_tvalid,
    output wire         s_axis_tready,
    input  wire         s_axis_tlast,
    output wire [63:0]  m_axis_tdata,
    output wire [7:0]   m_axis_tkeep,
    output wire         m_axis_tvalid,
    input  wire         m_axis_tready,
    output wire         m_axis_tlast,
    input  wire         cfg_rule_enable,
    input  wire         cfg_match_dst,
    input  wire         cfg_match_ethertype,
    input  wire [47:0]  cfg_dst_mac,
    input  wire [15:0]  cfg_ethertype,
    output reg  [31:0]  frames_forwarded,
    output reg  [31:0]  frames_dropped,
    output reg  [31:0]  frames_oversize,
    output reg  [31:0]  frames_malformed
);
    localparam integer CW = $clog2(MAX_BEATS + 1);
    localparam [1:0] CAPTURE = 2'd0, FORWARD = 2'd1, DISCARD = 2'd2, LOAD = 2'd3;
    reg [1:0] state;
    reg [63:0] data_ram [0:MAX_BEATS-1];
    reg [7:0]  keep_ram [0:MAX_BEATS-1];
    reg        last_ram [0:MAX_BEATS-1];
    reg [CW-1:0] captured;
    reg [CW-1:0] sending;
    reg [CW-1:0] frame_beats;
    reg [63:0] output_data;
    reg [7:0] output_keep;
    reg output_last;
    reg [47:0] frame_dst_mac;
    reg [15:0] frame_ethertype;
    reg [15:0] frame_rule_ethertype;
    reg [47:0] frame_rule_dst_mac;
    reg frame_first_full;
    reg frame_header_valid;
    reg frame_rule_enable;
    reg frame_match_dst;
    reg frame_match_ethertype;
    wire read_enable = (state == LOAD) ||
        (state == FORWARD && m_axis_tready && sending != frame_beats - 1'b1);
    wire [CW-1:0] read_address = (state == LOAD) ? sending : sending + 1'b1;
    wire store_beat = (state == CAPTURE) && s_axis_tvalid;

    wire [15:0] this_ethertype = {s_axis_tdata[39:32], s_axis_tdata[47:40]};
    wire header_ok = (captured == 1)
        ? (frame_first_full && (&s_axis_tkeep[5:0]))
        : ((captured > 1) && frame_header_valid);
    wire [15:0] checked_ethertype = (captured == 1) ? this_ethertype : frame_ethertype;
    wire matching_rule = frame_rule_enable &&
        (!frame_match_dst || frame_dst_mac == frame_rule_dst_mac) &&
        (!frame_match_ethertype || checked_ethertype == frame_rule_ethertype);

    // The LOAD cycle only primes the synchronous read port; it cannot
    // accept a new input beat until this frame finishes forwarding.
    assign s_axis_tready = (state == CAPTURE || state == DISCARD);
    assign m_axis_tvalid = (state == FORWARD);
    assign m_axis_tdata = output_data;
    assign m_axis_tkeep = output_keep;
    assign m_axis_tlast = output_last;

    // One synchronous write port and one clocked read port per buffer.
    always @(posedge clk) begin
        if (store_beat) begin
            data_ram[captured] <= s_axis_tdata;
            keep_ram[captured] <= s_axis_tkeep;
            last_ram[captured] <= s_axis_tlast;
        end
        if (read_enable) begin
            output_data <= data_ram[read_address];
            output_keep <= keep_ram[read_address];
            output_last <= last_ram[read_address];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= CAPTURE;
            captured <= 0;
            sending <= 0;
            frame_beats <= 0;
            frame_dst_mac <= 0;
            frame_ethertype <= 0;
            frame_rule_ethertype <= 0;
            frame_rule_dst_mac <= 0;
            frame_first_full <= 0;
            frame_header_valid <= 0;
            frame_rule_enable <= 0;
            frame_match_dst <= 0;
            frame_match_ethertype <= 0;
            frames_forwarded <= 0;
            frames_dropped <= 0;
            frames_oversize <= 0;
            frames_malformed <= 0;
        end else begin
            case (state)
                CAPTURE: if (s_axis_tvalid) begin
                    if (captured == 0) begin
                        frame_dst_mac <= s_axis_tdata[47:0];
                        frame_first_full <= &s_axis_tkeep;
                        frame_header_valid <= 0;
                        frame_rule_enable <= cfg_rule_enable;
                        frame_match_dst <= cfg_match_dst;
                        frame_match_ethertype <= cfg_match_ethertype;
                        frame_rule_dst_mac <= cfg_dst_mac;
                        frame_rule_ethertype <= cfg_ethertype;
                    end
                    if (captured == 1) begin
                        frame_ethertype <= this_ethertype;
                        frame_header_valid <= frame_first_full && (&s_axis_tkeep[5:0]);
                    end
                    if (s_axis_tlast) begin
                        if (!header_ok) begin
                            frames_dropped <= frames_dropped + 1;
                            frames_malformed <= frames_malformed + 1;
                            captured <= 0;
                        end else if (matching_rule) begin
                            frames_dropped <= frames_dropped + 1;
                            captured <= 0;
                        end else begin
                            frame_beats <= captured + 1'b1;
                            sending <= 0;
                            state <= LOAD;
                        end
                    end else if (captured == MAX_BEATS-1) begin
                        state <= DISCARD;
                        frames_dropped <= frames_dropped + 1;
                        frames_oversize <= frames_oversize + 1;
                        captured <= 0;
                    end else begin
                        captured <= captured + 1'b1;
                    end
                end
                LOAD: begin
                    state <= FORWARD;
                end
                FORWARD: if (m_axis_tready) begin
                    if (sending == frame_beats - 1'b1) begin
                        sending <= 0;
                        captured <= 0;
                        state <= CAPTURE;
                        frames_forwarded <= frames_forwarded + 1;
                    end else begin
                        sending <= sending + 1'b1;
                    end
                end
                DISCARD: if (s_axis_tvalid && s_axis_tlast) begin
                    captured <= 0;
                    state <= CAPTURE;
                end
                default: state <= CAPTURE;
            endcase
        end
    end
endmodule
