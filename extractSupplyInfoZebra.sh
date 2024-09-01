#!/bin/bash

a=($(zcash-cli getblockchaininfo | jq .valuePools.[].chainValue))

SSupply=$(echo "${a[1]} + ${a[2]} + ${a[3]}" | bc)
TSupply=$(echo "${a[0]} + $SSupply" | bc)

echo
echo "Total Chain Supply       : $TSupply"

echo "Total Transparent supply : ${a[0]}"

echo "Total Sprout supply      : ${a[1]}"

echo "Total Sapling supply     : ${a[2]}"

echo "Total Orchard supply     : ${a[3]}"

echo "-----------------------------------"
echo "Total Shielded Supply    : $SSupply"


