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


package router_pkg;
    parameter SYMBOL_W= 8;
    parameter SYMBOL_NUM= 8;
    parameter DATA_W= 8;
    parameter TID_W= 8;
    parameter TDEST_W= 8;
    parameter TUSER_W= 8;
    parameter NUM_PORTS= 4;
    parameter PORT_WIDTH= 128;
    parameter FIFO_DEPTH =16;
    parameter LOCAL_ADR= 0;

typedef struct packed{
    logic [4-1:0] src_x;
    logic [4-1:0] src_y;
    logic [4-1:0] dst_x;
    logic [4-1:0] dst_y;
    logic [8-1:0] mtype;
    logic [(PORT_WIDTH-24-1):0] data;
} rout_msg_t;

typedef struct packed{
    logic                   tvalid;
    logic                   tready;
    logic [DATA_W-1:0]      tdata;
    logic [SYMBOL_NUM-1:0]  tstrb;
    logic [SYMBOL_NUM-1:0]  tkeep;
    logic                   tlast;
    logic [TID_W-1:0]       tid;
    logic [TDEST_W-1:0]     tdest;
    logic [TUSER_W-1:0]     tuser;
} axi_st;

// Parameters may lead to errors, should be rewritten.
typedef struct packed{
    logic                   tvalid;
    logic                   tready;
    rout_msg_t              tdata;
    logic [SYMBOL_NUM-1:0]  tstrb;
    logic [SYMBOL_NUM-1:0]  tkeep;
    logic                   tlast;
    logic [TID_W-1:0]       tid;
    logic [TDEST_W-1:0]     tdest;
    logic [TUSER_W-1:0]     tuser;
} rout_axi_st;

endpackage

