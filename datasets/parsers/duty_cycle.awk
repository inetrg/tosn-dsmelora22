#!/bin/awk -f

NR == 1 {
    next;
}

function addr_to_id(addr) {
    hex_addr = int(strtonum(addr));
    d1 = int(hex_addr/0xFF);
    d2 = hex_addr - d1*256;
    d1 -= int(0x30);
    d2 -= int(0x30);
    return d1*10 + d2;

}
function resolve_type(t) {
    t = strtonum(t)
    if (t == 0) {
        return "beacon";
    }
    else if (t == 1) {
        return "data";
    }
    else if (t == 2) {
        return "ack";
    }
    else if (t == 3) {
        return "command";
    }
    else {
        print("ERROR");
        exit;
    }
}

{
    dc[$3][resolve_type($6)]+= $9;
    agg[$3] += $9;
    if (first_packet[$3] == 0) {
        first_packet[$3] = $1
    }
    last_packet[$3] = $1
}

END {
    for (_node in dc) {
        # IoT-LAB artifacts...
        if (_node == "0x" || (last_packet[_node]-first_packet[_node]) == 0) {
            continue;
        }

        total_dt = last_packet[_node]-first_packet[_node]
        beacon = dc[_node]["beacon"]/1000
        data = dc[_node]["data"]/1000
        ack = dc[_node]["ack"]/1000
        command = dc[_node]["command"]/1000
        duty_cycle = agg[_node]/1000
        if (data == 0) {
            if (addr_to_id(_node) == 0) {
                _role = "pan_coord";
            }
            else {
                _role = "actuator";
            }
        }
        else {
            _role = "sensor";
        }
        printf "%s,%f,%f,%f,%f,%f,%s,%f\n", _node, duty_cycle, beacon, data, ack, command, _role, total_dt
    }
}

@include "common.awk"

BEGIN {
    delete dc[0][0];
    delete agg[0];
    delete node_info[0];
    delete first_packet[0];
    delete last_packet[0];
    FS=","

    print ("node,total_dc,beacon,data,ack,command,role,dt")
}
