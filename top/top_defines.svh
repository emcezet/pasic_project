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

// Define TOP-LEVEL parameters.
// All sizes in bits.
// Reset

// NoC
`define TOPOLOGY "MESH"
`define MESH_SIZE_X 4
`define MESH_SIZE_Y 4
// Router
`define ROUTER_ALGORITHM "ALGORITHMIC_SOUTH_EAST"
`define ROUTER_BUS_W 128
`define ROUTER_NUM_PORTS 5
`define ROUTER_FIFO_DEPTH 8
// AXI Stream
`define AXI_ST_SYMBOL_W 8
`define AXI_ST_SYMBOL_NUM 16
`define AXI_ST_DATA_W AXI_ST_SYMBOL_W*AXI_ST_SYMBOL_NUM
`define AXI_ST_TID_W 8
`define AXI_ST_TDEST_W 4
`define AXI_ST_TUSER_W 8

