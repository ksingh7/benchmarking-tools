#!/bin/bash
echo 3 > /proc/sys/vm/drop_caches

fio_test_dir=/mnt/ceph-1tb
fio_test_size=10

fio_output_dir=$fio_test_dir/fio_output
mkdir $fio_output_dir

# test order: sequential write with large block size first, so
# that the test files are fully laid out before other tests

for fio_test in write read readwrite randwrite randread ; do
  for bs in 1024k 128k 4k; do
    for i in {1..4}; do
      for ((size=$fio_test_size,nw=1;nw<=64;nw*=2,size/=2)); do
#        d=$(date)
#        echo "$d starting test fio_$fio_test-$i-$nw-$bs"
        fio --directory=$fio_test_dir --randrepeat=0 --size=${size}M --runtime=300 \
            --direct=1 --bs=$bs --timeout=60 --numjobs=$nw --name=fio-nw$nw --rw=$fio_test \
            --group_reporting --eta=never --output=$fio_output_dir/fio_$fio_test-$i-$nw-$bs.out;

        if [ ! $? -eq 0 ]; then
          echo "error"
          exit 1
        fi

        grep iops $fio_output_dir/fio_$fio_test-$i-$nw-$bs.out

        sleep 1

      done
    done
  done
done

