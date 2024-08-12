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