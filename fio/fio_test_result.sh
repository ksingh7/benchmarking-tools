#!/bin/bash

fio_test_dir=/mnt/ceph-1tb
fio_output_dir=$fio_test_dir/fio_output

# get the iops in generated files with something like:
for fio_test in write read readwrite randwrite randread ; do
 for i in {1..4}; do
  for bs in 4k 128k 1024k; do
   for nw in 1 2 4 8 16 32 64; do
    grep --with-filename iops $fio_output_dir/fio_$fio_test-$i-$nw-$bs.out | sort -t "-" -k 2n | sed -r "s/.*fio_output\///"
   done
  done
 done
done
