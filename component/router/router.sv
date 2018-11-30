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

`define CENTRAL 3'b000
`define NORTH   3'b001
`define SOUTH   3'b010
`define EAST    3'b011
`define WEST    3'b100

module router #(
    //Allowed NUM_PORTS = {2, 3, 4}, NI port is always on and not counted here.
    parameter NUM_PORTS = 4,
    parameter PORT_WIDTH = 128,
    parameter FIFO_DEPTH = 16,
    parameter LOCAL_ADR = 0
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

localparam LOCAL_ADR_X = LOCAL_ADR / SIZE_Y;
localparam LOCAL_ADR_Y = LOCAL_ADR % SIZE_X;

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
rout_msg_t message;
logic [3:0] adr_polled_q;
logic [3:0] adr_out_q;
logic [3:0] adr_local;

typedef enum {IDLE, POLL, DECODE, SEND} router_state;
router_state r_state;

always_ff @ (posedge clk_if.clk or posedge clk_if.arst)
    begin
        if ( arst )
            begin
                adr_local <= '0;
            end
        else
            begin
                adr_local <= LOCAL_ADDRESS;
            end

    end

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
                            // Outputs
                            adr_polled_q <= '0;
                            adr_out_q <= '0;
                            message <= '0;
                            // Next state
                            r_state <= POLL;
                        end
                    POLL:
                        begin
                            // Outputs
                            if ( adr_polled_q == 3'h05 )
                                begin
                                    adr_polled_q <= '0;
                                end
                            else
                                begin
                                    adr_polled_q <= adr_polled_q + 1'b1;
                                end
                            if ( ~fifo_ingress[adr_polled_q].mty )
                                begin
                                    message <= fifo_ingress[adr_polled_q].q;
                                    fifo_ingress[adr_polled_q].rd <= 1'b1;
                                end
                            else
                                begin
                                    message <='0;
                                    fifo_ingress[adr_polled_q].rd <= 1'b0;
                                end
                            // Next state
                            if ( fifo_ingress[adr_polled_q].mty )
                                begin
                                    r_state <= POLL;
                                end
                            else
                                begin
                                    r_state <= DECODE;
                                end
                        end
                    DECODE:
                        begin
                            // Decoding scheme
                            if ( message.dst_y == LOCAL_ADR_Y )
                                begin
                                    if ( message.dst_x == LOCAL_ADR_X )
                                        begin
                                            adr_out_q <= `CENTRAL;
                                        end
                                    else if ( message.dst_x > LOCAL_ADR_X )
                                        begin
                                            adr_out_q <= `EAST;
                                        end
                                    else
                                        begin
                                            adr_out_q <= `WEST;
                                        end
                                end
                            else if ( message.dst_y > local_adr_y )
                                begin
                                    adr_out_q <= `SOUTH;
                                end
                            else
                                begin
                                    adr_out_q <= `NORTH:
                                end
                            // Next state
                            if ( fifo_egress[adr_out_q].full )
                                begin
                                    r_state <= DECODE;
                                end
                            else
                                begin
                                    r_state <= SEND;
                                end
                        end
                    SEND:
                        begin
                            fifo_egress[adr_out_q].wr <= '1;
                            fifo_egress[adr_out_q].data <= message;
                            // Next state
                            r_state <= POLL;
                        end
                    default:
                        begin
                            r_state <= IDLE;
                        end
                endcase

    end

endmodule

