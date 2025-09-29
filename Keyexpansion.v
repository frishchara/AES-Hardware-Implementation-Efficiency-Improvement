module Keyexpansion (rd,CLK, sel, rk);
	 input rd;
    input sel;
    input CLK;
    output reg [127:0] rk;
	
    reg [31:0] Rcon [0:9];
    reg [3:0] i; 

    initial begin
        Rcon[0] = 32'h01000000;
        Rcon[1] = 32'h02000000;
        Rcon[2] = 32'h04000000;
        Rcon[3] = 32'h08000000;
        Rcon[4] = 32'h10000000;
        Rcon[5] = 32'h20000000;
        Rcon[6] = 32'h40000000;
        Rcon[7] = 32'h80000000;
        Rcon[8] = 32'h1b000000;
        Rcon[9] = 32'h36000000;
    end
	 reg [31:0] sbox_in;
	 wire [31:0] sbox_out;
	 SBox Sbox3 (.B(sbox_in[31:24]),.D(sbox_out[7:0]));
	 SBox Sbox2 (.B(sbox_in[23:16]),.D(sbox_out[31:24]));
	 SBox Sbox1 (.B(sbox_in[15:8]),.D(sbox_out[23:16]));
	 SBox Sbox0 (.B(sbox_in[7:0]),.D(sbox_out[15:8]));
	 
    always @(posedge CLK) begin
        if (sel) begin
            rk = 128'h2b7e151628aed2a6abf7158809cf4f3c;
            i = 0;
				sbox_in=rk[31:0];
        end else begin
            if (i < 10 && rd) begin
                rk[127:96] = rk[127:96] ^ (sbox_out ^ Rcon[i]);
                rk[95:64] = rk[95:64] ^ rk[127:96];
                rk[63:32] = rk[63:32] ^ rk[95:64];
                rk[31:0] = rk[31:0] ^ rk[63:32];
					 sbox_in=rk[31:0];
                i = i + 1;
            end
        end
    end
endmodule
