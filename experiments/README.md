## Experiment scripts

This script runs multiple DSME-LoRa nodes on IoT-LAB hardware.

## Requirements

### Python libraries
- numpy
- pandas
- iotlab-cli
- pulp

### Linux tools
- socat
- jq
- GNU AWK

### Misc
- ARM-Toolchain and OpenOCD to compile and flash B-L072z-LRWAN1
- An [IoT-LAB](https://www.iot-lab.info/) account

## Run DSME-LoRa experiments

```
IOTLAB_USER=<your_iot_lab_user> OUTPUT_FOLDER=<output_folder> ./run_experiments.sh
```

