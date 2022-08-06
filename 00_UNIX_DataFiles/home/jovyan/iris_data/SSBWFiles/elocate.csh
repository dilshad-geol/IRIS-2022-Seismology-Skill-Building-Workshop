#!/bin/csh
#
# Simple script to run elocate on picks from SAC files
#   SAC filenames with picks should be listed on the command line
#   P and S wave arrivals should be stored in "A" and "T0" header variables
#
# Script provided by Mike Brudzinski - brudzimr@muohio.edu
# sac2eloc and elocate are from Computer Programs in Seismology written by Robert Herrmann - http://www.eas.slu.edu/People/RBHerrmann/CPS/CPS33.html
#

# Download Model File
if (! -e VEL.MOD) then
  echo "Retrieving velocity model VEL.MOD from a webpage..."
  wget "https://moodle.glg.miamioh.edu/mikeb/code/VEL.MOD"
#  echo ' O0- Oregon model\n6 2\nP S\n0.0 2.9 1.6763\n1.3 4.7 2.71676\n3.4 6.0 3.46821\n8.0 6.4 3.69942\n30. 6.8 3.93064\n42. 7.7 4.30168' >! VEL.MOD
endif
set model=7

if (${#argv} < 1) then
  echo "usage: elocate.csh [SAC file names]"
  echo "  example: elocate.csh `\ls *.BHZ`"
  exit
endif
echo -n "Writing SAC file arrival time picks to elocate.dat file... "

if (! -e sac2eloc) then
  cp /home/jovyan/iris_data/SSBWFiles/sac2eloc .
  chmod +x sac2eloc
endif

# Run sac2eloc
echo "\n Running sac2eloc"
./sac2eloc $*
echo "\n done"

set lat=`awk '{sum+=$c;n++}END{print sum/n}' c=15 elocate.dat`
set lon=`awk '{sum+=$c;n++}END{print sum/n}' c=16 elocate.dat`
set dep=10
echo "Starting location (lon, lat, dep): $lon $lat $dep"

if (! -e elocate) then
  cp /home/jovyan/iris_data/SSBWFiles/elocate .
  chmod +x elocate
endif


echo "\n Running elocate..."
./elocate -LAT $lat -LON $lon -DEP $dep -BATCH -M $model
echo "\n done"

