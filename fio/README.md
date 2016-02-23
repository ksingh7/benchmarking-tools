Prerequisite
----------
- fio package should be installed
- Mount your block device that needs to be tested. Update run_me.sh with its path

How to use
-----------
Before starting the test, verify test case with various tunable parameters defined in ``run_me.sh``
Once you are ready , run the test in either of these two ways ( or your own way )

- Direct run  ``$ sh run_me.sh`` 
- Run in background  ``$ nohup sh run_me.sh &`` 

Sample Output
-------------
```
fio_write-1-1-4096k.out:  write: io=12288KB, bw=42667KB/s, iops=10, runt=   288msec
fio_write-1-2-4096k.out:  write: io=16384KB, bw=79534KB/s, iops=19, runt=   206msec
fio_write-1-16-4096k.out:  write: io=10240MB, bw=405921KB/s, iops=99, runt= 25832msec
fio_write-1-32-4096k.out:  write: io=10240MB, bw=564023KB/s, iops=137, runt= 18591msec
fio_read-1-1-4096k.out:  read : io=12288KB, bw=227556KB/s, iops=55, runt=    54msec
fio_read-1-2-4096k.out:  read : io=16384KB, bw=468114KB/s, iops=114, runt=    35msec
fio_read-1-16-4096k.out:  read : io=10240MB, bw=1449.7MB/s, iops=362, runt=  7064msec
fio_read-1-32-4096k.out:  read : io=10240MB, bw=1447.1MB/s, iops=361, runt=  7072msec
```

Conventions
-----------
The output file will be in the format ``fio_write-1-1-4096k.out`` which expands to

```fio_(Test Method)_(Test Count)_(Number of Workers)_(Block Size)```
