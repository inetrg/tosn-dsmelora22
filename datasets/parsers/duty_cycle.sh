TX_FILE=$(mktemp)
PCAP_FILE=$(mktemp)
WS_FILE=$(mktemp)
MATCHED_ACK_FILE=/tmp/$(basename $1)

awk -F ";" '$4 ~ /TX$/ {printf "%.3f",$1;print " " $5}' $1 | sed 's/[[:space:]]*$//' > $TX_FILE
python3 pcapify.py -if $TX_FILE -of $PCAP_FILE
tshark -r $PCAP_FILE \
        -E separator=, -E header=y -T fields -e wpan.fcf -e wpan.src16 \
        -e wpan.dst16 -e wpan.frame_length -e wpan.frame_type -e wpan.seq_no \
        -e wpan.src64 -e wpan.dst64 -e frame.time_epoch -e wpan > $WS_FILE
./match_ack.awk $WS_FILE > $MATCHED_ACK_FILE
./duty_cycle.awk $MATCHED_ACK_FILE
rm $TX_FILE $PCAP_FILE $WS_FILE $MATCHED_ACK_FILE
