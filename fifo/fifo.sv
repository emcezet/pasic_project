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

module fifo#(
    parameter DATA_WIDTH=128,
    parameter DEPTH=8,
    parameter ALMOST_MTY=1,
    parameter ALMOST_FULL=1
    )
    (
    clk_rst_if.sink clk_if,
    fifo_if.in fifo_in,
    fifo_if.out fifo_out
    );

localparam LOG2_DEPTH=$clog2(DEPTH);

logic [LOG2_DEPTH-1:0] pHead;
logic [LOG2_DEPTH-1:0] pTail;
logic [DATA_WIDTH-1:0] ff_ram [0:DEPTH-1];

always @ ( posedge clk_if.clk or posedge clk_if.arst )
begin
    if ( clk_if.arst )
        begin
            pHead                <= '0;
            pTail                <= '0;
            ff_ram               <= {DEPTH{'0}};
            fifo_out.almost_full <= '0;
            fifo_out.full        <= '0;
            fifo_out.almost_mty  <= '1;
            fifo_out.mty         <= '1;
            fifo_out.q           <= '1;
        end
    else
        begin
            if ( fifo_out.full ) // Do not accept new writes!
                begin
                    ff_ram[pHead] <= ff_ram[pHead];
                    pHead         <= pHead;
                end
            else
                begin
                    if ( fifo_in.wr )
                        begin
                            ff_ram[pHead] <= fifo_in.data;
                            pHead         <= pHead + 1'b1;
                        end
                    else
                        begin
                            ff_ram[pHead] <= ff_ram[pHead];
                            pHead         <= pHead;
                        end
                end
            if ( fifo_out.mty ) // Do not accept new reads!
                begin
                    ff_ram[pTail]   <= ff_ram[pTail];
                    pTail           <= pTail;
                end
            else
                begin
                    if ( fifo_in.rd )
                        begin
                            fifo_out.q  <= ff_ram[pTail];
                            pTail       <= pTail + 1'b1;
                        end
                    else
                        begin
                            ff_ram[pTail]   <= ff_ram[pTail];
                            pTail           <= pTail;
                        end
                end
            // Generate mty, almost_mty
            fifo_out.almost_mty <= ( pHead - pTail ) == ALMOST_MTY; //parameter cast to int!
            fifo_out.mty        <= ( pHead - pTail ) == 1'b1;
            // Generate full, almost_full
            fifo_out.almost_full <= ( pTail - pHead ) == ALMOST_FULL;
            fifo_out.full        <= ( pTail - pHead ) == 1'b1;
        end
end

endmodule

