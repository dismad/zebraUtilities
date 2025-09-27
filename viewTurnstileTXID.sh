#!/bin/bash

txID="${1}"   #1 represent 1st argument
debug="${2}"

if [ -f txidJSON ]; then
	rm txidJSON
fi

if [ -z $debug ]; then
	debug="false"
fi

./toCurl.sh getrawtransaction $txID 1 > txidJSON

txJSON=$(cat txidJSON | jq)
sSpend=$(echo $txJSON | jq -r '.vShieldedSpend | length')
sOutput=$(echo $txJSON | jq -r '.vShieldedOutput | length')
oActions=$(echo $txJSON | jq -r '.orchard.actions | length')

if [ "$debug" = "true" ]; then
	
	currentBlock=$(cat txidJSON | jq .height)
	currentDate=$(./getDateFromTX.sh  $txID)
	echo
	echo "Block: $currentBlock | txid: $txID | Date: $currentDate" 
	echo "       -----------------------"
	echo "       Sapling vShieldedSpends: $sSpend"
	echo "       Sapling vShieldedOutput: $sOutput"
	echo "       Orchard Actions:       : $oActions"
	echo "       -----------------------"
	echo
else
	isSapling=0
	isOrchard=0

	if [[ "$sSpend" > "0" ]] || [[ "$sOutput" > "0" ]]; then
        	isSapling=1
	fi
	
	if [[ "$oActions" > "0" ]]; then
		isOrchard=1
	fi


	if [[ "$isSapling" == "1" ]] && [[ "$isOrchard" == "1" ]]; then
		
		echo "0 1 1 "

	elif [[ "$isSapling" == "1" ]] && [[ "$isOrchard" == "0" ]]; then

		echo "0 1 0 "

	elif [[ "$isSapling" == "0" ]] && [[ "$isOrchard" == "1" ]]; then
		
		echo "0 0 1 "

	elif [[ "$isSapling" == "0" ]] && [[ "$isOrchard" == "0" ]]; then
	
		echo "1 0 0 "
	fi
fi

