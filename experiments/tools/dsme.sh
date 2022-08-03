#!/bin/bash

PTY=$(mktemp -u)
function cmd {
    NODE="$1"
    CMD="$2"
    echo "$NODE;$CMD"
    echo "$NODE;$CMD" > $PTY
    timeout 0.01s cat $PTY > /dev/null 
}

function exp () {                                                               
    python -c "import numpy as np;print(np.random.exponential($1, 1)[0])"       
}

function randy_uniform () {                                                     
    python -c "import numpy as np;print(np.random.uniform($1, $2, 1)[0])"       
}

TX_INTERVAL=${TX_INTERVAL=10}
NUM_PACKETS=${NUM_PACKETS=200}
NUM_SENSORS=${NUM_SENSORS=5}
NUM_ACTUATORS=${NUM_ACTUATORS=3}
ACK_REQ=${ACK_REQ=0}
CAP=${CAP=0}
USE_CAD=${USE_CAD=1}
IOTLAB_USER=${IOTLAB_USER="user"}
IOTLAB_SITE=${IOTLAB_SITE="saclay"}

TOTAL_NODES=$(($NUM_SENSORS+$NUM_ACTUATORS+1))
RIOTBASE=../../RIOT

if [ -z "$1" ];then
    IOTLAB_OUTPUT=dsme_iotlab_output.dat
else
    IOTLAB_OUTPUT="$1"
fi

BETA=$(python -c "print($TX_INTERVAL/$TOTAL_NODES)")

echo "TX_INTERVAL: $TX_INTERVAL"
echo "NUM_PACKETS: $NUM_PACKETS"
echo "TOTAL_NODES: $TOTAL_NODES"
echo "BETA: $BETA"
echo "IOTLAB_USER: $IOTLAB_USER"
echo "IOTLAB_SITE: $IOTLAB_SITE"

while true; do
    echo "Booking experiment"
    EXP=$(iotlab-experiment submit -n LoRa -d 300 -l $TOTAL_NODES,archi=st-lrwan1:sx1276+site=saclay | jq ".id")
    iotlab-experiment wait -i $EXP

    NODES="$(iotlab-experiment get -i $EXP -n | jq ".items[].network_address" | tr -d '"' | awk -F "." '{print $1}')"
    # RUN experiment here
    echo $NODES
    ARRAY=($NODES)

    pushd $RIOTBASE/examples/opendsme
    TARGET_ELF="$(pwd)/bin/b-l072z-lrwan1/opendsme_example.elf"
    CFLAGS="-DCONFIG_DSME_PLATFORM_ACK_REQ=$ACK_REQ -DCONFIG_OPENDSME_USE_CAP=$CAP -DCONFIG_OPENDSME_PAYLOAD_LENGTH=16 -DUSE_CAD=$USE_CAD -DCAP_REDUCTION=0 -DCONFIG_DSME_PLATFORM_STATIC_GTS=1 -DCONFIG_DSME_PLATFORM_SF_PER_MSF=1" make -j4 clean all
    JSON=$(iotlab-node -i $EXP --flash $TARGET_ELF)
    FLASH_OUTPUT=$(echo $JSON | jq -r 'has("1")')
    echo $JSON
    popd
    if [[ $FLASH_OUTPUT == "true" ]];then
        echo "Flash failed: Trying again"
        iotlab-experiment stop -i $EXP
    else
        socat pty,rawer,link=$PTY SYSTEM:"ssh $IOTLAB_USER@$IOTLAB_SITE.iot-lab.info serial_aggregator -i $EXP 2>&1 | tee $IOTLAB_OUTPUT",stderr &
        error=0
        for n in $NODES
        do
            echo "Check"
            echo $n
            echo $(echo "$n;help" | socat -t 1 - $PTY)
            MANAGED=$(echo "$n;help" | socat -t 1 - $PTY | grep managed)
            if [ -n "$MANAGED" ]
            then
                echo "IoT-LAB error..."
                error=1
            fi
        done
        if [ "$error" -eq 1 ]
        then
            iotlab-experiment stop -i $EXP
        else
            echo "All OK"
            break
        fi
        sleep 2
    fi
done

sleep 1
echo "START"

# Reboot

iotlab-node -i $EXP --reset

PAN_COORD="$(echo "$NODES" | tr ' ' '\n' | head -n1)"
cmd "$PAN_COORD" "id 00"
cmd "$PAN_COORD" "start pan_coord"
cmd "$PAN_COORD" "status"

i=1
echo "$NODES" | tr ' ' '\n' | tail -n+2 | for node in $(cat);do
    while true;
    do
        cmd "$node" "id $(printf '%-2.2d\n' $i)"
        echo "Starting $node"
        ASSOC=$(echo "$node;start child" > $PTY
                timeout 45s cat $PTY | grep -a -e "$node;.*ASSOC;1")
        echo $ASSOC
        if [ -n "$ASSOC" ];
        then
            echo "Successfully associated $node"
            cmd "$node" "status"
            break;
        fi
        echo "Failed to associate $node"
        iotlab-node -i $EXP --reset -l saclay,st-lrwan1,$(echo $node | awk -F"-" '{print $NF}')
    done
    i=$((i+1))
done

SENSORS="$(echo $NODES | tr ' ' '\n' | tail -n+2 | head -n-3)"
ACTUATORS="$(echo $NODES | tr ' ' '\n' | tail -n3)"

# Setup GTS
declare -A TARGET_ADDR
GTS_COMMANDS="$(echo \"$NODES\" | tr ' ' '\n' | tail -n+2 | python3 gts.py | grep st-lrwan)"
while read n;
do
    echo $n
    node=$(echo $n | awk -F";" '{print $1}')
    TARGET_ADDR[$node]=$(echo $n | awk '{print $2}')
    echo $n | tr -d '"' > $PTY
done < <(echo "$GTS_COMMANDS")

PREPROC_LIST=$(                                                                          
    echo "$SENSORS" | for i in $(cat) 
do                                                                              
    python -c "import numpy as np;print(\"\n\".join([str(x) for x in np.cumsum(np.random.uniform($(($TX_INTERVAL-3)),$(($TX_INTERVAL+3)),$NUM_PACKETS))]))" | awk "{print \"$i,\"\$0}"
done | sort -t, -nk2                                                            
)
                                                                                
previous=0                                                                      
index=0

echo $PREPROC_LIST | for i in $(cat)                                                     
do                                                                              
    node=$(echo $i | awk -F"," '{print($1)}')                                   
    time=$(echo $i | awk -F"," '{print($2)}')                                   
    delay=$(bc -l <<< "$time-$previous")                                        
    actuator=${TARGET_ADDR[$node]}
    previous=$time                                                              
    payload=$(printf '%-16.16d\n' $index)
    index=$((index+1))
    echo "Sending to node $node and sleep for $delay"
    cmd $node "txtsnd $actuator"
    sleep $delay
done

echo "Finish"
sleep 30
iotlab-experiment stop -i $EXP
