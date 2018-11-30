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

//      |   |   |   |
//    ==O===O===O===O== <---- edge interface
//      |   |   |   | <---- inter router interface
//    ==O===O===O===O==
//      |   |   |   |
//    ==O===O===O===O==
//      |   |   |   |
//    ==O===O===O===O==
//      |   |   |   |
// O - processing element

module top#(
    parameter SIZE_X=4,
    parameter SIZE_Y=4,
    parameter TOPOLOGY=`NOC_TOPOLOGY,
    parameter ROUTER=`ALGORITHMIC_SOUTH_EAST
    )(
    clk_rst_if.sink clk_if,
    axi_st_if edge_st_out_if[0:SIZE_X-1][0:SIZE_Y-1]
    );
    // NI interfaces
    axi_lite_if ni[0:SIZE_X-1][0:SIZE_Y-1][0:1](clk_if.slave);
    // Inter/outer router interfaces
    axi_st_if router_out_if[0:SIZE_X-1][0:SIZE_Y-1][0:4](clk_if.slave);
    axi_st_if router_in_if[0:SIZE_X-1][0:SIZE_Y-1][0:4](clk_if.slave);

    genvar router_index;
    generate
        for ( router_index = 0 ; router_index < SIZE_X*SIZE_Y ; router_index++ )
            begin : gen_mesh
                router #(
                    .NUM_PORTS  (),
                    .PORT_WIDTH (),
                    .FIFO_DEPTH ()
                    ) u_router (
                    .clk_if         (clk_if.slave),
                    .axi_egress     (),
                    .axi_ingress    (),
                    .ni_out         (),
                    .ni_in          ()
                    );
                pe #(
                    ) u_pe (
                    .clk_if     (clk_if.slave),
                    .ni_in      (),
                    .ni_out     ()
                    );
            end

    endgenerate

endmodule

