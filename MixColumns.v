// aES Mixcolumns implementation for 128-bit input
module MixColumns (
    input  [127:0] B,  // Input state (128 bits: 4x4 bytes matrix)
    output [127:0] D   // Output state (128 bits)
);

    // Extract individual bytes from the 128-bit input
    wire [7:0] B0 = B[127:120];
    wire [7:0] B1 = B[119:112];
    wire [7:0] B2 = B[111:104];
    wire [7:0] B3 = B[103:96];
    wire [7:0] B4 = B[95:88];
    wire [7:0] B5 = B[87:80];
    wire [7:0] B6 = B[79:72];
    wire [7:0] B7 = B[71:64];
    wire [7:0] B8 = B[63:56];
    wire [7:0] B9 = B[55:48];
    wire [7:0] B10 = B[47:40];
    wire [7:0] B11 = B[39:32];
    wire [7:0] B12 = B[31:24];
    wire [7:0] B13 = B[23:16];
    wire [7:0] B14 = B[15:8];
    wire [7:0] B15 = B[7:0];

    // Wires for outputs of each column transformation
    wire [7:0] D0, D1, D2, D3;
    wire [7:0] D4, D5, D6, D7;
    wire [7:0] D8, D9, D10, D11;
    wire [7:0] D12, D13, D14, D15;

    // column-wise Mixcolumns transformation
    MixSinglecolumn msc0 (
        .B0(B0), .B1(B1), .B2(B2), .B3(B3),
        .D0(D0), .D1(D1), .D2(D2), .D3(D3)
    );

    MixSinglecolumn msc1 (
        .B0(B4), .B1(B5), .B2(B6), .B3(B7),
        .D0(D4), .D1(D5), .D2(D6), .D3(D7)
    );

    MixSinglecolumn msc2 (
        .B0(B8), .B1(B9), .B2(B10), .B3(B11),
        .D0(D8), .D1(D9), .D2(D10), .D3(D11)
    );

    MixSinglecolumn msc3 (
        .B0(B12), .B1(B13), .B2(B14), .B3(B15),
        .D0(D12), .D1(D13), .D2(D14), .D3(D15)
    );

    // combine outputs into a 128-bit state
    assign D = {D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15};

endmodule

// Sub-module for processing a single column in Mixcolumns
module MixSinglecolumn (
    input [7:0] B0, B1, B2, B3,     // 4-byte input b
    output [7:0] D0, D1, D2, D3     // 4-byte output D
);

    // Intermediate wires for T, F, G calculations
    wire [7:0] GFM_T0, GFM_T1, GFM_F0, GFM_F1, GFM_G0, GFM_G1;
    wire [7:0] GFM_T0_a, GFM_T0_b, GFM_T1_a, GFM_T1_b;
    wire [7:0] GFM_F0_a, GFM_F0_b, GFM_F1_a, GFM_F1_b;
    wire [7:0] GFM_G0_a, GFM_G0_b, GFM_G1_a, GFM_G1_b;

    // T calculation
    GFM gfm_T0_1 (.a(8'h02), .b(B0 ^ B2), .c(GFM_T0_a));
    GFM gfm_T0_2 (.a(8'h03), .b(B1 ^ B3), .c(GFM_T0_b));

    GFM gfm_T1_1 (.a(8'h01), .b(B0 ^ B2), .c(GFM_T1_a));
    GFM gfm_T1_2 (.a(8'h02), .b(B1 ^ B3), .c(GFM_T1_b));

    // F calculation
    GFM gfm_F0_1 (.a(B0), .b(8'h02 ^ 8'h01), .c(GFM_F0_a));
    GFM gfm_F0_2 (.a(B1), .b(8'h03 ^ 8'h01), .c(GFM_F0_b));

    GFM gfm_F1_1 (.a(B0), .b(8'h03 ^ 8'h01), .c(GFM_F1_a));
    GFM gfm_F1_2 (.a(B1), .b(8'h02 ^ 8'h01), .c(GFM_F1_b));

    // G calculation
    GFM gfm_G0_1 (.a(B2), .b(8'h02 ^ 8'h01), .c(GFM_G0_a));
    GFM gfm_G0_2 (.a(B3), .b(8'h03 ^ 8'h01), .c(GFM_G0_b));

    GFM gfm_G1_1 (.a(B2), .b(8'h03 ^ 8'h01), .c(GFM_G1_a));
    GFM gfm_G1_2 (.a(B3), .b(8'h02 ^ 8'h01), .c(GFM_G1_b));

    assign GFM_T0 = GFM_T0_a ^ GFM_T0_b;
    assign GFM_T1 = GFM_T1_a ^ GFM_T1_b;
    assign GFM_F0 = GFM_F0_a ^ GFM_F0_b;
    assign GFM_F1 = GFM_F1_a ^ GFM_F1_b;
    assign GFM_G0 = GFM_G0_a ^ GFM_G0_b;
    assign GFM_G1 = GFM_G1_a ^ GFM_G1_b;

    // Final output D calculation
    assign D0 = GFM_T0 ^ GFM_G0;
    assign D1 = GFM_T1 ^ GFM_G1;
    assign D2 = GFM_T0 ^ GFM_F0;
    assign D3 = GFM_T1 ^ GFM_F1;

endmodule
