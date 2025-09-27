#!/bin/bash

taddr="${1}"   #1 represent 1st argument
debug="${2}"


if [ -f txidJSON ]; then
	rm txidJSON
fi

if [ -z $debug ]; then
	debug=false
fi

./listTaddyTXs.sh $taddr > txids

if [ -f turnstileData.md ]; then
	rm turnstileData.md
fi

echo "Finding address portrait ..."
echo

result=$(cat txids | xargs -I {} ./viewTurnstileTXID.sh {} "$debug" | tee turnstileData.md)

tCount=$(cat turnstileData.md | awk '{print $1}' | paste -sd+ | bc)
sCount=$(cat turnstileData.md | awk '{print $2}' | paste -sd+ | bc)
oCount=$(cat turnstileData.md | awk '{print $3}' | paste -sd+ | bc)

length=$(echo $result | wc -w)

final=""
index=9
j=1

if [ -f yessir.md ]; then
	rm yessir.md
fi

while [ $index -lt $length ]; do
	
	echo $result | cut -c1-18 >> yessir.md

	temp=$( echo $result | cut -c1-18)
	result=$( echo $result | cut -c18-)

	j=$(( $j + 1 ))
        index=$((  $j * 9 ))
done

echo $result >> yessir.md

cat yessir.md


echo
echo "$taddr has $(cat txids | wc -l)" transactions
echo

echo "$sCount Sapling Outputs/Spends"
echo "$oCount Orchard actions"




