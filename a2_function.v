module a2_function(
    input  [7:0] i,   // 8-bit input
    output [7:0] o    // 8-bit output
);

assign o[7] = ((i >> 7) & 1) ^ ((i >> 6) & 1);
assign o[6] = ((i >> 5) & 1) ^ ((i >> 3) & 1);
assign o[5] = ((i >> 6) & 1) ^ ((i >> 5) & 1);
assign o[4] = ((i >> 2) & 1) ^ ((i >> 4) & 1) ^ ((i >> 7) & 1);
assign o[3] = ((i >> 4) & 1) ^ ((i >> 5) & 1) ^ ((i >> 6) & 1) ^ ((i >> 7) & 1);
assign o[2] = ((i >> 1) & 1) ^ ((i >> 5) & 1);
assign o[1] = ((i >> 4) & 1) ^ ((i >> 6) & 1) ^ ((i >> 7) & 1);
assign o[0] = (i & 1) ^ ((i >> 4) & 1) ^ ((i >> 6) & 1);

endmodule

