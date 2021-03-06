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

interface axi_st_if #(
    parameter SYMBOL_W      = 8, //`AXI_ST_SYMBOL_W,
    parameter SYMBOL_NUM    = 8, //`AXI_ST_SYMBOL_NUM,
    parameter DATA_W        = 128, //`AXI_ST_DATA_W,
    parameter TID_W         = 8, //`AXI_ST_TID_W, // Recommended max.
    parameter TDEST_W       = 8, //`AXI_ST_TDEST_W, // Recommended max.
    parameter TUSER_W       = 8 //`AXI_ST_TUSER_W // Smaller than recommended.
    )(
    clk_rst_if.sink clk_rst_if
    );
    logic                   tvalid;
    logic                   tready;
    logic [DATA_W-1:0]      tdata;
    logic [SYMBOL_NUM-1:0]  tstrb;
    logic [SYMBOL_NUM-1:0]  tkeep;
    logic                   tlast;
    logic [TID_W-1:0]       tid;
    logic [TDEST_W-1:0]     tdest;
    logic [TUSER_W-1:0]     tuser;

modport master(
    output tvalid,
    input  tready,
    output tdata,
    output tstrb,
    output tkeep,
    output tlast,
    output tid,
    output tdest,
    output tuser
    );

modport slave(
    input  tvalid,
    output tready,
    input  tdata,
    input  tstrb,
    input  tkeep,
    input  tlast,
    input  tid,
    input  tdest,
    input  tuser
    );

endinterface

