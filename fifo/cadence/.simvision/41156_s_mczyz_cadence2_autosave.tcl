
# NC-Sim Command File
# TOOL:	ncsim(64)	15.20-s038
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias iprof profile
alias quit exit
stop -create -name Randomize -randomize
database -open -shm -into waves.shm waves -default
probe -create -database waves ut_fifo.ufifo.ff_ram ut_fifo.ufifo.pHead ut_fifo.ufifo.pTail ut_fifo.clk_test_if.sink.arst ut_fifo.clk_test_if.sink.arstn ut_fifo.clk_test_if.sink.clk ut_fifo.clk_test_if.sink.srst ut_fifo.clk_test_if.sink.srstn ut_fifo.fifo_test_if.in.data ut_fifo.fifo_test_if.in.rd ut_fifo.fifo_test_if.in.wr ut_fifo.fifo_test_if.out.almost_full ut_fifo.fifo_test_if.out.almost_mty ut_fifo.fifo_test_if.out.full ut_fifo.fifo_test_if.out.mty ut_fifo.fifo_test_if.out.q

simvision -input /home2/s_mczyz/pasic_project/fifo/cadence/.simvision/41156_s_mczyz_cadence2_autosave.tcl.svcf
