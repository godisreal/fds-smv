#!/bin/bash

# This script runs a set of Validation Cases on a Linux machine with a batch queuing system.
# See the file Validation/Common_Run_All.sh for more information.
export SVNROOT=`pwd`/../..
source $SVNROOT/Validation/Common_Run_All.sh

$QFDS $DEBUG -r $QUEUE -d $INDIR jet_csmag_dx10cm.fds
$QFDS $DEBUG -r $QUEUE -d $INDIR jet_dsmag_dx10cm.fds
$QFDS $DEBUG -r $QUEUE -d $INDIR jet_deardorff_dx10cm.fds
$QFDS $DEBUG -r $QUEUE -d $INDIR jet_vreman_dx10cm.fds

$QFDS $DEBUG -p 49 -r $QUEUE -d $INDIR jet_csmag_dx5cm.fds
$QFDS $DEBUG -p 49 -r $QUEUE -d $INDIR jet_dsmag_dx5cm.fds
$QFDS $DEBUG -p 49 -r $QUEUE -d $INDIR jet_deardorff_dx5cm.fds
$QFDS $DEBUG -p 49 -r $QUEUE -d $INDIR jet_vreman_dx5cm.fds

echo FDS cases submitted
