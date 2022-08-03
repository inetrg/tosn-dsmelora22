# TOSN DSME-LoRa 2022

This repository contains the measurement applications, datasets and DSME-LoRa
code of our contribution <i>DSME-LoRa: Seamless Long Range Communication Between
Arbitrary Nodes in the Constrained IoT</i>

To clone this repository and all submodules run:
```
git clone --recursive https://github.com/inetrg/tosn-dsmelora22.git
```

## Repository structure
This repository contains three folders:
- [datasets](datasets): Contains all datasets and evaluation tools. Please refer
to the [README](datasets/README.md)
- [simulation](https://github.com/inetrg/dsme_lora/tree/e94c7e55c4d69e629d2e5d7cecb1ce7a6c89a230): Contains the code of the Omnet++ simulation environment.
Please refer to the [README](https://github.com/inetrg/dsme_lora/blob/e94c7e55c4d69e629d2e5d7cecb1ce7a6c89a230/README.md)
- [RIOT](https://github.com/inetrg/RIOT/tree/a0d83380996283f60b9a6a18bf9f5c764f50b8ab): Contains the fork of the RIOT repository with the DSME-LoRa code
and DSME applications. Check the [openDSME port](https://github.com/inetrg/RIOT/tree/a0d83380996283f60b9a6a18bf9f5c764f50b8ab/pkg/opendsme), the [DSME-LoRa compatible SX127x driver](https://github.com/inetrg/RIOT/blob/a0d83380996283f60b9a6a18bf9f5c764f50b8ab/drivers/sx127x/sx127x_rf_ops.c) as well as
the openDSME applications ([opendsme](https://github.com/inetrg/RIOT/tree/a0d83380996283f60b9a6a18bf9f5c764f50b8ab/examples/opendsme), [opendsme_actuator](https://github.com/inetrg/RIOT/tree/a0d83380996283f60b9a6a18bf9f5c764f50b8ab/examples/opendsme_actuator), [opendsme_sensor](https://github.com/inetrg/RIOT/tree/a0d83380996283f60b9a6a18bf9f5c764f50b8ab/examples/opendsme_sensor))
- [experiments](experiments): Contains scripts to reproduce experiments on IoT-LAB.
Please refer to the [README.md](experiments/README.md)
