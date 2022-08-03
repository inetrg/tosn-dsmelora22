function max(num1, num2) {
    if (num1 < num2) {
        return num2;
    }
    return num1;
}

function ceil(x) {
    if (x == int(x)) {
        return x;
    }
    return (int(x) + 1);
}

function sum(__arr) {
    for (__i in __arr) {
        __val += __arr[__i];
    }
    return __val;
}

function toa(payload) {
    t_s = 1.024;
    n_preamble = 8;
    t_preamble = (n_preamble + 4.25) * t_s;
    sf = 7;
    crc = 1;
    de = 0;
    cr = 1;
    d1 = 8*payload - 4*sf + 28 + 16*crc;
    d2 = 4*(sf - 2*de);
    d3 = cr + 4;
    op = ceil(d1/d2)*d3;
    n_payload = 8 + max(op,0);
    t_payload = n_payload * t_s
    return t_preamble + t_payload;
}

function print_conf() {

    printf("%f,%d,%d,%d,%d,%d,%d,%d,%d,%d", timestamp, n_nodes-1-n_actuators,txi,usecad,n_actuators,payload_length, cap,ack_req, num_packets,csma_standard)
}

BEGIN {
    delete crashed[0];
    delete tx[0];
    delete rx[0];
    delete pkt_lookup[0];
    delete tx_data[0];
    delete tx_attempt[0];
    delete assoc[0];
    delete addr[0];
    delete role[0];
    delete valid[i]
    delete last_queue[0];
    delete queue_timestamp[0];
    delete queue_aggregate[0];
    delete queue_aggregate_time[0];

    # Store the packet count (for removing transient)
    delete pkt_count[0]

    delete pkts_while_busy[0];
    delete agg_pkts_while_busy[0]
    delete agg_pkts_while_busy_len[0];

    delete busy_period_c[0];

    delete ql_timestamp[0];
    delete max_heap[0];
    delete heap[0];

    # constant value for initial value

    string_conf = "timestamp,n_sensors,txi,usecad,n_actuators,payload_length,cap,ack_req,num_packets,csma_standard"

    filename = ARGV[1]
    match(filename,"data_n_([0-9]+)_na_([0-9]+)_APS_([0-9]+)_txi_([0-9]+)_pl_([0-9]+)_cap_([0-1])_usecad_([0-1])" , a2);
    match(filename,"num_packets_([0-9]+)" , npackets);
    match(filename,"standard" , csmastd);
    num_packets = npackets[1];
    csma_standard = 0
    if (csmastd[0]) {
        csma_standard = 1
    }
    ack_req = 1;
    n_nodes = a2[1];
    n_actuators = a2[2];
    aps = a2[3];
    txi = a2[4];
    payload_length = a2[5];
    cap = a2[6]
    usecad = a2[7]

    if (num_packets == 0) {
        num_packets = 50;
    }

    C1 = 0;
    C2 = 700;

    delete should_measure[0];

}

$2 ~ /st-lrwan1/ {
    if (timestamp == 0) {
        timestamp = $1;
    }
}

{
    split($2,a,"-");
    curr_id = a[3];
}

/ROLE/ {
    r = $NF
    role[curr_id] = r;
    if (r != "PAN_COORD") {
        type[curr_id] = "ACTUATOR"
    }
}

$3 ~ /\[config\]/ {
    valid[curr_id] = 1;
}

$3 ~ /\[config\]/ && $4 ~ /ACK_REQ/ {
    ack_req = int($5)
}

$4 ~ /TX/ && $5 ~ /^[46]1/ {
    if (should_measure[addr[curr_id]] != 0) {
        tx_data[$2] += 1;
    }
}

{
    if (skip_valid == 0 && valid[curr_id] == 0) {
        next;
    }
}

$4 ~ /RECV/ {
    match($7, "^01(..)$", a)
    if (a[0] != "") {
       p_id = "100" a[1];
    }
    else {
        p_id = $7;
    }
    if (should_measure[$5] != 0 && rx[$5][p_id] == 0) {
        rx[$5][p_id] = $1;
        sink_recv[$5] += 1;
    }
}

$4 ~ /ASSOC/ {
    assoc[$2] = $5;
}

$4 ~ /ADDR/ {
    addr[curr_id] = $5
}

$4 ~ /heap/ {
    split($4, a, " ")
    if (valid[curr_id] && a[4] > max_heap[curr_id]) {
        max_heap[curr_id] = a[4];
    }
    heap[curr_id] = $4;
}

$4 ~ /TXTSND/ {
    type[curr_id] = "SENSOR"
    if (ql[$2] == 0) {
        # Regenerate
        agg_pkts_while_busy[addr[curr_id]][agg_pkts_while_busy_len[addr[curr_id]]] = pkts_while_busy[addr[curr_id]];
        pkts_while_busy[addr[curr_id]] = 0;
        agg_pkts_while_busy_len[addr[curr_id]] += 1;
        last_busy_period[addr[curr_id]] = $1;
    }
    else {
        pkts_while_busy[addr[curr_id]] += 1
    }

    if (last_busy_period[addr[curr_id]] > 0) {
        packets_in_busy_period[addr[curr_id]][busy_period_c[addr[curr_id]]] += 1;
    }

    pkt_count[$2] += 1;
    if (pkt_count[$2] >= C1 && pkt_count[$2] <= C2) {
        should_measure[addr[curr_id]] = 1;
    }
    else {
        should_measure[addr[curr_id]] = 0;
    }

    if (should_measure[addr[curr_id]] != 0) {
        tx_attempt[addr[curr_id]][$6] = $1;
    }
}

$4 ~ /QL/ {
    ql_timestamp[addr[curr_id]][$1] = $5
    ql[$2] = $5
    if (queue_timestamp[$2] != 0) {
        queue_aggregate[$2] += ($1 - queue_timestamp[$2])*last_queue[$2]
        queue_aggregate_time[$2] += ($1 - queue_timestamp[$2])
    }
    queue_timestamp[$2] = $1;
    last_queue[$2] = int($5);

    if ($5 == 0) {
        if (last_busy_period[addr[curr_id]] > 0) {
            busy_period[addr[curr_id]][busy_period_c[addr[curr_id]]] = $1 - last_busy_period[addr[curr_id]];
            busy_period_c[addr[curr_id]] += 1;
        }
    }
}

$5 ~ /ALLOC/ {
    alloc[$2] += 1;
}

$5 ~ /DEALLOC/ {
    alloc[$2] -= 1;
}

$2 ~ /st-lrwan1/{
    if (init_time == 0) {
        init_time = $1;
    }
    nodes[$2] = 1;
    curr_time = $1;
}

$0 ~ /home|Context|ASSERT/ {
    crashed[$2] = 1;
    reason[$2] = $3;
}

END {

}
