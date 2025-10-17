#!/bin/bash

taddr="${1}"    #1 represent 1st argument

formattedInput="'{\"addresses\": [\"$taddr\"]}'"

echo $formattedInput
echo
echo $formattedInput | xargs ./toCurl.sh getaddresstxids | jq .[]

