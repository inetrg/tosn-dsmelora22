#!/usr/bin/python3

import os
import sys
import numpy as np
import pandas as pd

from allocate import is_feasible, generate_allocation, abs_slot_to_dsme_coords, generate_linear_allocation

nodes = []
for line in sys.stdin:
    nodes.append(line.rstrip())

SF_PER_MSF = int(os.environ.get("SF_PER_MSF", 1))
NUM_ACTUATORS = int(os.environ.get("NUM_ACTUATORS", 3))
NUM_SLOTS = 7*SF_PER_MSF
NUM_SLOTS_PER_DEST = int(os.environ.get("NUM_SLOTS_PER_DEST", 1))
NUM_SENSORS = int(os.environ.get("NUM_SENSORS", 10))
APS = 1

if not is_feasible(len(nodes)-NUM_ACTUATORS, NUM_ACTUATORS, APS, num_slots=NUM_SLOTS):
    print("[ERROR] Scenario not valid for static allocation", file=sys.stderr)
    exit(1)
# Generate allocation
df = generate_allocation(num_slots=NUM_SLOTS, num_sensors=len(nodes)-NUM_ACTUATORS, num_actuators=NUM_ACTUATORS, aps=APS, max_slots_per_dest=NUM_SLOTS_PER_DEST)
#df = generate_linear_allocation(num_slots=NUM_SLOTS, num_sensors=len(nodes)-NUM_ACTUATORS, num_actuators=NUM_ACTUATORS, aps=APS, max_slots_per_dest=NUM_SLOTS_PER_DEST)

gts_commands = []
actuators = []
sensors = []
sensor_act_assoc = {}
for i,r in df.iterrows():
    source_id = int(r["origin"])
    dest_id = int(r["dest"])
    sensors.append(nodes[source_id])
    actuators.append(nodes[dest_id])
    nodes_source_id = nodes[source_id]
    if nodes_source_id not in sensor_act_assoc:
        sensor_act_assoc[nodes_source_id] = []
    sensor_act_assoc[nodes_source_id].append(nodes[dest_id])
    superframe_id, slot_id = abs_slot_to_dsme_coords(int(r["abs_slot"]),cap_reduction=False)
    if (superframe_id > 0):
        slot_id -= 8
    channel = int(r["channel"])
    hex_to_addr = lambda d: f"{30 + int(d/10)}:{30 + d-10*int(d/10)}"
    source_node = source_id
    source = hex_to_addr(source_id+1)
    dest = hex_to_addr(dest_id+1)
    gts_commands.append({"node_id": nodes[source_id], "command": f"gts {dest} 1 {superframe_id} {slot_id} {channel}"})
    gts_commands.append({"node_id": nodes[dest_id], "command": f"gts {source} 0 {superframe_id} {slot_id} {channel}"})
actuators = list(set(actuators))
sensors = list(set(sensors))
for cmd in gts_commands:
    print(f"{cmd['node_id']};{cmd['command']}")
