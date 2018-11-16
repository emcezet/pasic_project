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
module ut_fifo#()(
    );

//timeunit 1ns;
//timeprecision 10ps;

// FIFO parameters
localparam DATA_W=128;
localparam DEPTH=2**4;
localparam MTY_TH=3;
localparam FULL_TH=3;

// Signals declarations
clk_rst_if clk_test_if();
fifo_if #(.DATA_WIDTH (DATA_W)
    ) fifo_test_if (clk_test_if.sink);

// Generate clock
clk_rst_source #(
    .PERIOD(10)
    ) u_clk_rst_source (
    .clk_if     (clk_test_if.source)
    );

// Instantiate FIFO
fifo #(
    .DATA_WIDTH     (DATA_W),
    .DEPTH          (DEPTH),
    .ALMOST_MTY     (MTY_TH),
    .ALMOST_FULL    (FULL_TH)
    ) ufifo
    (
    .clk_if     (clk_test_if.sink),
    .fifo_in    (fifo_test_if.in),
    .fifo_out   (fifo_test_if.out)
    );

fifo_tester #(
    .DATA_WIDTH     (DATA_W)
    ) u_fifo_tester
    (
    .clk_if         (clk_test_if.sink),
    .fifo_driver    (fifo_test_if.driver),
    .fifo_reader    (fifo_test_if.reader)
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
            $display("Entering test.");
            ut_fifo.seq_reset(15,45);
            #(20)
            ut_fifo.seq_single_data_io();
            $display("Finished single test.");
            $display("*********************");
            $display("Resetting again");
            ut_fifo.seq_reset(15,45);
            #(20)
            fork
                begin
                    ut_fifo.seq_multiple_write(20);
                end
                begin
                    u_fifo_tester.read_data_infinite();
                end
            join
        u_fifo_tester.dump();
            $display("*********************");
            $display("Resetting again");
            ut_fifo.seq_reset(15,45);
            #(20)
            ut_fifo.seq_multiple_write(8);
            #(20)
            fork
                begin
                    ut_fifo.seq_multiple_write(20);
                end
                begin
                    u_fifo_tester.read_data_infinite();
                end
            join
        u_fifo_tester.dump();
            $display("*********************");
            $display("Resetting again");
            ut_fifo.seq_reset(15,45);
            #(20)
            ut_fifo.seq_multiple_write(20);
        u_fifo_tester.dump();
        end

task seq_reset(
    input integer time_delay,
    input integer time_len
    );
    u_fifo_tester.idle();
    #(time_delay)
        u_clk_rst_source.arst_assert();
    #(time_len)
        u_clk_rst_source.arst_deassert();
endtask

task seq_setup(
    input integer number_data
    );
    u_fifo_tester.generate_new_data(number_data);
endtask

task seq_single_data_io();
   ut_fifo.seq_setup(1);
   fork
       begin
            u_fifo_tester.send_data();
       end
       begin
            u_fifo_tester.read_data();
       end
   join
   u_fifo_tester.dump();
endtask

task seq_multiple_write(
    input integer num_writes
    );
    integer i = 0;
    integer rnd_delay = 10;
    ut_fifo.seq_setup(num_writes);
    for ( i=0 ; i < num_writes; i++ )
        begin
            rnd_delay = $urandom_range(100, 10);
            #(rnd_delay)
                u_fifo_tester.send_data();
        end
endtask

endmodule

