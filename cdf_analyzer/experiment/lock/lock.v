module lock(
  input wire reset_n,
  input wire clk,
  input wire [7:0] code,
  output reg [1:0] state,
  output wire [1:0]unlocked
);

assign unlocked[0] = state == 2'b11 ? 1'b1 : 1'b0;

always @(posedge clk) begin
  if (~reset_n) begin
    state <= 2'b00;
  end
  else begin
    case(state)
      2'b00   : state <= code == 8'haa ? 2'b01 : 2'b00;
      2'b01   : state <= code == 8'hbb ? 2'b10 : 2'b01;
      2'b10   : state <= code == 8'hcc ? 2'b11 : 2'b10;
      default : state <= state;
    endcase
  end
end

endmodule
