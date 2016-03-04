#!/bin/bash

# Author: Karan Singh
# Inspired by Olli Tourunen <Olli.Tourunen@csc.fi>
# Version - 2.0

###########
## Notes ##
###########
# 1. sequential write with large block size first, so  that the test files are fully laid out before other tests

# Mount point where block device is mounted
fio_test_dir=/mnt/bench-disk

# Test size in MB
fio_test_size=10240

# Number of workers
workers=64

# Output directory to store fio results
fio_output_dir=$fio_test_dir/fio_output

# Different block sizes to test with. Example : 8192k 4096k 2048k 1024k 512k 256k 128k 64k 32k 16k 4k 2k 1k
block_size="4k 128k 1024k 4096k"

# The test method that should be used by fio, Example : write read readwrite randread randwrite randrw 
#test_method="write randwrite readwrite read randread"
test_method="write read readwrite randread randwrite randrw"

# Repeat the test for better averaging
repeat=1

# Use buffered IO: direct=0  or non buffered IO: direct=1
direct=1

if [ -d "$fio_output_dir" ]; then
   echo "$fio_output_dir directory already exists, renaming existing directory"
   mv $fio_output_dir ${fio_output_dir}'_'`date +"%d-%m-%Y-%H-%M-%S"`
   echo "Creating new $fio_output_dir directory"
   mkdir $fio_output_dir
else
   echo "Creating new $fio_output_dir directory"
   mkdir $fio_output_dir
fi

echo " ================================================= "
echo "               Starting Benchmarking "
echo " ================================================= "

for fio_test in $test_method ; do

 if [ "$fio_test" == "write" ] || [ "$fio_test" == "randwrite" ]; then
  echo "Hostname Pattern Block_size Threads Bandwidth_KB/s IOPS Latency_mean Total_I/O_KB Rununtime_ms " >> $fio_output_dir/fio_output_`hostname`_"$fio_test".summary;
 fi
 if [ "$fio_test" == "read" ] || [ "$fio_test" == "randread" ]; then
  echo "Hostname Pattern Block_size Threads Bandwidth_KB/s IOPS Latency_mean Total_I/O_KB Rununtime_ms " >> $fio_output_dir/fio_output_`hostname`_"$fio_test".summary;
 fi
 if [ "$fio_test" == "readwrite" ] || [ "$fio_test" == "writeread" ]; then
  echo "Hostname Pattern Block_size Threads Read_Bandwidth_KB/s Read_IOPS Read_latency_mean Read_Total_I/O_KB Read_runtime_ms Write_Bandwidth_KB/s Write_IOPS Write_latency_mean Write_Total_I/O_KB Write_runtime_ms" >> $fio_output_dir/fio_output_`hostname`_"$fio_test".summary;
 fi

  for bs in $block_size ; do
    for ((i=1;i<=$repeat;i+=1)) ; do
      for ((size=$fio_test_size,nw=1;nw<=$workers;nw*=2)); do
        echo "starting test fio_$fio_test-$i-$nw-$bs"
        fio --directory=$fio_test_dir --randrepeat=0 --size=${size}M \
            --direct=$direct --bs=$bs --timeout=60 --numjobs=$nw --rw=$fio_test \
            --group_reporting --eta=never --name=`hostname` --minimal --output=$fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.out;
        echo 3 > /proc/sys/vm/drop_caches
        if [ ! $? -eq 0 ]; then
          echo "error running FIO, exiting"
          exit 1
        fi
        #grep iops $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.out
        sed "s/$/;$nw;$bs;$fio_test/" $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.out > $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.output;
        rm $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.out;

	if [ "$fio_test" == "write" ] || [ "$fio_test" == "randwrite" ]; then
	cat $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.output | awk -F ';' '{print $3,$133,$132,$131,$48,$49,$81,$47,$50}' >> $fio_output_dir/fio_output_`hostname`_"$fio_test".summary;
	fi

	if [ "$fio_test" == "read" ] || [ "$fio_test" == "randread" ]; then
	cat $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.output | awk -F ';' '{print $3,$133,$132,$131,$7,$8,$40,$6,$9}' >> $fio_output_dir/fio_output_`hostname`_"$fio_test".summary;
	fi

	if [ "$fio_test" == "readwrite" ] || [ "$fio_test" == "writeread" ]; then
	cat $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.output | awk -F ';' '{print $3,$133,$132,$131,$7,$8,$40,$6,$9,$48,$49,$81,$47,$50}' >> $fio_output_dir/fio_output_`hostname`_"$fio_test".summary;
	fi
	
      done
    done
  done
done

# Loop to extract result of fio test , creates a file with name results/fio_result_%date
#for fio_test in $test_method ; do
#  for bs in $block_size ; do
#    for ((i=1;i<=$repeat;i+=1)) ; do
#      for ((size=$fio_test_size,nw=1;nw<=$workers;nw*=2,size/=2)); do
#	grep --with-filename iops $fio_output_dir/`hostname`_fio_$fio_test-$i-$nw-$bs.output | sort -t "-" -k 2n | sed -r "s/.*fio_output\///" >> results/fio_result_`hostname`_`date +"%d-%m-%Y-%H-%M-%S"`
#      done
#    done
#  done
#done
echo " =========================================================== "
echo "               Benchmarking Completed "
#echo " Results : results/fio_result_`hostname`_`date +"%d-%m-%Y-%H-%M"`-*"
echo " Results: $fio_output_dir/fio_output_*TestMethod.summary files"
echo " =========================================================== "
