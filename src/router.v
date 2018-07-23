//MIT License
//
//Copyright (c) 2018 Michał Czyż
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//

// Port = ingress+egress bus


module router#(
	//NUM_PORTS = {2, 3, 4}, NI port is always on and not counted here.
	parameter NUM_PORTS=5,
	parameter PORT_WIDTH=128
	)
	(
	input clk,
	input arst,
	input srst,
	// Ingress ports
	input                  ing_val [0:NUM_PORTS-1],
	input [PORT_WIDTH-1:0] ing_dat [0:NUM_PORTS-1],
	output reg             ing_rdy [0:NUM_PORTS-1],
	// Egress ports
	input                  egr_val [0:NUM_PORTS-1],
	input [PORT_WIDTH-1:0] egr_dat [0:NUM_PORTS-1],
	output reg             egr_rdy [0:NUM_PORTS-1]
	);

genvar fifo_index;
for ( fifo_index = 0 ; fifo_index < NUM_INDEX ; fifo_index++ )
begin : gen_input_fifo
	fifo #(
	.DATA_WIDTH(128),
	.DEPTH(8),
	.ALMOST_MTY_TH(1),
	.ALMOST_FULL_TH(1)
	) ufifoinput (
	.clk		(clk),
	.arst		(arst),
	.srst		(srst),
	.wr		(),
	.rd		(),
	.data		(ing_dat[fifo_index]),
	.almost_full	(),
	.full		(),
	.almost_mty	(),
	.mty		(),
	.q		()
	);
end

for ( fifo_index = 0 ; fifo_index < NUM_INDEX ; fifo_index++ )
begin : gen_output_fifo
	fifo #(
	.DATA_WIDTH(128),
	.DEPTH(8),
	.ALMOST_MTY_TH(1),
	.ALMOST_FULL_TH(1)
	) ufifooutput (
	.clk		(clk),
	.arst		(arst),
	.srst		(srst),
	.wr		(),
	.rd		(),
	.data		(egr_dat[fifo_index]),
	.almost_full	(),
	.full		(),
	.almost_mty	(),
	.mty		(),
	.q		()
	);
end

endmodule
