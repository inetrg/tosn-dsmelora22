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
- [RIOT](https://github.com/inetrg/RIOT/tree/45c9637040e48e370271c1ac54554f40d5f2d5fa): Contains the fork of the RIOT repository with the DSME-LoRa code
and DSME applications. Check the [openDSME port](https://github.com/inetrg/RIOT/tree/45c9637040e48e370271c1ac54554f40d5f2d5fa/pkg/opendsme), the [DSME-LoRa compatible SX127x driver](https://github.com/inetrg/RIOT/blob/45c9637040e48e370271c1ac54554f40d5f2d5fa/drivers/sx127x/sx127x_rf_ops.c) as well as
the openDSME applications ([opendsme](https://github.com/inetrg/RIOT/tree/45c9637040e48e370271c1ac54554f40d5f2d5fa/examples/opendsme), [opendsme_actuator](https://github.com/inetrg/RIOT/tree/45c9637040e48e370271c1ac54554f40d5f2d5fa/examples/opendsme_actuator), [opendsme_sensor](https://github.com/inetrg/RIOT/tree/45c9637040e48e370271c1ac54554f40d5f2d5fa/examples/opendsme_sensor))

