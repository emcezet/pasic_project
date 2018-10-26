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

module router #(
    //Allowed NUM_PORTS = {2, 3, 4}, NI port is always on and not counted here.
    parameter NUM_PORTS = `ROUTER_NUM_PORTS,
    parameter PORT_WIDTH = `ROUTER_BUS_W,
    parameter FIFO_DEPTH = `ROUTER_FIFO_DEPTH
    )
    (
    clk_rst_if.sink clk_if,
    // To/from other routers
    axi_st.master axi_egress[0:NUM_PORTS],
    axi_st.slave axi_ingress[0:NUM_PORTS],
    // To/from Network Inteface (Processing Element)
    axi_lite.master ni_out,
    axi_lite.slave ni_in
    );

// Generate fifos and crossbar switch.

genvar fifo_index;
generate
for ( fifo_index = 0 ; fifo_index < NUM_PORTS ; fifo_index++ )
    begin : gen_input_fifo
        fifo #(
        .DATA_WIDTH     (PORT_WIDTH),
        .DEPTH          (FIFO_DEPTH),
        .ALMOST_MTY_TH  (1),
        .ALMOST_FULL_TH (1)
        ) u_fifo_in (
        .clk_if     (clk_if.slave),
        .fifo_in    (),
        .fifo_out   ()
        );
    end

for ( fifo_index = 0 ; fifo_index < NUM_PORTS ; fifo_index++ )
    begin : gen_output_fifo
        fifo #(
        .DATA_WIDTH     (PORT_WIDTH),
        .DEPTH          (FIFO_DEPTH),
        .ALMOST_MTY_TH  (1),
        .ALMOST_FULL_TH (1)
        ) u_fifo_out (
        .clk_if         (clk_if.slave),
        .fifo_in        (),
        .fifo_out       ()
        );
    end
endgenerate
// Fifo to axi_st conversion is needed.
// Basic scheme:

always_comb
    begin : translate_axi_to_fifo
        if ( fifo_full )
            begin
                axi_ready = 0;
            end
        else
            begin
                axi_ready = 1;
            end
        if ( axi_ready & axi_data_valid )
                write_to_fifo;
    end

always_comb
    begin : translate_fifo_to_axi
        if ( axi_ready & fifo_not_empty )
            begin
                read_from_fifo;
                axi_valid;
            end
        if ( fifo_empty )
            begin
                axi_notvalid
            end
    end

// Router FSM
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

// NI


endmodule

