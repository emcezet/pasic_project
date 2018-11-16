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

module fifo_tester#(
    parameter DATA_WIDTH = 8
    )
    (
    clk_rst_if.sink clk_if,
    fifo_if.driver fifo_driver,
    fifo_if.reader fifo_reader
    );

logic [DATA_WIDTH-1:0] out_q[$];
logic [DATA_WIDTH-1:0] in_q[$];

task idle();
    fifo_driver.wr = '0;
    fifo_driver.data = '0;
    fifo_driver.rd = '0;
endtask

task generate_new_data(
    input integer number
    );
    integer index;
    integer result;
    logic [DATA_WIDTH-1:0] data;
    for ( index = 0 ; index < number ; index++ )
        begin
            result = randomize(data);
            out_q.push_back(data);
        end
endtask

task send_data();
    // Send one data (one write operation)
    // Timeout is set to a huge number by default
    fork : wait_or_timeout
        begin
            #3_000
                $display("Send data timed-out");
                disable wait_or_timeout;
        end
        begin
            wait ( fifo_reader.full == 1'b0 );
            @( posedge clk_if.clk )
                begin

                    fifo_driver.data = out_q.pop_front();
                    fifo_driver.wr = '1;
                end
            @( posedge clk_if.clk )
                begin
                    fifo_driver.wr = '0;
                end
            disable wait_or_timeout;
        end
    join_any
endtask

task read_data();
    // Read one data (one read operation)
    // Timeout is set to a huge number by default
    logic [DATA_WIDTH-1:0] data;
    fork : wait_or_timeout
        begin
            #999_999
                $error("Read data timed-out");
                disable wait_or_timeout;
        end
        begin
            wait ( fifo_reader.mty == 1'b0 );
                @( posedge clk_if.clk )
                    fifo_driver.rd = '1;
/* Written like this gives a race issue!
 * Synchronize read to negedge
            @( posedge clk_if.clk )
                    begin
                        fifo_driver.rd = '0;
                        in_q.push_front(fifo_reader.q);
                    end
*/
                @( posedge clk_if.clk )
                    begin
                        fifo_driver.rd = '0;
                    end
                @( negedge clk_if.clk )
                    begin
                        in_q.push_front(fifo_reader.q);
                    end
            disable wait_or_timeout;
        end
    join_any
endtask

task read_data_infinite();
    // Read data until timeout
    // Timeout is set to a lower number by default
    logic [DATA_WIDTH-1:0] data;
    fork : wait_or_timeout
        begin
            #1_500
                $display("Read data timed-out");
                disable wait_or_timeout;
        end
        begin
            forever
                begin
                    wait ( fifo_reader.mty == 1'b0 );
                        @( posedge clk_if.clk )
                            fifo_driver.rd = '1;
/* Written like this gives a race issue!
 * Synchronize read to negedge
            @( posedge clk_if.clk )
                    begin
                        fifo_driver.rd = '0;
                        in_q.push_front(fifo_reader.q);
                    end
*/
                        @( posedge clk_if.clk )
                            begin
                                fifo_driver.rd = '0;
                            end
                        @( negedge clk_if.clk )
                            begin
                                in_q.push_front(fifo_reader.q);
                            end
                end
        end
    join
endtask

task dump();
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

endmodule

