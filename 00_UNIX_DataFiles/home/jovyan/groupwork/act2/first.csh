#!/bin/tcsh

#
#This is my first cript
#It goes to a directory, prints the location, lists the files present, and counts the number of files.
set directory=~/groupwork
cd $directory
pwd
ls
ls | wc -l
