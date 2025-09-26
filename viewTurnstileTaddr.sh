#!/bin/bash

taddr="${1}"   #1 represent 1st argument
debug="${2}"


if [ -f txidJSON ]; then
	rm txidJSON
fi

if [ -z $debug ]; then
	debug=false
fi

./listTaddyTXs.sh $taddr > txidJSON

if [ -f turnstileData.md ]; then
	rm turnstileData.md
fi

echo "Crunching data ..."
echo

cat txidJSON | xargs -I {} ./viewTurnstileTXID.sh {} "$debug" | tee turnstileData.md


tCount=$(cat turnstileData.md | awk '{print $1}' | paste -sd+ | bc)
sCount=$(cat turnstileData.md | awk '{print $2}' | paste -sd+ | bc)
oCount=$(cat turnstileData.md | awk '{print $3}' | paste -sd+ | bc)


echo
echo "$taddr has $(cat txidJSON | wc -l)" transactions
echo

echo "$sCount Sapling Outputs/Spends"
echo "$oCount Orchard actions"




