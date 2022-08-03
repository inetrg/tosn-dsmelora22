#!/bin/awk -f

@include "common.awk"

BEGIN {
    FS=";"
    print string_conf
}

END {
    print_conf()
    printf "\n"
}
