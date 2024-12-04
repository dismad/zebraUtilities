#!/bin/bash

b=($(./toCurl.sh getblockchaininfo | jq . |  grep 'chainValue": [0-9]+' -Eo)) 
b=("${b[@]#chainValue}")

SSupply=$(echo "scale=0; ${b[3]} + ${b[5]} + ${b[7]} + ${b[9]}" | bc)
TSupply=$(echo "scale=0; ${b[1]} + $SSupply" | bc)

echo
echo "Total Chain Supply       : $TSupply"

echo "Total Transparent supply : ${b[1]}"

echo "Total Sprout supply      : ${b[3]}"

echo "Total Sapling supply     : ${b[5]}"

echo "Total Orchard supply     : ${b[7]}"

echo "Total Lockbox supply    : ${b[9]}"

echo "-----------------------------------"
echo "Total Shielded Supply    : $SSupply"
