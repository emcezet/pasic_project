VLOG=ncverilog
VLOG_OPTS=+sv -sysv

syntax:
	${VLOG} ${VLOG_OPTS} +compile ${SRC}
clean:
	rm -rf INCA_libs/
	rm -rf ncverilog.history
	rm -rf ncverilog.log

	
