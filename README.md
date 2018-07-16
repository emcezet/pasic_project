# PASIC Project
Implementation of a digital CMOS NoC-Mesh oriented router.

# Message layer

Message length is at least 64b long and composes of:

	- 4b Source X
	- 4b Source Y
	- 4b Destination X
	- 4b Destination Y
	- 8b Type
	- ( ROUTER_BUS_WIDTH - (4+4) - (4+4) - (8) ) Payload/Data

# Topology

This design was created to implement a regular, mesh network of routers. Thus,
router was tested with 2, 3 and 4 ports active. Ports are called by their geo-
graphical directions: S, N, E, W. Each port consists of an ingress and egress
bus.
Top left router is addressed with {0,0} and then matrix convention applies,
e.g. a router in second row, third column will be addressed with {1,2}, etc.

# Routing pseudo-algorithm

Each router knows its position:
	myPosition{X,Y} := init_values{X,Y};
When message arrives, destination{X,Y} are extracted and output direction port
is calculated.

	if myPosition{X} < destination{X}
		route to S-port
	else if ">"
		route to N-port
	else if "=="
		if myPosition{Y} < destination{Y}
			route to E-port
		else if ">"
			route to W-port
		else if "=="
			echo "This is my final destination!"
			route to NI-port

This algorithm is called "south first, east next"? I don't have the book
with me atm.

# Router operation

Each bus has a FIFO buffer associated with it. All inputs are connected to all
outputs via a crossbar switch. Switch's control signals are calculated with the
routing algorithm. 

# Traffic flow control mechanism

To avoid simple live-locks, dead-locks, but also not achieving highest 
performance possible, a following mechanism was developed:
	- all input FIFOs are served in a round-robin fashion, except for the input
	port which has a message ready for the output port that is almost full.
	- any input FIFO can assert "almost-full", regarded as a port backpressure.
	- rdreq is a confirmation of read operation ("show-ahead fifo") and should
	only be asserted if the output port can accept the message, otherwise the
	round-robin should skip this input port until the output port deasserts
	almost-full signal.

This should solve locks (resource contention rather) inside the router, but not 
the NoC as a whole.
