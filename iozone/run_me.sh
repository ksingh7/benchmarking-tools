#!/bin/bash

for i in 4096 1024 128 4; do
        ./run_test.pl "$i"k_test.csv ;
done
