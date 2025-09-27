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

echo "Crunching data ..."
echo

result=$(cat txids | xargs -I {} ./viewTurnstileTXID.sh {} "$debug" | tee turnstileData.md)

tCount=$(cat turnstileData.md | awk '{print $1}' | paste -sd+ | bc)
sCount=$(cat turnstileData.md | awk '{print $2}' | paste -sd+ | bc)
oCount=$(cat turnstileData.md | awk '{print $3}' | paste -sd+ | bc)

length=$(echo $result | wc -w)
final=""

echo $result
echo

index=18

while [ $length -gt 0 ]; do
	
	#final=$(echo $result | cut -c1-18)
        #remainder=$(( $length % 18 ))

	echo "Is index: $index less than length: $length?"
	echo

	if (( index < length )); then

		temp=$( echo $result | cut -c1-$index)
		result=$( echo $result | cut -c9-)

		echo -e "$temp\r"
		final=$( echo -e "$final$temp\r")
		echo "final: $final"
		index=$(( $index + 18 ))
	fi
	length=$(( $length - $index ))
done

echo $result | cut -c1-18
echo
echo
echo "$taddr has $(cat txids | wc -l)" transactions
echo

echo "$sCount Sapling Outputs/Spends"
echo "$oCount Orchard actions"




