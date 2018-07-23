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

`define ROUTER_BUS_WIDTH 148
`define NIBBLE reg[3:0]

typedef struct packed{
	`NIBBLE src_x,
	`NIBBLE src_y,
	`NIBBLE dst_x,
	`NIBBLE dst_y,
	reg [7:0] type,
	reg [(`ROUTER_BUS_WIDTH - 4*4 - 8 )-1:0] payload
} message_t;

module top#(
	parameter SIZE_X=4,
	parameter SIZE_Y=4,
	parameter TOPOLOGY="MESH",
	parameter ROUTER="ALGORITHMIC_SOUTH_EAST"
	)(
	input clk,
	input arst,
	input srst,
	//I/O
	
	);

endmodule

