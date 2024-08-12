module scfa_demo(A, B, Result);
input [1:0] A, B;
output reg Result;

wire A_is_Max;
assign A_is_Max = &(A & 2'b11);

always @(A or B) begin
  if (A > B) begin
    Result = 1;
  end else begin
    if (A_is_Max) Result = 1;
    else Result = 0;
  end
end
endmodule

module top(top_A, top_B, top_ret);
input [1:0] top_A,top_B;
output [1:0]  top_ret;
wire flag;
wire [1:0] a_inter;
scfa_demo scfa_demo_i(
.A(a_inter),
.B(top_B),
.Result(flag)
);
assign top_ret = flag ? 2'b11:2'b00 ;
assign a_inter=top_A + 2'b01;
endmodule