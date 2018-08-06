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


// Unit test for FIFO
import utils_pkg::*;

module ut_fifo();
// FIFO parameters
localparam DATA_W=128;
localparam DEPTH=2**4;
localparam MTY_TH=1;
localparam FULL_TH=1;

// // Signals declarations
wire clk;
wire rst;

// FIFO
reg wr;
reg rd;
reg data;
wire almost_full;
wire full;
wire almost_mty;
wire mty;
wire q;

// // Instances

// Generate clock
clk_source #(
    .PERIOD(10)
    ) uclk (
    .clk(clk)
    );

// Generate reset
rst_source #(
    .ACTIVE_HIGH("YES"),
    .SYNCH("NO")
    ) urst (
    .clk(clk),
    .rst(rst)
    );

// Instantiate FIFO
fifo #(
    .DATA_WIDTH     (DATA_W),
    .DEPTH          (DEPTH),
    .ALMOST_MTY     (MTY_TH),
    .ALMOST_FULL    (FULL_TH)
    ) ufifo
    (
    .clk            (clk),
    .arst           (rst),
    .srst           (/*nc*/),
    .wr             (),
    .rd             (),
    .data           (),
    .almost_full    (),
    .full           (),
    .almost_mty     (),
    .mty            (),
    .q              ()
    );


// Test scheme:
// -> Reset, check for 'x'
// -> Write until full
// -> Attempt overflow write
// -> Reset
// -> Write until full
// -> Read until empty
// -> Reset
// -> Randomized R/W operation

// Test:

initial
        begin
            // Reset
            debug_print("Entering test.");
            urst.rst_deassert();
            debug_print("Reset deaserted");
            $display("[rst=%b]",rst);
            uclk.enable();
            #(50)
            urst.rst_cycle(79);
            debug_print("Reset cycle finished");
            $display("[rst=%b]",rst);
        end

task write(
    input [DATA_W-1:0] data
    );
    begin
        @( posedge clk )
            wr = 1'b1;
        @( posedge clk )
            wr = 1'b0;
    end
endtask

task read(
    output [DATA_W-1:0] data
    );
    begin
        @( posedge clk )
            rd = 1'b1;
        @( posedge clk )
            rd = 1'b0;
    end
endtask

endmodule
