#!/usr/bin/perl

use strict;
use warnings;

open(F,"test_def.csv") or
        die "Unable to open test_def.csv";

open(T,">results.csv") or
        die "Unable to open results.csv";

open(RL,">read_latencies.csv") or
        die "Unable to open read_latencies.csv";

open(WL,">write_latencies.csv") or
        die "Unable to open write_latencies.csv";

print T "test_name;write_speed_mb;read_speed_mb;write_speed_ops;read_speed_ops;threads;record_size_kb;file_size;is_sync;start_time;end_time;\n";

print RL "test_name;20us;40us;60us;80us;100us;200us;400us;600us;800us;1ms;2ms;4ms;6ms;8ms;10ms;12ms;14ms;16ms;18ms;20ms;40ms;60ms;80ms;100ms;200ms;400ms;600ms;800ms;1s;2s;4s;6s;8s;10s;20s;40s;60s;80s;120s;120+s;\n";

print WL "test_name;20us;40us;60us;80us;100us;200us;400us;600us;800us;1ms;2ms;4ms;6ms;8ms;10ms;12ms;14ms;16ms;18ms;20ms;40ms;60ms;80ms;100ms;200ms;400ms;600ms;800ms;1s;2s;4s;6s;8s;10s;20s;40s;60s;80s;120s;120+s;\n";

while(<F>){
        my ($test_name,$write_ops,$read_ops,$write_mb,$read_mb,$threads,$record_size,$file_size,$start_time,$end_time,$is_sync);

        my @write_latency_results;
        my @read_latency_results;


        if(/test_name;threads;record_size;file_size;sync_write;/){ next; }

        my @params = split(/;/);
        my $test_file_names = "";

        $test_name = $params[0];

        if($params[1] < 0 || $params[1] > 1024 ||
           $params[2] !~ /^\d+[kK]$/ ||
           $params[3] !~ /^\d+[kKmMgGtT]$/ ||
           $params[4] < 0 || $params[4] > 1){
                die("Invalid entry in CSV-file\n");
        }
        else {
                $threads = $params[1];
                $record_size = $params[2];
                $file_size = $params[3];
        }
        for(my $n=0;$n<$params[1];$n++){
                $test_file_names .= "file$n ";
        }
        my $issync = "";
        if($params[4] == 0){ $is_sync = 0; }
        else { $issync = " -O"; $is_sync = 1;}
        $start_time = localtime;
        print "Starting test ".$params[0]." @ ".$start_time." with ".$params[2]." record size and ".$params[1]." threads and ".$params[3]." file size\n";
        system("iozone -i 0 -i 1 -I -+z -+n".$issync." -t ".$params[1]." -r ".$params[2]." -s ".$params[3]." -F ".$test_file_names." > results.txt");
        $end_time = localtime;
        for(my $n=0;$n<$params[1];$n++){ unlink "file$n"; }

        my $rs_as_bytes = 0;
        if($params[2] =~ /^\d+[kK]$/){
                $params[2] =~ /^(\d+).*$/;
                $rs_as_bytes = $1*1024;
        }

        open(K,"results.txt") or
                die "Unable to open results.txt";

        while(<K>){
                if(/Children see throughput/ && /writers/){
                        my @tmp = split(/\s+/);
                        my $tmpval = $tmp[9];
                        $write_ops = sprintf("%d",($tmpval*1024)/$rs_as_bytes);
                        $write_mb = sprintf("%.2f",$tmpval/1024);
                }
                if(/Children see throughput/ && /readers/){
                        my @tmp = split(/\s+/);
                        my $tmpval = $tmp[8];
                        $read_ops = sprintf("%d",($tmpval*1024)/$rs_as_bytes);
                        $read_mb = sprintf("%.2f",$tmpval/1024);
                }
        }

        my $fn = 0;
        my $v = 0;
        my $flag = 0;

        while(-f "Iozone_histogram_child_$fn.txt"){
                open(LF,"Iozone_histogram_child_$fn.txt");
                while(<LF>){
                        if(/Op: write/){
                                $v = 0;
                                $flag = 1;
                        }
                        if(/Op: Read/){
                                $v = 0;
                                $flag = 2;
                        }
                       if($flag == 1){
                                if(/Band/){
                                        my @values = split(/\s+/);
                                        for(my $n=2;$n<=6;$n++){
                                                if($values[$n]){
                                                        my ($key,$val) = split(/:/,$values[$n]);
                                                        $write_latency_results[$v] = $val;
                                                        $v++;
                                                }
                                        }
                                }
                        }
                        if($flag == 2){
                                if(/Band/){
                                        my @values = split(/\s+/);
                                        for(my $n=2;$n<=6;$n++){
                                                if($values[$n]){
                                                        my ($key,$val) = split(/:/,$values[$n]);
                                                        $read_latency_results[$v] = $val;
                                                        $v++;
                                                }
                                        }
                                }
                        }
                }
                close(LF);
                unlink("Iozone_histogram_child_$fn.txt");
                $fn++;
        }

        print T $test_name.";".$write_mb.";".$read_mb.";".$write_ops.";".$read_ops.";".$threads.";".$record_size.";".$file_size.";".$start_time.";".$end_time."\n";

        print WL $test_name.";";
        print RL $test_name.";";
        foreach my $k(@write_latency_results){ print WL $k.";"; }
        foreach my $k(@read_latency_results){ print RL $k.";"; }
        print WL "\n";
        print RL "\n";

        unlink("results.txt");
}
close(T);
close(WL);
close(RL);
