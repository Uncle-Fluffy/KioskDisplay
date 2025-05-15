#!/bin/bash

IP="192.168.1.11"

scp *-2.jpg tcarter@$IP:/home/tcarter/Pictures/
scp evening/*-2.jpg tcarter@$IP:/home/tcarter/Pictures/evening
scp night/*-2.jpg tcarter@$IP:/home/tcarter/Pictures/night
