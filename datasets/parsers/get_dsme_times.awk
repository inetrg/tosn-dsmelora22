#!/bin/awk -f
BEGIN {
    FS=";"
}
@include "common.awk"

END {
    for (_addr in tx_attempt) {                                                 
       for (_id in tx_attempt[_addr]) {                                        
           print tx_attempt[_addr][_id], rx[_addr][_id]
       }                                                                       
   }
}
