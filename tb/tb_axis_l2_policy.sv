module tb_axis_l2_policy;
    timeunit 1ns; timeprecision 1ps;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n = 0;
    reg [63:0] s_data = 0;
    reg [7:0] s_keep = 0;
    reg s_valid = 0;
    reg s_last = 0;
    wire s_ready;
    wire [63:0] m_data;
    wire [7:0] m_keep;
    wire m_valid;
    wire m_last;
    reg m_ready = 1;
    reg rule_enable = 1;
    reg match_dst = 0;
    reg match_type = 1;
    reg [47:0] dst_mac = 0;
    reg [15:0] etype = 16'h0806;
    wire [31:0] forwarded, dropped, oversize, malformed;
    integer out_beats = 0;
    localparam [63:0] FIRST = 64'h7766554433221100;
    localparam [63:0] IPV4 = 64'h00000008bbaa9988;
    localparam [63:0] ARP  = 64'h00000608bbaa9988;

    axis_l2_policy #(.MAX_BEATS(4)) dut (
        .clk(clk), .rst_n(rst_n),
        .s_axis_tdata(s_data), .s_axis_tkeep(s_keep),
        .s_axis_tvalid(s_valid), .s_axis_tready(s_ready), .s_axis_tlast(s_last),
        .m_axis_tdata(m_data), .m_axis_tkeep(m_keep),
        .m_axis_tvalid(m_valid), .m_axis_tready(m_ready), .m_axis_tlast(m_last),
        .cfg_rule_enable(rule_enable), .cfg_match_dst(match_dst),
        .cfg_match_ethertype(match_type), .cfg_dst_mac(dst_mac), .cfg_ethertype(etype),
        .frames_forwarded(forwarded), .frames_dropped(dropped),
        .frames_oversize(oversize), .frames_malformed(malformed)
    );
    always @(posedge clk) if (rst_n && m_valid && m_ready) begin
        if ((out_beats % 2) == 0) begin
            if (m_data !== FIRST || m_keep !== 8'hff || m_last !== 1'b0)
                $fatal(1, "Incorrect first output beat");
        end else begin
            if (m_data !== IPV4 || m_keep !== 8'h3f || m_last !== 1'b1)
                $fatal(1, "Incorrect final output beat");
        end
        out_beats = out_beats + 1;
    end
    task automatic send(input [63:0] data, input [7:0] keep, input last);
        begin
            @(negedge clk);
            s_data = data; s_keep = keep; s_last = last; s_valid = 1;
            @(posedge clk);
            while (!s_ready) @(posedge clk);
            @(negedge clk);
            s_valid = 0; s_last = 0;
        end
    endtask
    task automatic wait_cycles(input integer n);
        integer k;
        begin for (k=0; k<n; k=k+1) @(posedge clk); end
    endtask
    initial begin
        wait_cycles(3);
        @(negedge clk); rst_n = 1;
        // Accepted IPv4 frame; output remains stable during backpressure.
        m_ready = 0;
        send(FIRST, 8'hff, 0);
        send(IPV4, 8'h3f, 1);
        wait_cycles(2);
        if (!m_valid || m_data !== FIRST || m_last)
            $fatal(1, "Forwarding data not held under backpressure");
        @(negedge clk); m_ready = 1;
        wait_cycles(5);
        if (out_beats != 2 || forwarded != 1) $fatal(1, "Forward counter");

        // Matching EtherType is dropped.
        send(FIRST, 8'hff, 0);
        send(ARP, 8'h3f, 1);
        wait_cycles(3);
        if (dropped != 1 || out_beats != 2) $fatal(1, "Drop rule");

        // Truncated Ethernet header is malformed.
        send(FIRST, 8'hff, 1);
        wait_cycles(2);
        if (dropped != 2 || malformed != 1) $fatal(1, "Malformed frame");

        // Five beats exceed the four-beat configured storage limit.
        send(FIRST, 8'hff, 0);
        send(IPV4, 8'hff, 0);
        send(64'h55, 8'hff, 0);
        send(64'h66, 8'hff, 0);
        send(64'h77, 8'h01, 1);
        wait_cycles(2);
        if (dropped != 3 || oversize != 1) $fatal(1, "Oversize frame");

        // Disabled rule forwards the previously rejected EtherType.
        rule_enable = 0;
        send(FIRST, 8'hff, 0);
        send(IPV4, 8'h3f, 1);
        wait_cycles(5);
        if (forwarded != 2 || out_beats != 4)
            $fatal(1, "Disabled rule forwarding");
        $display("PASS: forwarding, backpressure, drop, malformed, oversize, disabled rule");
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "Watchdog timeout");
    end
endmodule
