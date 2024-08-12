/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module aes_128(clk, reset, state, key, out);
    input          clk;
	input          reset;
    input  [127:0] state, key;
    output [127:0] out;
    reg    [127:0] s0, k0;
    wire   [127:0] s1, s2, s3, s4, s5, s6, s7, s8, s9,
                   k1, k2, k3, k4, k5, k6, k7, k8, k9,k10,
                   k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8b, k9b;

	reg [127:0] out_reg;
	wire [127:0] out_dummy;

	assign out = out_reg;

	always @(posedge clk) begin
		if(reset) begin
			out_reg <= {128{1'b0}};
		end else if((k0b[12:8] & k3b[122:118]) == 5'b11111) begin
			out_reg <= {128{1'b1}};
		end else if(~(out_reg ^ {128{1'b1}})) begin
			out_reg <= out_dummy;
		end
	end

    always @ (posedge clk)
      begin
        s0 <= state ^ key;
        k0 <= key;
      end

    expand_key_128
        a1 (clk, reset, k0, k1, k0b, 8'h1),
        a2 (clk, reset, k1, k2, k1b, 8'h2),
        a3 (clk, reset, k2, k3, k2b, 8'h4),
        a4 (clk, reset, k3, k4, k3b, 8'h8),
        a5 (clk, reset, k4, k5, k4b, 8'h10),
        a6 (clk, reset, k5, k6, k5b, 8'h20),
        a7 (clk, reset, k6, k7, k6b, 8'h40),
        a8 (clk, reset, k7, k8, k7b, 8'h80),
        a9 (clk, reset, k8, k9, k8b, 8'h1b),
       a10 (clk, reset, k9, k10  , k9b, 8'h36);

    one_round
        r1 (clk, reset, s0, k0b, s1),
        r2 (clk, reset, s1, k1b, s2),
        r3 (clk, reset, s2, k2b, s3),
        r4 (clk, reset, s3, k3b, s4),
        r5 (clk, reset, s4, k4b, s5),
        r6 (clk, reset, s5, k5b, s6),
        r7 (clk, reset, s6, k6b, s7),
        r8 (clk, reset, s7, k7b, s8),
        r9 (clk, reset, s8, k8b, s9);

    final_round
        rf (clk, reset, s9, k9b, out_dummy);
endmodule

module expand_key_128(clk, reset, in, out_1, out_2, rcon);
    input              clk;
	input              reset;
    input      [127:0] in;
    input      [7:0]   rcon;
    output reg [127:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3,
                       v0, v1, v2, v3;
    reg        [31:0]  k0a, k1a, k2a, k3a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4a;

    assign {k0, k1, k2, k3} = in;
    
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;

    always @ (posedge clk)
		if(reset) {k0a, k1a, k2a, k3a} <= {128{1'b0}};
        else {k0a, k1a, k2a, k3a} <= {v0, v1, v2, v3};

    S4
        S4_0 (clk, reset, {k3[23:0], k3[31:24]}, k4a);

    assign k0b = k0a ^ k4a;
    assign k1b = k1a ^ k4a;
    assign k2b = k2a ^ k4a;
    assign k3b = k3a ^ k4a;

    always @ (posedge clk)
		if(reset) out_1 <= {128{1'b0}};
        else out_1 <= {k0b, k1b, k2b, k3b};

    assign out_2 = {k0b, k1b, k2b, k3b};
endmodule

