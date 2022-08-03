#!/bin/awk -f

@include "common.awk"

BEGIN {
    FS=","
    del source[0]
    skip_valid = 1;
    print "timestamp,fcf,src_addr,dst_addr,frame_length,frame_type,seq_no,info,toa"
}

NR == 1 {
    next;
}

{
    fcf = $1
    src_addr = $2
    dst_addr = $3
    frame_length = $4;
    frame_type = $5;
    seq_no = $6;
    src_addr_ext = $7;
    dst_addr_ext = $8;
    timestamp = $9
    info = $10

    # Include 2 bytes of CRC
    time_on_air = toa(frame_length + 2)
}

$1 ~ /^0x2002/ {
    if (source[seq_no] == 0) {
        next;
    }
    src_addr = source[seq_no]
}

$1 !~ /^0x2002/ {

    if (src_addr == "") {
        split(src_addr_ext, a, ":");
        src_addr = "0x" a[7] a[8]
    }
    if (dst_addr == "") {
        split(dst_addr_ext, a, ":");
        dst_addr = "0x" a[7] a[8]
    }
    seq_n = $6;
    source[seq_n] = dst_addr;
}

{
    print timestamp "," fcf "," src_addr "," dst_addr "," frame_length "," frame_type "," seq_no "," info "," time_on_air
}
