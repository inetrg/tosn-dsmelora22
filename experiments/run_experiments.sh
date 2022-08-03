NUM_ACTUATORS=${NUM_ACTUATORS=3}
OUTPUT_FOLDER=${OUTPUT_FOLDER=/tmp}

cd tools
for txi in 5 10 20;do
    for n in 5 10 15;do
        for ack_req in 0 1;do
            for cap in 0 1;do
                for use_cad in 0 1;do
                    filename=txi_${txi}_num_sensors_${n}_ack_req_${ack_req}_cap_${cap}_use_cad_${use_cad}.dat
                    TX_INTERVAL=$txi NUM_SENSORS=$n ACK_REQ=$ack_req CAP=$cap USE_CAD=$use_cad ./dsme.sh $OUTPUT_FOLDER/$filename
                done
            done
        done
    done
done
