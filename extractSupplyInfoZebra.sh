#!/bin/bash

a=($(./toCurl.sh getblockchaininfo | jq .valuePools[].chainValue))

SSupply=$(echo "${a[1]} + ${a[2]} + ${a[3]} + ${a[5]}" | bc)
TSupply=$(echo "${a[0]} + ${a[4]} + $SSupply" | bc)

echo
echo "Total Chain supply:       $TSupply"

echo "Total Transparent supply: ${a[0]}"

echo "Total Sprout supply:      ${a[1]}"

echo "Total Sapling supply:     ${a[2]}"

echo "Total Orchard supply:     ${a[3]}"

echo "Total Lockbox supply:     ${a[4]}"

echo "Total Ironwood supply:    ${a[5]}"

echo "-------------------------------------------"
echo "Total Shielded supply:    $SSupply"


