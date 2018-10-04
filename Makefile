# Define general user preferences (e.g. libraries) in a ./configure file
include ./configure

##################################################################################
##             Tools options and command line switches                          ##
##################################################################################

# Incisive top installation directory
CDS_INST_DIR = $(shell ncroot)

# default hdl.var
HDLVAR = $(CDS_INST_DIR)/tools/inca/files/hdl.var

# Compiler executable
CC = ncvlog
#CC = ncvhdl

# Elaborator executable
ELABORATOR = ncelab

# Simulator executable
SIMULATOR = ncsim

# ncls executable 
LS = ncls 

# Remove command
RM = rm -rf

# SimVision options can be passed to ncsim/irun 
# executables with the -simvisargs switch:
# -simvisargs " $(SIMVISARGS)"
# Use simvision -help for more information
SIMVISARGS = -cdslib $(CDSLIB)                    \
             -logfile $(LOGDIR)/simvision.log     \
             -keyfile $(LOGDIR)/simvision.key     \
             -diagfile $(LOGDIR)/simvision.diag   \
             -nosplash                            \
             -waves 

# Note! 
# You must pass SimVision options to ncsim/irun in quotes!
# Furthermore, you must also leave a blank space before the 
# first option (Tcl syntax error otherwise)


# nclaunch options
# Use nclaunch -help for more information
NCLAUNCHOPTS = -work $(WORK)              \
               -cdslib $(CDSLIB)          \
                #-input ./scripts/run.tcl \
               -keyfile $(LOGDIR)/nclaunch.key

# ncvhdl options
# Use ncvhdl -help for more information
NCVHDLOPTS = -work $(WORK)       \
             -cdslib $(CDSLIB)   \
             -hdlvar $(HDLVAR)   \
             -v93                \
             -errormax 15        \
             -update             \
             -linedebug          \
             -status             \
             -smartorder         \
             -logfile $(LOGDIR)/ncvhdl.log

# ncvlog options
# Use ncvlog -help for more information
NCVLOGOPTS = -work $(WORK)       \
             -cdslib $(CDSLIB)   \
             -hdlvar $(HDLVAR)   \
             -errormax 15        \
             -update             \
             -linedebug          \
             -status             \
             -logfile $(LOGDIR)/ncvlog.log 

# ncelab options
# Use ncelab -help for more information
NCELABOPTS = -work $(WORK)           \
             -cdslib $(CDSLIB)       \
             -hdlvar $(HDLVAR)       \
             -snapshot $(SNAPSHOT)   \
             -errormax 15            \
             -update                 \
             -access +rwc            \
             -status                 \
             -logfile $(LOGDIR)/ncelab.log           

# ncsim options
# Use ncsim -help for more information
NCSIMOPTS = -$(RUNMODE)         \
            -cdslib $(CDSLIB)   \
            -hdlvar $(HDLVAR)   \
            -run                \
            -errormax 15        \
            -update             \
            -status             \
            -simvisargs " $(SIMVISARGS)"    \
            -logfile $(LOGDIR)/ncsim.log    \
            -keyfile $(LOGDIR)/ncsim.key    \
            -input ./scripts/shm.tcl        \

# Linting tool options (missing...)
#HALOPTS = 

# irun options (missing...)
# User irun -helpall for more information
IRUNOPTS = -$(RUNMODE)             \
           -v $(CDSLIB)            \
           -l $(LOGDIR)/irun.log   \
           -k $(LOGDIR)/irun.key   \
           -access +rwc            \
           -exit                   \
           -top $(TOP)             \
           -simvisargs " $(SIMVISARGS)"


# Xterm appearance
XTERM_APPEARANCE = -fg black -bg grey


##################################################################################
##                make targets implementation (DO NOT EDIT!)                    ##
##################################################################################

# Target: default
# By default, just call the help target
default: help


# Target: worklib
# Create a new work library $(LIBDIR)/$(WORK) 
worklib: clean_all
	@mkdir $(LIBDIR)/$(WORK)
	@echo "DEFINE $(WORK) $(LIBDIR)/$(WORK)" >> $(CDSLIB)
	@echo "INCLUDE $(CDS_INST_DIR)/tools/inca/files/cds.lib" >> $(CDSLIB)
	@echo "Added $(WORK) and default libraries to $(CDSLIB) file"

