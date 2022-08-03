#!/bin/awk -f

@include "common.awk"

BEGIN {
    FS=";"
}

$4 ~ /TX_INFO/ {
    if(length(tx_attempt)) {
        unique_trans += 1; 
        num_trans += int($6)
    }
}

END {
    for (i in tx_attempt) {
        for (j in tx_attempt[i]) {
            total_tx += 1;
        }
    }
    for (i in rx) {
        _rx += length(rx[i]);
    }
    print "total_tx,tx_mac_unique,tx_mac,retrans,successful,PRR,retrans_norm"
    if (unique_trans == 0) {
        for (i in tx_data) {
            unique_trans += tx_data[i]
            num_trans = unique_trans
        }
    }
    else {
        retrans_norm = (num_trans-unique_trans)/unique_trans
    }
    num_retrans = num_trans-unique_trans
    printf "%d,%d,%d,%d,%d,%f,%f\n", total_tx, unique_trans, num_trans, num_retrans, _rx, _rx/total_tx*100, retrans_norm
}
