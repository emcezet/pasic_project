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

interface axi_st #(
    parameter SYMBOL_W      = `AXI_ST_SYMBOL_W,
    parameter SYMBOL_NUM    = `AXI_ST_SYMBOL_NUM,
    parameter DATA_W        = `AXI_ST_DATA_W,
    parameter TID_W         = `AXI_ST_TID_W, // Recommended max.
    parameter TDEST_W       = `AXI_ST_TDEST_W, // Recommended max.
    parameter TUSER_W       = `AXI_ST_TUSER_W // Smaller than recommended.
    )();
    logic                   TVALID;
    logic                   TREADY;
    logic [DATA_W-1:0]      TDATA;
    logic [SYMBOL_NUM-1:0]  TSTRB;
    logic [SYMBOL_NUM-1:0]  TKEEP;
    logic                   TLAST;
    logic [TID_W-1:0]       TID;
    logic [TDEST_W-1:0]     TDEST;
    logic [TUSER_W-1:0]     TUSER;

modport master(
    output TVALID;
    input  TREADY;
    output TDATA;
    output TSTRB;
    output TKEEP;
    output TLAST;
    output TID;
    output TDEST;
    output TUSER;
    );

modport slave(
    input  TVALID;
    output TREADY;
    input  TDATA;
    input  TSTRB;
    input  TKEEP;
    input  TLAST;
    input  TID;
    input  TDEST;
    input  TUSER;
    );

endinterface