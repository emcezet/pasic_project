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
	//
    input clk,
    input arst,
    input srst,
    //
    input wr,
    input rd,
    input [DATA_WIDTH-1:0] data,
    output reg almost_full,
    output reg full,
    output reg almost_mty,
    output reg mty,
    output reg [DATA_WIDTH-1:0] q
    );

localparam LOG2_DEPTH=$clog2(DEPTH);

reg [LOG2_DEPTH-1:0] pHead;
reg [LOG2_DEPTH-1:0] pTail;
// create memory from registers
reg [DATA_WIDTH-1:0] ff_ram [0:DEPTH-1];

// Signals associated with R:
//  - mty
//  - almost_mty
//  - q

always @ ( posedge clk or posedge arst )
begin
    if ( arst )
	    begin
		    pHead       <= '0;
		    pTail       <= '0;
		    ff_ram      <= {DEPTH{'0}};
            almost_full <= '0;
            full        <= '0;
            almost_mty  <= '0;
            mty         <= '1;
	    end
    else
	    begin
            if ( full ) // Do not accept new writes!
                begin
                    ff_ram[pHead] <= ff_ram[pHead];
                    pHead         <= pHead;
                end
            else
                begin
                    if ( wr )
                        begin
                            ff_ram[pHead] <= data;
                            pHead         <= pHead + 1'b1;
                        end
                    else
                        begin
                            ff_ram[pHead] <= ff_ram[pHead];
                            pHead         <= pHead;
                        end
                end
            if ( mty ) // Do not accept new reads!
                begin
                    ff_ram[pTail]   <= ff_ram[pTail];
                    pTail           <= pTail;
                end
            else
                begin
                    if ( rd )
                        begin
                            q       <= ff_ram[pTail];
                            pTail   <= pTail + 1'b1;
                        end
                    else
                        begin
                            ff_ram[pTail]   <= ff_ram[pTail];
                            pTail           <= pTail;
                        end
                end
            // Generate full, mty, almost_*
            almost_full <= ( pHead - pTail ) == ALMOST_MTY; //parameter cast to int!
            mty <= ( pHead - pTail ) == 1'b1;
            almost_full <=  ( pTail - pHead ) == ALMOST_FULL;
            full <= ( pTail - pHead ) == 1'b1;
		end
end

endmodule
