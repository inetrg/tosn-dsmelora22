## Available data sources

All available data sources are included in [datasets.tar.gz](https://cloud.haw-hamburg.de/index.php/s/VO5lcQJUN7uNj8j) (pass:`tosn_dsme_lora_22`).

`data_transmission.csv` contains the data used to generate
Sections 5.2,5.3,5.4.

The columns are described in the following list:
- `timestamp`: Timestamp of the experiment
- `n_sensors`: Number of source devices
- `txi`: Transmission interval
- `usecad`: Whether CSMA-CA transmission use CAD or not
- `n_actuators`: Number of sink devices
- `payload_length`: Payload length
- `cap`: Whether the device transmits on CAP (CSMA-CA) or CFP (GTS)
- `ack_req`: Whether the device transmit confirmed frames or not
- `num_packets`: The number of transmitted frames per device during the experiment
- `csma_standard`: Whether CSMA-CA use standard settings or not
- `delay_b`<X>: The X bin of the transmission delay CDF
- `delay_mean`: The average value of the transmission delay
- `delay_stdev`: The standard deviation of the transmission delay
- `delay_int_min`: The lower bound of confidence interval
- `delay_int_max`: The upper bound of confidence interval
- `min_delay`: The minimum transmission delay
- `delay_q1`: The 25% percentile of the transmission delay
- `delay_q2`: The 50% percentile of the transmission delay
- `delay_q3`: The 75% percentile of the transmission delay
- `max_delay`: The maximum transmission delay
- `total_tx`: Number of scheduled data frames
- `tx_mac_unique`: Number of unique transmitted data frames
- `tx_mac`: Number of data frames transmitted by the MAC layer
- `retrans`: Total number of frame retransmissions
- `successful`: Number of successfully received frames
- `PRR`: Packet Reception Ratio of the experiment
- `retrans_norm`: Number of retransmitted frames per transmitted frame.
- `total_cca`: Total number of CCA attempts
- `total_cca_with_collision`: Total number of CCA attempts while there was a packet on the air
- `total_cca_no_collision`: Total number of CCA attemps while the channel was free
- `cca_success`: Total number of successful CCA attempts
- `cca_success_and_collision`: Total number of successful detection of busy channel
- `cca_success_and_no_collision`: Total number of successful detection of clear channel
- `collisions`: Total number of frame collisions
- `csma_drop`: Total number of frames dropped by CSMA-CA
- `queue_drop`: Total number of frames dropped by the CAP queue
- `toa_node_agg`: List of aggregated time on air for each node
- `toa_node_roles`: List of roles for each node
- `toa_node_dt`: List of the times between last and first transmission, for each node.

`prr_coexistence.csv` contains data used to generate the figure
in Section 5.5.

The columns are described in the following list:
- `prr_baseline`: PRR of the baseline case (DSME-LoRa nodes without cross-traffic)
- `prr_cross`: PRR of the LoRaWAN cross-traffic case

`interference_prr_moving_avg.csv` contains data used to generate the
moving average PRR under interference from jammers in Section 5.6

The columns are described in the following list:
- `t_r<x>`: Time axis of the replica `x`
- `prr_r<x>`: Prr axis of the replica `x`

`energy.csv` contains raw current measurements used for Section 5.7

The columns are described in the following list:
- `n`: The sample index
- `cap`: Current samples for CAP transmission
- `cfp`: Current samples for CFP transmission
- `cfp_rx`: Current samples for CFP transmission (RX node)

`simulation.csv` contains all simulation data used for the
experiments (Sections 6,7). This file is the output of Omnet++ Scavetool for
all simulation results. See (Result Analysis with Python)[https://docs.omnetpp.org/tutorials/pandas/] from the official Omnet++ documentation for performing data analysis
on this data.

## Generate data sources from raw logs
`data_transmission.csv`, `prr_coexistence.csv`
and `interference_prr_moving_avg.csv` are generated
from raw log files.
To generate these files from the original raw data, extract
[raw_logs.tar.gz](https://cloud.haw-hamburg.de/index.php/s/O0cJ1YcVuWqSG3a)
(pass:`tosn_dsme_lora_2022`) in this folder and execute `get_all.sh`
