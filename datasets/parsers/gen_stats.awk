#!/bin/awk -f

@include "common.awk"

BEGIN {
    FS=";"
    n = 100
    delete bins[0]
    for (i=0;i<n;i++) {
        bins[i] = 0
    }
    max_latencies = 0;
    success = 0;
    total_packets = 0;
    first = 0
    for (i=0;i<n;i++) {
        if (first > 0) {
            printf ","
        }
        first = 1;
        printf "delay_b%d",i
    }

    printf(",delay_mean,delay_stdev,delay_int_min,delay_int_max,min_delay,delay_q1,delay_q2,delay_q3,max_delay")
    printf "\n"
    mean = 0;
    stdev = 0;
    delete group_latency[0]
}

END {
    for (_addr in tx_attempt) {
        for (_id in tx_attempt[_addr]) {
            lat = rx[_addr][_id]-tx_attempt[_addr][_id]
            latency[tx_attempt[_addr][_id]] = lat
            if (lat >= 0) {
                group_latency[_addr][tx_attempt[_addr][_id]] = lat
            }
        }
    }
    total_packets = length(latency)

    len = asorti(latency, ordered);

    for (l=0;l<len;l++) {
        lat = latency[ordered[l]];
        if (lat < 0) {
            continue;
        }
        success++;
        mean += lat;
        if (lat > max_latencies) {
            max_latencies = lat;
        }
    }
    if (success == 0) {
        exit 0;
    }
    step = max_latencies / n;
    mean = mean / success;

    for (l=0;l<len;l++) {
        lat = latency[ordered[l]];
        if (lat < 0) {
            continue;
        }
        stdev += (lat - mean)*(lat-mean)
        i = int(lat / step);        
        bins[i] += 1
        if (i == 100) {
            i -= 1;
        }
    }

    stdev = sqrt(stdev / (success - 1));

    agg = 0;
    # Calculate pooled variance
    delete lat_num[0];
    delete lat_agg[0];
    delete lat_mean[0];

    # Calculate mean first
    for (_addr in group_latency) {
        for (_timestamp in group_latency[_addr]) {
            lat_num[_addr]++;
            lat_agg[_addr] += group_latency[_addr][_timestamp];
        }
    }

    # Then group variance
    for (_addr in group_latency) {
        _curr_mean = lat_agg[_addr]/lat_num[_addr];
        lat_mean[_addr] = _curr_mean;
        lat_agg[_addr] = 0;
        for (_timestamp in group_latency[_addr]) {
            _curr_lat = group_latency[_addr][_timestamp];
            lat_agg[_addr] += (_curr_lat - _curr_mean)*(_curr_lat - _curr_mean)
        }
        lat_agg[_addr] = lat_agg[_addr]/(lat_num[_addr] - 1);
    }
    
    _n = 0;
    for (i in lat_num) {
        pool_var += (lat_num[i]-1)*lat_agg[i];
        pool_mean += lat_num[i] * lat_mean[i];
        _n += lat_num[i];
    }
    pool_var = sqrt(pool_var/(_n-length(lat_num)));
    pool_mean = pool_mean / _n;
    mean = pool_mean
    stdev = pool_var;

    first = 0
    c = 0;
    for (b=0;b<n;b++) {
        c += 1;
        agg += bins[b] / success * (success/total_packets);
        if (first > 0) {
            printf ","
        }
        first = 1;
        printf "%f", agg;
    }
    w = 2.58*(stdev/sqrt(success));
    int_min = mean - w;
    int_max = mean + w;
    # Delete invalid before the calculation
    for (i in latency) {
        if (latency[i] < 0) {
            delete latency[i];
        }
    }
    n_sorted = asort(latency, sorted_latency);
    min_latency = sorted_latency[0];
    q_len = int(n_sorted/4)
    q1 = sorted_latency[q_len]
    q2 = sorted_latency[2*q_len]
    q3 = sorted_latency[3*q_len]

    # Print stuff
    printf(",%f,%f,%f,%f,%f,%f,%f,%f,%f",mean,stdev,int_min,int_max,min_latency,q1,q2,q3,max_latencies);
    printf("\n")
}
