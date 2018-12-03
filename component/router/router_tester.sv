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

// Test on one interface only
module router_tester#(
    parameter NUM_PORTS = 4,
    parameter PORT_WIDTH = 128,
    parameter FIFO_DEPTH = 16,
    parameter LOCAL_ADR = 0
    )
    (
    clk_rst_if.sink clk_if,
    axi_st_if.master stimulus[0:NUM_PORTS],
    axi_st_if.slave response[0:NUM_PORTS],
    // To/from Network Inteface (Processing Element)
    axi_lite_if.master ni_master_unconn,
    axi_lite_if.slave ni_slave_unconn
    );

logic [PORT_WIDTH-1:0] stimulus_q[$];
logic [PORT_WIDTH-1:0] response_q[$];

task idle();
    begin
        stimulus[0].tvalid = '0;
        stimulus[0].tdata = '0;
        stimulus[1].tvalid = '0;
        stimulus[1].tdata = '0;
        stimulus[2].tvalid = '0;
        stimulus[2].tdata = '0;
        stimulus[3].tvalid = '0;
        stimulus[3].tdata = '0;
        stimulus[4].tvalid = '0;
        stimulus[4].tdata = '0;
    end
endtask

task build_messages(
    input integer number,
    input logic [3:0] dst_x,
    input logic [3:0] dst_y
    );
    integer index;
    integer result;
    rout_msg_t message;
    for ( index = 0 ; index < number ; index++ )
        begin
            result = randomize(message);
            message.dst_x = dst_x;
            message.dst_y = dst_y;
            stimulus_q.push_back(message);
        end
endtask

task send_data(
    );
    // Send one data (one write operation)
    // Timeout is set to a huge number by default
    fork : wait_or_timeout
        begin
            #3_000
                $display("Send data timed-out");
                disable wait_or_timeout;
        end
        begin
            wait ( stimulus[1].tready== 1'b1 );
            @( posedge clk_if.clk )
                begin
                    stimulus[1].tdata= stimulus_q.pop_front();
                    stimulus[1].tvalid = '1;
                end
            @( posedge clk_if.clk )
                begin
                    stimulus[1].tdata = '0;
                    stimulus[1].tvalid = '0;
                end
            disable wait_or_timeout;
        end
    join_any
endtask

task read_data_infinite(
    );
    // Read data until timeout
    // Timeout is set to a lower number by default
    logic [PORT_WIDTH-1:0] data;
    fork : wait_or_timeout
        begin
            #1_500
                $display("Read data timed-out");
                disable wait_or_timeout;
        end
        begin
            forever
                begin
                    @( posedge clk_if.clk )
                        response[2].tready = '1;
                    wait ( response[2].tvalid == '1);
                    @( posedge clk_if.clk )
                        begin
                            response_q.push_front(response[2].tdata);
                        end
                end
        end
    join
endtask

/*task dump();
    integer index;
    $display("Fifo tester - dump of queue");
    for ( index = 0 ; index < out_q.size() ; index++ )
        begin
            $display("\t out_q[%d] =\t [%h]",index,out_q[index]);
        end
    for ( index = 0 ; index < in_q.size() ; index++ )
        begin
            $display("\t in_q[%d] =\t [%h]",index,in_q[index]);
        end
endtask
*/
endmodule

