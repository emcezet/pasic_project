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

module router#(
    //NUM_PORTS = {2, 3, 4}, NI port is always on and not counted here.
    parameter NUM_PORTS=`ROUTER_NUM_PORTS,
    parameter PORT_WIDTH=`ROUTER_BUS_W,
    parameter FIFO_DEPTH=`ROUTER_FIFO_DEPTH
    )
    (
    clk_rst_if.sink clk_if,
    axi_st.master[`ROUTER_NUM_PORTS] axi_egress, 
    axi_st.slave[`ROUTER_NUM_PORTS] axi_ingress, 
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
    .clk_if(clk_if.slave),
    .fifo_in(),
    .fifo_out()
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
    .clk_if(clk_if.slave),
    .fifo_in(),
    .fifo_out()
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

