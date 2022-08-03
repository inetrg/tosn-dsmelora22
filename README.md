# tosn-dsmelora22

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
- [simulation](simulation): Contains the code of the Omnet++ simulation environment.
Please refer to the [README](simulation/README.md)
- [RIOT](RIOT): Contains the fork of the RIOT repository with the DSME-LoRa code
and DSME applications. Check the [openDSME port](RIOT/pkg/opendsme) as well as
the openDSME applications ([opendsme](RIOT/examples/opendsme), [opendsme_actuator](RIOT/examples/opendsme_actuator), [opendsme_sensor](RIOT/examples/opendsme_sensor))

