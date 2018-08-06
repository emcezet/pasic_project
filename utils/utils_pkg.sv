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

`define V_DEBUG
`define V_INFO
`define V_WARN
package utils_pkg;

function debug_print(
    input string msg
    );
    `ifdef V_DEBUG
        $display("[%t] [DEBUG:%m] %s",$time,msg);
    `endif
endfunction

function info_print(
    input string msg
    );
    `ifdef V_INFO
        $display("[%t] [INFO :%m] %s",$time,msg);
    `endif
endfunction

function warn_print(
    input string msg
    );
    `ifdef V_WARN
        $display("[%t] [WARN :%m] %s",$time,msg);
    `endif
endfunction

endpackage

