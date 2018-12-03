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
    axi_st_if.master axi_egress[0:NUM_PORTS],
    axi_st_if.slave axi_ingress[0:NUM_PORTS],
    // To/from Network Inteface (Processing Element)
    axi_lite_if.master ni_out,
    axi_lite_if.slave ni_in
    );

localparam LOCAL_ADR_X = LOCAL_ADR / 4;
localparam LOCAL_ADR_Y = LOCAL_ADR % 4;

fifo_if fifo_ingress[0:NUM_PORTS](clk_if.sink);
fifo_if fifo_egress[0:NUM_PORTS](clk_if.sink);

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
        .ALMOST_MTY     (1),
        .ALMOST_FULL    (1)
        ) u_fifo_in (
        .clk_if     (clk_if.sink),
        .fifo_in    (fifo_ingress[fifo_index].in),
        .fifo_out   (fifo_ingress[fifo_index].out)
        );
    end

for ( fifo_index = 0 ; fifo_index < NUM_PORTS ; fifo_index++ )
    begin : gen_output_fifo
        fifo #(
        .DATA_WIDTH     (PORT_WIDTH),
        .DEPTH          (FIFO_DEPTH),
        .ALMOST_MTY     (1),
        .ALMOST_FULL    (1)
        ) u_fifo_out (
        .clk_if         (clk_if.sink),
        .fifo_in        (fifo_egress[fifo_index].in),
        .fifo_out       (fifo_egress[fifo_index].out)
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
router_pkg::rout_msg_t message;
logic [2:0] adr_out_q;
logic [2:0] adr_in_q;

typedef enum {IDLE, POLL, POLL_Q, DECODE, DECODE_Q, SEND} router_state;
router_state r_state;

always_ff @ ( posedge clk_if.clk or posedge clk_if.arst )
    begin : proc_router_fsm
        if ( clk_if.arst )
            begin
                r_state <= IDLE;
            end
        else
            begin
                case ( r_state )
                    IDLE:
                        begin
                            // Outputs
                            adr_out_q <= '0;
                            adr_in_q <= '0;
                            message <= '0;
                            // Next state
                            r_state <= POLL;
                        end
                    POLL:
                        begin
                            // Outputs
                            if ( ~fifo_ingress[0].mty )
                                begin
                                    fifo_ingress[0].rd <= 1'b1;
                                    adr_in_q <= 4'h0;
                                    r_state <= POLL_Q;
                                end
                            else if ( ~fifo_ingress[1].mty )
                                    begin
                                    fifo_ingress[1].rd <= 1'b1;
                                    r_state <= POLL_Q;
                                    adr_in_q <= 4'h1;
                                end
                            else if ( ~fifo_ingress[2].mty )
                                    begin
                                    fifo_ingress[2].rd <= 1'b1;
                                    r_state <= POLL_Q;
                                    adr_in_q <= 4'h2;
                                end
                            else if ( ~fifo_ingress[3].mty )
                                    begin
                                    fifo_ingress[3].rd <= 1'b1;
                                    r_state <= POLL_Q;
                                    adr_in_q <= 4'h3;
                                end
                            else if ( ~fifo_ingress[4].mty )
                                    begin
                                    fifo_ingress[4].rd <= 1'b1;
                                    r_state <= POLL_Q;
                                    adr_in_q <= 4'h4;
                                end
                            else
                                begin
                                    message <= message;
                                    fifo_ingress[0].rd <= '0;
                                    fifo_ingress[1].rd <= '0;
                                    fifo_ingress[2].rd <= '0;
                                    fifo_ingress[3].rd <= '0;
                                    fifo_ingress[4].rd <= '0;
                                    r_state <= POLL;
                                end
                        end
                    POLL_Q:
                        begin
                            // Outputs
                            if ( adr_in_q == 4'h0 )
                                begin
                                    message <= fifo_ingress[0].q;
                                end
                            else if ( adr_in_q == 4'h1)
                                    begin
                                    message <= fifo_ingress[1].q;
                                end
                            else if ( adr_in_q == 4'h2)
                                    begin
                                    message <= fifo_ingress[2].q;
                                end
                            else if ( adr_in_q == 4'h3)
                                    begin
                                    message <= fifo_ingress[3].q;
                                end
                            else if ( adr_in_q == 4'h4)
                                    begin
                                    message <= fifo_ingress[4].q;
                                end
                            else
                                begin
                                    message <= message;
                                end
                            r_state <= DECODE;
                            fifo_ingress[0].rd <= '0;
                            fifo_ingress[1].rd <= '0;
                            fifo_ingress[2].rd <= '0;
                            fifo_ingress[3].rd <= '0;
                            fifo_ingress[4].rd <= '0;
                        end

                    DECODE:
                        begin
                             if ( adr_in_q == 4'h0 )
                                begin
                                    message <= fifo_ingress[0].q;
                                end
                            else if ( adr_in_q == 4'h1)
                                    begin
                                    message <= fifo_ingress[1].q;
                                end
                            else if ( adr_in_q == 4'h2)
                                    begin
                                    message <= fifo_ingress[2].q;
                                end
                            else if ( adr_in_q == 4'h3)
                                    begin
                                    message <= fifo_ingress[3].q;
                                end
                            else if ( adr_in_q == 4'h4)
                                    begin
                                    message <= fifo_ingress[4].q;
                                end
                            else
                                begin
                                    message <= message;
                                end
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
                            else if ( message.dst_y > LOCAL_ADR_Y )
                                begin
                                    adr_out_q <= `SOUTH;
                                end
                            else
                                begin
                                    adr_out_q <= `NORTH;
                                end
                            // Next state
                        end
                        DECODE_Q:
                        begin
                            case ( adr_out_q )
                                    `CENTRAL:
                                        begin
                                            if ( fifo_egress[`CENTRAL].full )
                                                begin
                                                    r_state <= DECODE_Q;
                                            end
                                            else
                                                begin
                                                    r_state <= SEND;
                                            end
                                        end
                                    `SOUTH:
                                        begin
                                            if ( fifo_egress[`SOUTH].full )
                                                begin
                                                    r_state <= DECODE_Q;
                                            end
                                            else
                                                begin
                                                    r_state <= SEND;
                                            end
                                        end
                                    `WEST:
                                        begin
                                            if ( fifo_egress[`WEST].full )
                                                begin
                                                    r_state <= DECODE_Q;
                                            end
                                            else
                                                begin
                                                    r_state <= SEND;
                                            end
                                        end
                                    `EAST:
                                        begin
                                            if ( fifo_egress[`EAST].full )
                                                begin
                                                    r_state <= DECODE_Q;
                                            end
                                            else
                                                begin
                                                    r_state <= SEND;
                                            end
                                        end
                                    `NORTH:
                                        begin
                                            if ( fifo_egress[`NORTH].full )
                                                begin
                                                    r_state <= DECODE_Q;
                                            end
                                            else
                                                begin
                                                    r_state <= SEND;
                                            end
                                        end
                                default:
                                    begin
                                        r_state <= IDLE;
                                    end
                            endcase

                        end
                    SEND:
                        begin
                            message <= message;
                            case ( adr_out_q )
                                    `CENTRAL:
                                        begin
                                            fifo_egress[`CENTRAL].wr <= '1;
                                            fifo_egress[`CENTRAL].data <= message;
                                        end
                                    `SOUTH:
                                        begin
                                            fifo_egress[`SOUTH].wr <= '1;
                                            fifo_egress[`SOUTH].data <= message;
                                        end
                                    `WEST:
                                        begin
                                            fifo_egress[`WEST].wr <= '1;
                                            fifo_egress[`WEST].data <= message;
                                        end
                                    `EAST:
                                        begin
                                            fifo_egress[`EAST].wr <= '1;
                                            fifo_egress[`EAST].data <= message;
                                        end
                                    `NORTH:
                                        begin
                                            fifo_egress[`NORTH].wr <= '1;
                                            fifo_egress[`NORTH].data <= message;
                                        end
                                default:
                                    begin
                                        fifo_egress[`CENTRAL].wr <= '0;
                                        fifo_egress[`CENTRAL].data <= '0;
                                        fifo_egress[`SOUTH].wr <= '0;
                                        fifo_egress[`SOUTH].data <= '0;
                                        fifo_egress[`WEST].wr <= '0;
                                        fifo_egress[`WEST].data <= '0;
                                        fifo_egress[`EAST].wr <= '0;
                                        fifo_egress[`EAST].data <= '0;
                                        fifo_egress[`NORTH].wr <= '0;
                                        fifo_egress[`NORTH].data <= '0;
                                    end
                            endcase
                        // Next state
                            r_state <= POLL;
                        end
                    default:
                        begin
                            r_state <= IDLE;
                        end
                endcase
            end
    end

endmodule

