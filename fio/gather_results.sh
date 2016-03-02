#!/bin/bash

run=run1
test_method="write randwrite readwrite read randread"
block_size="8192k 1024k 128k 4k"
host="bench-node1 bench-node2 bench-node3 bench-node4 bench-node5 bench-node6 bench-node7 bench-node8" 

fio_output_dir=results/"$run"_summary

if [ -d "$fio_output_dir" ]; then
   echo "$fio_output_dir directory already exists, renaming existing directory"
   mv $fio_output_dir ${fio_output_dir}'_'`date +"%d-%m-%Y-%H-%M-%S"`
   echo "Creating new $fio_output_dir directory"
   mkdir $fio_output_dir
else
   echo "Creating new $fio_output_dir directory"
   mkdir $fio_output_dir
fi

for pattern in $test_method ; do
	for hn in $host ; do
	cat results/$run/fio_output_"$hn"_"$pattern".summary >> $fio_output_dir/"$pattern".out
	done
done
