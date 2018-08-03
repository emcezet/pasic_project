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
// Reset source generator
// Synch only guarantees synch on assertion, not on removal.

module rst_source#(
    parameter ACTIVE_HIGH="YES",
    parameter SYNCH="YES"
    )(
    input clk,
    output reg rst
    );

task assert();
    begin
        rst = ( ACTIVE_HIGH == "YES" ) ? 1'b1 : 1'b0;
    end
endtask

task deassert();
    begin
        rst = ( ACTIVE_HIGH == "YES" ) ? 1'b0 : 1'b1;
    end
endtask

task cycle(
    input integer len
    );
    begin
    if ( SYNCH == "YES" )
        begin
            @( posedge clk )
                assert();
            #( len )
                deassert();
        end
    else
        begin
                assert();
            #( len )
                deassert();
        end
    end
endtask

endmodule
