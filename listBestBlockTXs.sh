#!/bin/bash


./getBlockCount.sh | xargs -n1 ./listBlockTXs.sh
