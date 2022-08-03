from xml.dom import minidom
import pulp
import pandas as pd
import itertools
import numpy as np

def gen_feasible(num_sensors = [10, 30, 50, 70, 100], num_actuators=[10, 30, 50, 70, 100], aps=[1,2,4,8,16,32], num_slots=28):
    a = pd.DataFrame(itertools.product(num_sensors, num_actuators, aps))
    a.columns = ["num_sensors", "num_actuators", "aps"]
    a["r1"] = a["num_sensors"] * a["aps"] < num_slots*16
    a["r2"] = a["num_sensors"] * a["aps"] < a["num_actuators"]*num_slots
    feasible = a[(a["r1"] == True) & (a["r2"] == True)]
    return feasible[["num_sensors", "num_actuators", "aps"]]

def is_feasible(num_sensors, num_actuators, aps, num_slots=28):
    r1 = num_sensors * aps < num_slots*16
    r2 = num_sensors * aps < num_actuators*num_slots
    return r1 and r2

def generate_linear_allocation(num_slots=28, num_channels=16, num_sensors=60, num_actuators=10, aps=4, max_slots_per_dest=1):
    a = np.empty(num_slots*num_actuators)
    a.fill(np.nan)
    m = min(num_sensors*max_slots_per_dest,num_slots*num_actuators)
    a[0:m] = np.arange(m)
    a = a % num_sensors
    a = np.reshape(a,(num_slots,num_actuators)).T
    l=[]
    for i in range(num_actuators):
        for j in range(num_slots):
            channel = i
            slot = j
            if (slot < num_slots and not np.isnan(a[i,j])):
                l.append({"abs_slot": slot, "origin": a[i,j], "dest": num_sensors + i, "channel": channel})

    return pd.DataFrame(l)

def generate_allocation(num_slots=28, num_channels=16, num_sensors=60, num_actuators=10, aps=4, max_slots_per_dest=1):
    slots = range(num_slots)
    #channels = range(16)
    num_nodes = num_sensors + num_actuators

    sensors = range(0, num_sensors)
    actuators = range(num_sensors, num_nodes)
    nodes = range(num_nodes)

    var = [(slot, i, j) for slot in slots for i in nodes for j in nodes]
    aux = [(i,j) for i in nodes for j in nodes]
    problem = pulp.LpProblem('Slot_allocation', pulp.LpMinimize)

    decision = pulp.LpVariable.dicts('Slots', var, lowBound=None, upBound=None, cat='Binary')
    #decision_aux = pulp.LpVariable.dicts('Aux', aux, lowBound=None, upBound=None, cat='Binary')
    # R1: Channel restriction
    for slot in slots:
            problem += pulp.lpSum(decision[(slot,i,j)] for i in nodes for j in nodes) <= num_channels

    #R2: Sensors must send to at least some actuators
    for i in sensors:
        problem += pulp.lpSum(decision[(slot, i, j)] for slot in slots for j in nodes) >= aps

    #R3: Sensor cannot receive
    for i in nodes:
        for j in sensors:
            problem += pulp.lpSum(decision[(slot, i, j)] for slot in slots) == 0

    #R4: Nodes cannot receive simultaneously
    for j in nodes:
        for slot in slots:
            problem += pulp.lpSum(decision[(slot, i, j)] for i in nodes) <= 1

    #R5: Nodes cannot transmit simultaneously
    for i in nodes:
        for slot in slots:
            problem += pulp.lpSum(decision[(slot, i, j)] for j in nodes) <= 1

    #R6: Sensors should only transmit one packet to an actuator
    for i in sensors:
        for j in actuators:
            #problem += pulp.lpSum(decision[(slot, i, j)] for slot in slots) == max_slots_per_dest*decision_aux[(i,j)]
            problem += pulp.lpSum(decision[(slot, i, j)] for slot in slots) <= 1

    ##R7: Auxiliar variable
    #for i in sensors:
    #    for j in actuators:
    #        problem += pulp.lpSum(decision[(slot, i, j)] for slot in slots) <= 1000000*decision_aux[(i,j)]

    problem += pulp.lpSum(decision[(slot, i, j)] for slot in slots for i in range(num_nodes) for j in range(num_nodes))
    res = problem.solve()
    
    if (res < 0):
        return None

    df = pd.DataFrame()
    for v in var:
        value = decision[v].varValue
        if value == 1:
            df = df.append({"abs_slot" : v[0], "origin": v[1], "dest": v[2]}, ignore_index=True)

    df["channel"] = df.groupby("abs_slot").cumcount()
    return df

def abs_slot_to_dsme_coords(pos,cap_reduction):
    if (pos < 7):
        slot_id = pos;
    elif cap_reduction:
        slot_id = (pos - 7) % 15
    else:
        slot_id = (pos % 7) + 8
    
    if (pos < 7):
        superframe_id = 0
    elif cap_reduction:
        superframe_id = 1 + ((pos - 7) / 15)
    else:
        superframe_id = (pos / 7)
    
    return (int(superframe_id), int(slot_id))
