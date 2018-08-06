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
	parameter FIFO_DEPTH=8
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
	.DATA_WIDTH(PORT_WIDTH),
	.DEPTH(FIFO_DEPTH),
	.ALMOST_MTY_TH(1),
	.ALMOST_FULL_TH(1)
	) ufifoinput (
	.clk		(clk),
	.arst		(arst),
	.srst		(srst),
	.wr		(ing_val[fifo_index]),
	.rd		(switch_rd_in[fifo_index]),
	.data		(ing_dat[fifo_index]),
	.almost_full	(),
	.full		(~ing_rdy[fifo_index]),
	.almost_mty	(),
	.mty		(switch_mty_in[fifo_index]),
	.q		(switch_dat_in[fifo_index])
	);
end

for ( fifo_index = 0 ; fifo_index < NUM_INDEX ; fifo_index++ )
begin : gen_output_fifo
	fifo #(
	.DATA_WIDTH(PORT_WIDTH),
	.DEPTH(FIFO_DEPTH),
	.ALMOST_MTY_TH(1),
	.ALMOST_FULL_TH(1)
	) ufifooutput (
	.clk		(clk),
	.arst		(arst),
	.srst		(srst),
	.wr		(switch_wr_out[fifo_index]),
	.rd		(),
	.data		(switch_dat_out[fifo_index]),
	.almost_full	(),
	.full		(switch_full_out[fifo_index]),
	.almost_mty	(),
	.mty		(),
	.q		(egr_dat[fifo_index])
	);
end


// Crossbar switch
reg switch_rd;
reg switch_mty;
reg switch_dat;


reg sel_fifo_in;
reg sel_fifo_out;

`define SEL_N 0
`define SEL_W 1
`define SEL_E 2
`define SEL_S 3

always @ ( * )
begin
	case ( sel_fifo_in ):
		`SEL_N:
			msg = switch_dat[0];
		`SEL_W:
					
end



// FSM
// Operation:
// 	-> Read messages from input fifo's in a round-robin fashion.
// 	-> If output FIFO is full, lock. Would be better if the message was
// 	returned to the input queue.
// 	-> If input FIFO is empty, skip.
// 	-> OPTIONAL : If corrupted message, drop.
// 	->  
// Inputs:
// 	-> mty's and full's
// 

`define S_RESET 0
`define S_RD_MSG 1
`define S_WR_MSG 2
`define 
reg [3:0] router_state;

// Process for next state.
always @ ( posedge clk or posedge arst )
begin
	case (router_state)
		`S_RESET:
			begin
				router_state <= 
			end
		`S_RD_MSG:
			begin
			end
		`S_WR_MSG
			begin
			end
		default:
			begin
			end	
end

endmodule

