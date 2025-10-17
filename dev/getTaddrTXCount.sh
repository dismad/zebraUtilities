#!/bin/bash

taddr="${1}"    #1 represent 1st argument

#limit is 10485760
#100000 txid limit

end=$(./getCurrentHeight.sh)
start=$(( $end - 100000 ))

formattedInput="'{\"addresses\": [\"$taddr\"], \"start\": $start, \"end\": $end}'"

result=$(echo $formattedInput | xargs ./toCurl.sh getaddresstxids | jq .[] | wc -w)

echo $result