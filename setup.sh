###############################################################################
## Setup and preferences                           
###############################################################################

# Edit the following statements to fit your requirements

# Top-level design unit (e.g. testbench file)
TOP = test

# Configure source files
SRCDIR = ./src
TBDIR  = ./testbench
#SOURCES = $(SRCDIR)/*.v $(TBDIR)/$(TOP).v
#SOURCES = $(SRCDIR)/*.vhd $(TBDIR)/$(TOP).vhd
SOURCES = $(TBDIR)/$(TOP).v

# Library setup
# LIBDIR = ./INCA_libs
LIBDIR = ./lib
CDSLIB = cds.lib
WORK = myLib

# Note! 
# Your cds.lib library mapping file must contain a DEFINE statement
# 
# DEFINE <work library name> ./lib/<physical directory>
#
# Type 
# 
# linux% make worklib 
#
# to mkdir a new work library ./lib/$(WORK) according to the WORK value
# specified in this Makefile


# Log directory (.log and .key files)
# usage: -logfile $(LOGDIR)/filename.log
LOGDIR = ./log

# Standard Delay Format (SDF) annotation directory
#SDFDIR = ./sdf

# Simulation results directory. By default, a waves.shm Cadence Signal History Manager
# (SHM) waveform database will be crearted under the ./shm directory, but feel free to
# use a VCD dump file
WAVEDIR = ./shm
#WAVEDIR = ./vcd

# change default snapshot name
# usage: -snapshot $(SNAPSHOT)
SNAPSHOT = simexe

# ncsim run mode (GUI, interactive or batch)
#RUNMODE = gui
RUNMODE = tcl
#RUNMODE = batch

