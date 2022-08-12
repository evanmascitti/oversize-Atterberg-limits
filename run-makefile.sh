#!/bin/bash

# set variable
OUTFILE=debugging/make.out

# delete old version of file
rm ${OUTFILE}

# add header to timestamp file
echo -e "Running GNU Make; run time: " $(date) "\n\n" |& tee -a ${OUTFILE}


# run GNU make and print results to stdout and also write to file
make |& tee -a ${OUTFILE}

# see solution at https://stackoverflow.com/questions/692000/how-do-i-write-standard-error-to-a-file-while-using-tee-with-a-pipe

