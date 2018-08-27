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


`include "defines.svh"

package router_pkg;

typedef struct packed{
    logic [4-1:0] src_x,
    logic [4-1:0] src_y,
    logic [4-1:0] dst_x,
    logic [4-1:0] dst_y,
    logic [8-1:0] mtype,
    logic [(`ROUTER_BUS_W-24-1):0] data
} rout_msg_t;

typedef struct packed{
    logic                   TVALID;
    logic                   TREADY;
    logic [DATA_W-1:0]      TDATA;
    logic [SYMBOL_NUM-1:0]  TSTRB;
    logic [SYMBOL_NUM-1:0]  TKEEP;
    logic                   TLAST;
    logic [TID_W-1:0]       TID;
    logic [TDEST_W-1:0]     TDEST;
    logic [TUSER_W-1:0]     TUSER;
} axi_st;

// Parameters may lead to errors, should be rewritten.
typedef struct packed{
    logic                   TVALID;
    logic                   TREADY;
    rout_msg_t              TDATA;
    logic [SYMBOL_NUM-1:0]  TSTRB;
    logic [SYMBOL_NUM-1:0]  TKEEP;
    logic                   TLAST;
    logic [TID_W-1:0]       TID;
    logic [TDEST_W-1:0]     TDEST;
    logic [TUSER_W-1:0]     TUSER;
} rout_axi_st;

endpackage

