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

// Non-synth module

import router_pkg::*;

module clk_rst_source#(
    parameter PERIOD=10
    )(
    clk_rst.source clk_if
    );

// Generate clock

initial
    begin : init_clk_val
        clk_if.CLK = 1'b0;
    end

always
    begin : clk_gen
        #(PERIOD/2)
            clk_if.CLK = ~clk_if.CLK;
    end

// Reset sequences

initial
    begin : init_rst_val
        clk_if.ARST     = 1'b0;
        clk_if.ARSTn    = 1'b1;
        clk_if.SRST     = 1'b0;
        clk_if.SRSTn    = 1'b1;
    end

task arst_assert();
    clk_if.ARST = 1'b1;
endtask

task arst_deassert();
    clk_if.ARST = 1'b0;
endtask

task arstn_assert();
    clk_if.ARSTn = 1'b0;
endtask

task arstn_deassert();
    clk_if.ARSTn = 1'b1;
endtask

task srst_assert();
    @( posedge clk_if.CLK )
        clk_if.SRST = 1'b1;
endtask

task srst_deassert();
    @( posedge clk_if.CLK )
        clk_if.SRST = 1'b0;
endtask

task srstn_assert();
    @( posedge clk_if.CLK )
        clk_if.SRSTn = 1'b0;
endtask

task srstn_deassert();
    @( posedge clk_if.CLK )
        clk_if.SRSTn = 1'b1;
endtask

endmodule

