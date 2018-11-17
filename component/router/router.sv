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

module router #(
    //Allowed NUM_PORTS = {2, 3, 4}, NI port is always on and not counted here.
    parameter NUM_PORTS = `ROUTER_NUM_PORTS,
    parameter PORT_WIDTH = `ROUTER_BUS_W,
    parameter FIFO_DEPTH = `ROUTER_FIFO_DEPTH
    )
    (
    clk_rst_if.sink clk_if,
    // To/from other routers
    axi_st.master axi_egress[0:NUM_PORTS],
    axi_st.slave axi_ingress[0:NUM_PORTS],
    // To/from Network Inteface (Processing Element)
    axi_lite.master ni_out,
    axi_lite.slave ni_in
    );

fifo_if fifo_ingress[0:NUM_PORTS](clk_if.slave);
fifo_if fifo_egress[0:NUM_PORTS](clk_if.slave);

genvar port_index;
generate
    for ( port_index = 0 ; port_index < NUM_PORTS ; port_index++ )
    begin
        // AXI ingress -> FIFO input
        always_comb
            begin : proc_glue_input
                fifo_ingress[port_index].data   = axi_ingress[port_index].tdata;
                fifo_ingress[port_index].wr     = axi_ingress[port_index].tvalid & ~fifo_ingress[port_index].full;
                axi_ingress[port_index].tready  = ~fifo_ingress[port_index].full;
            end
        // FIFO output -> AXI egress
        always_comb
            begin : proc_glue_output
                axi_egress[port_index].tdata = fifo_egress[port_index].data;
                axi_egress[port_index].tvalid = fifo_egress[port_index].rd; //Possibly add one cycle coz fifo latency
                fifo_egress[port_index].rd = axi_egress[port_index].tready & ~fifo_egress[port_index].mty;
            end
    end
endgenerate

// Generate input FIFOs
genvar fifo_index;
generate
for ( fifo_index = 0 ; fifo_index < NUM_PORTS ; fifo_index++ )
    begin : gen_input_fifo
        fifo #(
        .DATA_WIDTH     (PORT_WIDTH),
        .DEPTH          (FIFO_DEPTH),
        .ALMOST_MTY_TH  (1),
        .ALMOST_FULL_TH (1)
        ) u_fifo_in (
        .clk_if     (clk_if.slave),
        .fifo_in    (fifo_ingress[port_index].in),
        .fifo_out   (fifo_ingress[port_index].out)
        );
    end

for ( fifo_index = 0 ; fifo_index < NUM_PORTS ; fifo_index++ )
    begin : gen_output_fifo
        fifo #(
        .DATA_WIDTH     (PORT_WIDTH),
        .DEPTH          (FIFO_DEPTH),
        .ALMOST_MTY_TH  (1),
        .ALMOST_FULL_TH (1)
        ) u_fifo_out (
        .clk_if         (clk_if.slave),
        .fifo_in        (fifo_egress[port_index].in),
        .fifo_out       (fifo_egress[port_index].out)
        );
    end
endgenerate

// Router FSM
// Operation:
// 	-> Read messages from input fifo's in a round-robin fashion.
// 	-> If output FIFO is full, lock. Would be better if the message was
// 	returned to the input queue.
// 	-> If input FIFO is empty, skip.
// 	-> OPTIONAL : If corrupted message, drop.
// 	->
// Inputs:
// 	-> mty's and full's
//
rout_msg_t rout_msg_ingress[0:NUM_PORTS];
rout_msg_t rout_msg_egress[0:NUM_PORTS];
logic [LOG2_CEIL_NUM_PORTS] polled_q;
logic 
typedef enum {IDLE, POLL, DECODE, SEND} router_state;
router_state r_state;
genvar port_index;
generate
    for ( port_index = 0 ; port_index < NUM_PORTS ; port_index++ )
    begin
        always_ff @ ( posedge clk_if.clk or posedge clk_if.arst )
            begin : proc_router_fsm
                if ( arst )
                    begin
                        r_state <= IDLE;
                    end
                else
                    begin
                        case ( r_state )
                            IDLE:
                                begin
                                    polled_q <= '0;
                                    rout_msg_ingress[port_index] <= '0;
                                    rout_msg_egress[port_index] <= '0;
                                end
                            POLL:
                                begin
                                    if ( fifo_ingress[port_index].mty )
                                        begin
                                            polled_q <= polled_q + 1'b1;
                                        end
                                    else
                                        begin
                                            polled
                                        end
                                end
                            DECODE:
                                begin
                                    
                                end
                            SEND:
                                begin
                                    
                                end
                            default:
                                begin
                                    
                                end
                        endcase
                    end
            end
    end
endmodule

