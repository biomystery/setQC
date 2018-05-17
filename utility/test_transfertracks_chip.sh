#!/bin/bash

SETQC_DIR="/home/zhc268/data/outputs/setQCs/Set_101/2a85d6d99eb8c5f59e73d0b6a17226dd"
track_source_dir="/home/zhc268/data/outputs/"

cmd="transferTracks.sh -d $SETQC_DIR -s $track_source_dir  -l $SETQC_DIR/including_libs.txt"
