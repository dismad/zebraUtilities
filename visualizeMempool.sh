#!/bin/bash

block="${1}"   #1 represent 1st argument




size=($(zcash-cli getrawmempool | jq -r 'length'))
currentBlock=($(zcash-cli getblockcount))


while true
do
	if [[ "$size" -gt 0 ]];then

		a=($(zcash-cli getrawmempool))
		numTx=$size
		a=("${a[@]}")

		countTransparent=0
		countSprout=0
		countSapling=0
		countOrchard=0
		
	 	echo
                echo "Current Block: $currentBlock"
		echo "Number of tx's in mempool: $numTx"
		echo "----------------------------------"

		while [[ "$size" -ge 1 ]]
		do
 
			  tx=$(echo ${a[size]} | tr -d ',' | tr -d '"')

			  result=$(./getType.sh $tx)

			  if [[ "$result" == *"Transparent"* ]]; then
			    if [[ "$result" == *"Sprout"* ]]; then
				# non pure, record only shielded Pool
				countSprout=$((countSprout+1))
			    elif [[ "$result" == *"Sapling"* ]]; then
				# non pure, record only shielded Pool              
			    	countSapling=$((countSapling+1))
			    elif [[ "$result" == *"Orchard"* ]]; then
				# non pure, record only shielded Pool              
			    	countOrchard=$((countOrchard+1))
			    else
				#pure transparent tx
				countTransparent=$((countTransparent+1))
			    fi
			 elif [[ "$result" == *"Sprout"* ]]; then
			    countSprout=$((countSprout+1))
			 elif [[ "$result" == *"Sapling"* ]]; then
			    countSapling=$((countSapling+1))
			 elif [[ "$result" == *"Orchard"* ]]; then
			    countOrchard=$((countOrchard+1))
			 else
			    #edge case
		            :
			 fi

		 	 echo  "Tx $size : $result"
		 	 size=$(( $size - 1 ))
		done

		echo
		echo "----------------------------------"
		echo "Summary:"
		echo
		echo "Transparent tx's: $countTransparent"
		echo "Sprout tx's     : $countSprout"
		echo "Sapling tx's    : $countSapling"
		echo "Orchard tx's    : $countOrchard"
	else
                echo "Current Block: $currentBlock"
		echo "No tx's in mempool!"
	fi
	sleep 5
        size=($(zcash-cli getrawmempool | jq -r 'length'))
        currentBlock=($(zcash-cli getblockcount))
        clear
done