# Target: list
# Lists the work library contents
list:
	$(LS) -cdslib $(CDSLIB) -hdlvar $(HDLVAR) -logfile $(LOGDIR)/ncls.log -library $(WORK)



# Target: list_all
# Lists the contents of all libraries defined in the $(CDSLIB) file
list_all:
	$(LS) -cdslib $(CDSLIB) -hdlvar $(HDLVAR) -logfile $(LOGDIR)/ncls.log -all


# Target: nclaunch
# Run NCLaunch with a few additional switches 
nclaunch: clean
	nclaunch $(NCLAUNCHOPTS) &

# Target: prepare
# Compile and elaborate the design without simulating
prepare: clean
	$(CC) $(NCVLOGOPTS) $(SOURCES)
	$(ELABORATOR) $(NCELABOPTS) $(WORK).$(TOP)
	

# Target: sim
# Compile, elaborate and simulate the design
sim: prepare
	xterm $(XTERM_APPEARANCE) -e $(SIMULATOR) $(NCSIMOPTS) $(WORK).$(SNAPSHOT) &


# Target: update
# Compile, elaborate and simulate the design
update: prepare



# Target: results
results: 
        simvision $(SIMVISARGS) $(SNAPSHOT) &



# Target: all
# single-step compilation/elaboration/simulation using irun
#all:
#	irun $(IRUNOPTS) $(SOURCES)



# Target: lint
# call Incisive HDL Analysis and Lint (HAL)
#lint: prepare
#	irun 


# Target: clean
# delete all log and backup files

clean:
	@find ./ -name '*.log*'     -exec $(RM) {} \;
	@find ./ -name '.nclaunch*' -exec $(RM) {} \;
	@find ./ -name '*.key*'     -exec $(RM) {} \;
	@find ./ -name '*~'         -exec $(RM) {} \;
	@find ./ -name '*.diag'     -exec $(RM) {} \;
	@find ./ -name '*.sim'      -exec $(RM) {} \;
	@echo "Deleted all log and backup files."


# Target: clean all
# delete everything (libraries, cds.lib library mapping files,
# hdl.var option files and SHM waveform databases)

clean_all:
	@find ./ -name '*.log*'     -exec $(RM) {} \;
	@find ./ -name '.nclaunch*' -exec $(RM) {} \;
	@find ./ -name '*.key*'     -exec $(RM) {} \;
	@find ./ -name '*~'         -exec $(RM) {} \;
	@find ./ -name '*.lib'      -exec $(RM) {} \;
	@find ./ -name '*.var'      -exec $(RM) {} \;
	@find ./ -name '*.diag'     -exec $(RM) {} \;
	@find ./ -name '*.sim'      -exec $(RM) {} \;
	@$(RM) INCA_libs
	@$(RM) ./lib/*
	@$(RM) ./.simvision
	@$(RM) ~/.simvision
	@$(RM) ./shm/*


# Target: help
# Display information about all available targets
help: 
	@echo "                                                                                "
	@echo "   Usage:                                                                       "
	@echo "                                                                                "
	@echo "      make <target>                                                             "
	@echo "                                                                                "
	@echo "   Available targets are:                                                       "
	@echo "                                                                                "
	@echo "   help        -- Prints this help                                              "
	@echo "   worklib     -- Creates a new work library $(LIBDIR)/$(WORK)                  "
	@echo "   list        -- Display the contents of the $(WORK) library                   " 
	@echo "   list_all    -- Display the contents of all $(CDSLIB) libraries               "
	@echo "   nclaunch    -- Start NCLaunch attached to the current environment setup      "
	@echo "   prepare     -- Compile and elaborate the design without simulating           "
	@echo "   sim         -- Compile, elaborate and simulate the design in $(RUNMODE)-mode "
	@echo "   lint        -- Call Incisive HAL linting tool (not yet implemented)          "    
	@echo "   clean       -- Delete all log files and other temporary files                "
	@echo "   clean_all   -- Delete everything (libraries, waveforms etc.)                 "
	@echo " 
