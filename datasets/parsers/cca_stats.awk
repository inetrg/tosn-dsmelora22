#!/bin/awk -f
@include "common.awk"

BEGIN {
    FS=";"
    count = 0;
    cca_success = 0;
    total_cca = 0;
    total_cca_with_collision = 0;
    total_cca_no_collision = 0;
    cca_success_and_collision = 0;
    cca_success_and_no_collision = 0;
    collisions = 0;
    total_packets = 0;
    delete num_cca[0]
    max_retries = 4
    csma_attempts_exceeded = 0
}

$4 ~ /TX$/ {
    split($5, a, " ")
    tx_len = length(a) + 2; # Add FCS
    t = $1
    time_on_air = toa(tx_len)/1000
    if (should_measure[addr[curr_id]] == 1) {
        total_packets += 1;
        if (t < packet_end) {
            collisions += 1;
        }
    }
    packet_end = max(t+time_on_air, packet_end)
    count += 1;
}

$4 ~ /^TX$/ && $5 ~ /^[46]1/{
    num_cca[curr_id] = 0
}

$4 ~ /^TXTSND/ {
    scheduled_packets += 1;
}

$4 ~ /^CCA$/ && $5 ~ /0/{
    num_cca[curr_id]++
    if (num_cca[curr_id] == (max_retries+1)) {
        csma_attempts_exceeded++;
        num_cca[curr_id] == 0
    }
}

$3 ~ /TXD/ {
    count -= 1;
}

$4 ~ /^CCA/ {
    total_cca += 1
    t = $1
    cca_status = int($5);
    if (count > 0) {
        # Collision
        total_cca_with_collision += 1;

        if (cca_status == 0) {
            cca_success += 1;
            cca_success_and_collision += 1;
        }
    }
    else {
        total_cca_no_collision += 1;
        if (cca_status == 1) {
            cca_success_and_no_collision += 1; 
            cca_success += 1;
        }
    }
}

END {
    if (ack_req) {
        csma_attempts_exceeded = 0
        scheduled_packets = 0
        queue_drop = 0

    }
    else {
        queue_drop = scheduled_packets - csma_attempts_exceeded - total_packets;
    }
    print ("total_cca,total_cca_with_collision,total_cca_no_collision,cca_success,cca_success_and_collision,cca_success_and_no_collision,collisions,csma_drop,queue_drop")
    printf "%d,%d,%d,%d,%d,%d,%d,%d,%d\n",total_cca,total_cca_with_collision,total_cca_no_collision,cca_success, cca_success_and_collision, cca_success_and_no_collision,collisions,csma_attempts_exceeded, queue_drop
}
