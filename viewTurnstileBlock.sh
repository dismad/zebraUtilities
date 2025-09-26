#!/bin/bash

block="${1}"   #1 represent 1st argument
debug="${2}"

if [ -f txidJSON ]; then
	rm txidJSON
fi

if [ -f txidsFromBlock ]; then
	rm txidsFromBlock
fi

if [ -z $debug ]; then
	debug=false
fi

echo
echo "Calculating Turnstile Data ..."
echo

./listBlockTXs.sh $block > txidsFromBlock

if [[ "$debug" == "false" ]]; then
	
	./drawBlock.sh "Block: $block"
	result=$(cat txidsFromBlock | xargs -I {} ./viewTurnstileTXID.sh {} "$debug" | tee turnstileData.md)
	cat <<-EOF
	T|S|O
	-----
	$result
	EOF

	tCount=$(cat turnstileData.md | awk '{print $1}' | paste -sd+ | bc)
	sCount=$(cat turnstileData.md | awk '{print $2}' | paste -sd+ | bc)
	oCount=$(cat turnstileData.md | awk '{print $3}' | paste -sd+ | bc)

	echo
	echo "$(cat txidsFromBlock | wc -l)" transactions


	echo "$sCount Sapling Outputs/Spends"
	echo "$oCount Orchard actions"

else
	cat txidsFromBlock | xargs -I {} ./viewTurnstileTXID.sh {} "$debug" | tee turnstileData.md
fi
