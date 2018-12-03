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

import router_pkg::*;

module ut_router ();

localparam NUM_PORTS = 4;

// Signals declarations
clk_rst_if clk_test_if();

axi_st_if router_2_tester[0:NUM_PORTS](clk_test_if.sink);
axi_st_if tester_2_router[0:NUM_PORTS](clk_test_if.sink);
axi_lite_if ni_2_router(clk_test_if.sink);
axi_lite_if router_2_ni(clk_test_if.sink);

// Generate clock
clk_rst_source #(
    .PERIOD(10)
    ) u_clk_rst_source (
    .clk_if     (clk_test_if.source)
    );

// Instantiate Router
router #(
    .NUM_PORTS  (4),
    .PORT_WIDTH (128),
    .FIFO_DEPTH (16),
    .LOCAL_ADR  (0)
    ) u_router (
    .clk_if     (clk_test_if.sink),
    .axi_egress (router_2_tester.master),
    .axi_ingress(tester_2_router.slave),
    .ni_out     (router_2_ni.master),
    .ni_in      (ni_2_router.slave)
    );

router_tester #(
    .NUM_PORTS  (4),
    .PORT_WIDTH (128),
    .FIFO_DEPTH (16),
    .LOCAL_ADR  (0)
    ) u_router_tester (
    .clk_if           (clk_test_if.sink),
    .stimulus         (tester_2_router.master),
    .response         (router_2_tester.slave),
    .ni_master_unconn (ni_2_router.master),
    .ni_slave_unconn  (router_2_ni.slave)
    );

// Instantiate router tester

// Test:
initial
        begin
            $display("Entering test.");
            ut_router.seq_reset(15,45);
            u_router_tester.build_messages(1,1,0);
            #(20)
            fork
                begin
                    u_router_tester.send_data();
                end
                begin
                    u_router_tester.read_data_infinite();
                end
            join
        end

task seq_reset(
    input integer time_delay,
    input integer time_len
    );
    u_router_tester.idle();
    #(time_delay)
        u_clk_rst_source.arst_assert();
    #(time_len)
        u_clk_rst_source.arst_deassert();
endtask

endmodule

