#!/bin/awk -f
#
BEGIN {
    FS=" "
    N = 40
    print "time,PRR"
}

{
    pos = NR % N;
    val = $2
    if (val > 0) {
        arr[pos] = 1;
    }
    else {
        arr[pos] = 0;
    }
}

{
    if (NR < N) {
        timestamp = $1
        next;
    }
    agg = 0;
    for (i=0;i<N;i++) {
        agg += arr[i]
    }
    print ($1 - timestamp "," agg/N*100)
}
