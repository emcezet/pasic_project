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

// Please note this is incredibly simplified implementation of AXI Stream
// interface. Use with extra caution. No guarantee is provided.

// Signal names as in spec docs/AXI.
// Note that clock and reset signals should be provided with clk_rst interface.

interface axi_lite_if #(
    parameter SYMBOL_W      = 8, //`AXI_ST_SYMBOL_W,
    parameter SYMBOL_NUM    = 8, //`AXI_ST_SYMBOL_NUM,
    parameter DATA_W        = 8, //`AXI_ST_DATA_W,
    parameter TID_W         = 8, //`AXI_ST_TID_W, // Recommended max.
    parameter TDEST_W       = 8, //`AXI_ST_TDEST_W, // Recommended max.
    parameter TUSER_W       = 8 //`AXI_ST_TUSER_W // Smaller than recommended.
    )(
    clk_rst_if.sink clk_rst_if
    );
    logic                   awvalid;
    logic                   awready;
    logic                   awaddr;
    logic                   awprot;

    logic                   wvalid;
    logic                   wready;
    logic                   wdata;
    logic                   wstrb;

    logic                   bvalid;
    logic                   bready;
    logic                   bresp;

    logic                   arvalid;
    logic                   arready;
    logic                   araddr;
    logic                   arprot;

    logic                   rvalid;
    logic                   rready;
    logic                   rdata;
    logic                   rresp;

modport master(
    logic awvalid;
    logic awready;
    logic awaddr;
    logic awprot;
    logic wvalid;
    logic wready;
    logic wdata;
    logic wstrb;
    logic bvalid;
    logic bready;
    logic bresp;
    logic arvalid;
    logic arready;
    logic araddr;
    logic arprot;
    logic rvalid;
    logic rready;
    logic rdata;
    logic rresp;

    );

modport slave(
    logic awvalid;
    logic awready;
    logic awaddr;
    logic awprot;
    logic wvalid;
    logic wready;
    logic wdata;
    logic wstrb;
    logic bvalid;
    logic bready;
    logic bresp;
    logic arvalid;
    logic arready;
    logic araddr;
    logic arprot;
    logic rvalid;
    logic rready;
    logic rdata;
    logic rresp;

    );

endinterface

