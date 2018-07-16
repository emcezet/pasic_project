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
	parameter NUM_PORTS=4,
	parameter PORT_WIDTH=128
	)
	(
	input clk,
	input arst,
	input srst,
	// Ingress ports
	input                  ing_val [0:NUM_PORTS],
	input [PORT_WIDTH-1:0] ing_dat [0:NUM_PORTS],
	output reg             ing_rdy,
	// Egress ports
	input                  egr_val [0:NUM_PORTS],
	input [PORT_WIDTH-1:0] egr_dat [0:NUM_PORTS],
	output reg             egr_rdy
	);


endmodule
