/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
 * Copyright (C) 2007 Das Labor
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module uart_transceiver(
	input sys_rst,
	input sys_clk,

	input uart_rx,
	output reg uart_tx,

	input [15:0] divisor,

	output reg [7:0] rx_data,
	output reg rx_done,

	input [7:0] tx_data,
	input tx_wr,
	output reg tx_done
);

//-----------------------------------------------------------------
// enable16 generator
//-----------------------------------------------------------------
reg [15:0] enable16_counter;

wire enable16;
assign enable16 = (enable16_counter == 16'd0);

always @(posedge sys_clk) begin
	if(sys_rst)
		enable16_counter <= divisor - 16'b1;
	else begin
		enable16_counter <= enable16_counter - 16'd1;
		if(enable16)
			enable16_counter <= divisor - 16'b1;
	end
end

//-----------------------------------------------------------------
// Synchronize uart_rx
//-----------------------------------------------------------------
reg uart_rx1;
reg uart_rx2;

always @(posedge sys_clk) begin
	uart_rx1 <= uart_rx; // d=0
	uart_rx2 <= uart_rx1; // d=0
end

//-----------------------------------------------------------------
// UART RX Logic
//-----------------------------------------------------------------
reg rx_busy;
reg [3:0] rx_count16;
reg [3:0] rx_bitcount;
reg [7:0] rx_reg;

always @(posedge sys_clk) begin
	if(sys_rst) begin // d=1
		rx_done <= 1'b0;
		rx_busy <= 1'b0;
		rx_count16  <= 4'd0;
		rx_bitcount <= 4'd0;
	end else begin // d=1
		rx_done <= 1'b0;

		if(enable16) begin // d=2
			if(~rx_busy) begin // look for start bit // d=3
				if(~uart_rx2) begin // start bit found // d=4
					rx_busy <= 1'b1; // d=4
					rx_count16 <= 4'd7; // d=4
					rx_bitcount <= 4'd0; // d=4
				end
			end else begin  // d=3
				rx_count16 <= rx_count16 + 4'd1; // d=3

				if(rx_count16 == 4'd0) begin // sample  // d=4
					rx_bitcount <= rx_bitcount + 4'd1; // d=4

					if(rx_bitcount == 4'd0) begin // verify startbit  // d=5
						if(uart_rx2)  // d=6
							rx_busy <= 1'b0;
					end else if(rx_bitcount == 4'd9) begin // d=5
						rx_busy <= 1'b0;
						if(uart_rx2) begin // stop bit ok  // d=6
							rx_data <= rx_reg; // d=6
							rx_done <= 1'b1; // d=6
						end // ignore RX error
					end else // d=5
						rx_reg <= {uart_rx2, rx_reg[7:1]};
				end
			end
		end
	end
end

//-----------------------------------------------------------------
// UART TX Logic
//-----------------------------------------------------------------
reg tx_busy;
reg [3:0] tx_bitcount;
reg [3:0] tx_count16;
reg [7:0] tx_reg;

always @(posedge sys_clk) begin
	if(sys_rst) begin // d=1
		tx_done <= 1'b0;
		tx_busy <= 1'b0;
		uart_tx <= 1'b1;
	end else begin // d=1
		tx_done <= 1'b0;
		if(tx_wr) begin // d=2
			tx_reg <= tx_data;
			tx_bitcount <= 4'd0;
			tx_count16 <= 4'd1;
			tx_busy <= 1'b1;
			uart_tx <= 1'b0;
`ifdef SIMULATION
			$display("UART: %c", tx_data);
`endif
		end else if(enable16 && tx_busy) begin // d=2
			tx_count16  <= tx_count16 + 4'd1;

			if(tx_count16 == 4'd0) begin // d=3
				tx_bitcount <= tx_bitcount + 4'd1;
				
				if(tx_bitcount == 4'd8) begin // d=4
					uart_tx <= 1'b1;
				end else if(tx_bitcount == 4'd9) begin // d=4
					uart_tx <= 1'b1;
					tx_busy <= 1'b0;
					tx_done <= 1'b1;
				end else begin // d=4
					uart_tx <= tx_reg[0];
					tx_reg <= {1'b0, tx_reg[7:1]};
				end
			end
		end
	end
end

endmodule
