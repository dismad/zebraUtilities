#!/bin/bash

startBlock="${1}"   #1 represent 1st argument
endBlock="${2}"     #2 represent 2st argument


for i in `seq $startBlock $endBlock`; do ./toCurl.sh getblock $i | jq .result.tx.[]; done

