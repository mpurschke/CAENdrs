#! /bin/sh

# this script sets up the 1741 in "expert" mode.
# see the README.


# we figure out if a server is already running
if ! rcdaq_client daq_status > /dev/null 2>&1 ; then

    echo "No rcdaq_server running, starting... log goes to $HOME/rcdaq.log"
    rcdaq_server > $HOME/rcdaq.log 2>&1 &
    sleep 2

#    ELOG=$(which elog 2>/dev/null)
#    [ -n "$ELOG" ]  && rcdaq_client elog 192.168.60.1 7815 EIC_FNAL

    rcdaq_client daq_webcontrol 8899

fi


rcdaq_client daq_setrunnumberfile $HOME/.rcdaq_runnumber.txt

# we need the $0 as absolute path b/c we pass it on to a "file" device further down
D=`dirname "$0"`
B=`basename "$0"`
MYSELF="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"
HERE=$(dirname "$MYSELF")


rcdaq_client daq_clear_readlist


# and the run types
#rcdaq_client daq_define_runtype beam     $HOME/data/beam/beam-%08d-%04d.evt
#rcdaq_client daq_define_runtype calib    $HOME/data/calibration/calibration-%08d-%04d.evt
#rcdaq_client daq_define_runtype junk     $HOME/data/junk/junk-%08d-%04d.evt

# preset to junk
#rcdaq_client daq_set_runtype junk



# we add this very file to the begin-run event
rcdaq_client create_device device_file 9 900 "$MYSELF"
rcdaq_client create_device device_file 9 901 "$HERE/setup_1741.sh"

# We capture the state of the CAEN 1742 in this file
rcdaq_client create_device device_command 9 0  "caen_client status > /tmp/caen_status.txt"
# and we add the file to the data stream
rcdaq_client create_device device_file 9 922 "/tmp/caen_status.txt"


if ! rcdaq_client  daq_status -ll | grep -q "CAEN DRS Plugin" ; then 
    rcdaq_client load librcdaqplugin_CAENdrs.so
fi

# as seen from the back of the CONET card, the links go 3 2 1 0
# 0 is furthest away from the PC motherboard
LINK=0 

TRIGGER=1  # we make the RCDAQ system trigger

rcdaq_client create_device device_CAENdrs 1 2001 $LINK $TRIGGER

sh $HERE/setup_1741.sh







