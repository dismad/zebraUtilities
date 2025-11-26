#!/bin/bash

block="${1}"
debug="${2}"

#If coinbase
#Add all outputs 
#From this total, subtract miner portion,and subtract funding stream portion


if [[ "$debug" == "true" ]];then
	
	./listBlockTXs.sh $block | xargs -n1 ./tx_type.sh | awk '{ print $11,$15}'
else
	output=$(./getCoinbase.sh $block | xargs -n1 ./txDetails.sh | jq .vout[].value | paste -sd+ | bc)
	valueOut=$(./getCoinbase.sh $block | xargs -n1 ./txDetails.sh | jq .valueBalance)

	if [[ "$valueOut" != "0" ]]; then
		temp=$(./getCoinbase.sh $block | xargs -n1 ./txDetails.sh | jq .valueBalance | jq 'if . < 0 then . * -1 else . end')
		output=$( echo "$output + $temp" | bc)
		#echo "output: $output"
	fi

	if [[ "$block" -lt "653600" ]]; then
		miner=10
		founders=2.5
		fstream=0
	elif [[ "$block" -lt "1046400" ]]; then
                miner=5
		founders=1.25
		fstream=0

        elif [[ "$block" -ge "1046400" ]]; then
                miner=$(./toCurl.sh getblocksubsidy $block | jq .miner)
		founders=0
		fstream=$(./toCurl.sh getblocksubsidy $block | jq .fundingstreamstotal)
	else
		miner=0
		founders=0
	        fstream=0
		
	fi

	#echo "output: $output"
	#echo "miner : $miner"
	#echo "foundr: $founders"
	#echo "fstrem: $fstream"
	#echo
	output=$(echo "$output - ($miner + $fstream + $founders)" | bc)
	echo $output
fi