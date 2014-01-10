#/bin/bash -f

# This script runs the Smokeview Verification Cases on a 
# Linux machine with a batch queuing system

queue=
size=64
DEBUG=
OPENMP=
FDS_DEBUG=0

function usage {
echo "Run_SMV_Cases.sh [-d -h -o -p -q queue_name -s ]"
echo "Runs Smokeview verification suite"
echo ""
echo "Options"
echo "-d - use debug version of FDS"
echo "-h - display this message"
echo "-o - run OpenMP version of FDS"
echo "-p size - platform size"
echo "     default: 64"
echo "     other options: 32"
echo "-q queue_name - run cases using the queue queue_name"
echo "     default: batch"
echo "     other options: fire60s, fire70s, vis"
echo "-s - stop FDS runs"
exit
}

CURDIR=`pwd`
cd ..
export SVNROOT=`pwd`/..

while getopts 'dhop:q:s' OPTION
do
case $OPTION in
  d)
   DEBUG=_db
   FDS_DEBUG=1
   ;;
  h)
  usage;
  ;;
  o)
  OPENMP=openmp_
  RUN_OPENMP=1
  ;;
  p)
   size="$OPTARG"
   ;;
  q)
   queue="$OPTARG"
   ;;
  s)
   stop_cases=true
   export STOPFDS=1
   ;;
esac
#shift
done
export FDS_DEBUG

if [ "$size" != "32" ]; then
  size=64
fi
size=_$size

OS=`uname`
if [ "$OS" == "Darwin" ]; then
  PLATFORM=osx$size
  PLATFORM2=osx_32
else
  PLATFORM=linux$size
  PLATFORM2=linux_32
fi
IB=
if [ "$FDSNETWORK" == "infiniband" ] ; then
IB=ib
fi

export WIND2FDS=$SVNROOT/Utilities/wind2fds/intel_$PLATFORM/wind2fds_$PLATFORM
export BACKGROUND=$SVNROOT/Utilities/background/intel_$PLATFORM2/background
export FDSEXE=$SVNROOT/FDS_Compilation/${OPENMP}intel_$PLATFORM$DEBUG/fds_${OPENMP}intel_$PLATFORM$DEBUG
export WFDSEXE=~/FIRE-LOCAL/bin/wfds6_9977_intel_linux_64
export FDS=$FDSEXE
export WFDS=$WFDSEXE
export FDSMPI=$SVNROOT/FDS_Compilation/mpi_intel_$PLATFORM$IB$DEBUG/fds_mpi_intel_$PLATFORM$IB$DEBUG
export CFAST=~/cfast/CFAST/intel_$PLATFORM/cfast6_$PLATFORM

SMVUGDIR=$SVNROOT/Manuals/SMV_User_Guide/SCRIPT_FIGURES
SMVVGDIR=$SVNROOT/Manuals/SMV_Verification_Guide/SCRIPT_FIGURES
SMVVSDIR=$SVNROOT/Manuals/Verification_Summary/images

rm -rf $SMVVSDIR/*.png

# Set queue to submit cases to

if [ "$queue" != "" ]; then
   queue="-q $queue"
fi

export BASEDIR=`pwd`

# Remove output files (unless stop option is used)
if [[ ! $stop_cases ]] ; then
  echo "Removing FDS/CFAST output files"
  export RUNCFAST="$SVNROOT/Verification/scripts/Remove_CFAST_Files.sh"
  export RUNFDS="$SVNROOT/Verification/scripts/Remove_FDS_Files.sh"
  scripts/SMV_Cases.sh
  echo "FDS/CFAST output files removed"
fi

# run cases    

export RUNCFAST="$SVNROOT/Utilities/Scripts/runcfast.sh $queue"
export RUNFDS="$SVNROOT/Utilities/Scripts/runfds.sh $queue"
export RUNTFDS="$SVNROOT/Utilities/Scripts/runfds.sh $queue"
export RUNWFDS="$SVNROOT/Utilities/Scripts/runwfds.sh $queue"
export RUNFDSMPI="$SVNROOT/Utilities/Scripts/runfdsmpi.sh $queue"

if [ $RUN_OPENMP ]; then
  export RUNFDS="$SVNROOT/Utilities/Scripts/runfdsopenmp.sh $queue" 
fi

echo "" | $FDSEXE 2> $SVNROOT/Manuals/SMV_User_Guide/SCRIPT_FIGURES/fds.version

if [[ ! $stop_cases ]] ; then
if [ "$FDS_DEBUG" == "0" ] ; then
if [ -e $WIND2FDS ];  then
  cd $SVNROOT/Verification/WUI
  echo Converting wind data
  $WIND2FDS -prefix sd11 -offset " 100.0  100.0 0.0" wind_data1a.csv
else
  echo "The file $WIND2FDS does not exist. Run aborted"
fi
fi
fi
cd $SVNROOT/Verification
scripts/SMV_Cases.sh
scripts/SMV_MPI_Cases.sh

cp $SMVUGDIR/*.png $SMVVSDIR/.
cp $SMVVGDIR/*.png $SMVVSDIR/.


echo FDS cases submitted

