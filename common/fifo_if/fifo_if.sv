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

interface fifo_if #(
    parameter DATA_WIDTH = 8 //`AXI_ST_DATA_W
    )(
    clk_rst_if.sink clk_rst_if
    );
    logic wr;
    logic rd;
    logic [DATA_WIDTH-1:0] data;
    logic almost_full;
    logic full;
    logic almost_mty;
    logic mty;
    logic [DATA_WIDTH-1:0] q;

modport in(
    input wr,
    input data,
    input rd
    );

modport out(
    output almost_full,
    output full,
    output almost_mty,
    output mty,
    output q
    );

modport driver(
    output wr,
    output data,
    output rd
);

modport reader(
    input almost_full,
    input full,
    input almost_mty,
    input mty,
    input q
);

endinterface

