#!/bin/bash

current_block=$(zcash-cli getblockcount)
#now=$(zcash-cli getblock $current_block | jq .time)
difficulty=$(zcash-cli getdifficulty)

while true
do
    # Get latest block count
    #latest_block=$(zcash-cli getbestblockhash | xargs zcash-cli getblock | jq .height)
    latest_block=$(zcash-cli getbestblockhash | xargs zcash-cli getblock | jq .tx.[0] | xargs -n1 ./txDetails.sh | jq .height)
    
    # Check if latest block is greater than current block
    if [ "$latest_block" -gt "$current_block" ]
    then
	# Check for current Difficulty
        difficulty=$(zcash-cli getdifficulty)

	# Record Time
        #newBlockTime=$(date +%s)
	#newBlockTime=$(zcash-cli getblock $latest_block | jq .time)

        #calculate difference.
        #difference=$(( $newBlockTime - $now ))



        # Divide the difference by 3600 to calculate hours/ 60 for minutes
        #answer=$(bc <<< "scale=2 ; $difference/60")0
        #testTime=$(date +%R)


        # Display message with new block number
        echo
        echo "New block found! [$answer minutes since last block ($testTime)] (Difficulty: $difficulty)"
	echo "----------------"
	
	# List transaction ID's
        echo
	echo "Block $latest_block has $(./listBlockTXs.sh $latest_block | wc -l) transactions: "
	echo
	./listBlockTXs.sh $latest_block
        echo
        
        # Reset Time
        #now=$newBlockTime

	# loop through TX's of block
        index=$(./listBlockTXs.sh $latest_block | wc -l) 
	numTXs=$(./listBlockTXs.sh $latest_block | wc -l)
	#transparentCount=0
        #actionCount=0
        #sizeCount=0
        #arrayIndex=0
        blockSize=$(zcash-cli getblockcount | xargs zcash-cli getblock | jq .size)

        # Count number of inputs/outputs
        #outputs=$(./listBlockTXs.sh $latest_block | xargs -n1 ./txDetails.sh | jq .vout.[].n | wc -l)
	#inputs=$(./listBlockTXs.sh $latest_block | xargs -n1 ./txDetails.sh | jq .vin.[].txid | wc -l)

        # loop through TX's of block
	#while [[ index -ge 1 ]]
	#do
	    # Count size of tx's
            #size=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"]  | xargs -n1 ./txDetails.sh | jq .size)
            #sizeCount=$(($sizeCount + $size))

            # Count number of Orchard Actions
            #actions=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"] | xargs -n1 ./txDetails.sh | jq .orchard.actions | jq -r 'length')
            #actionCount=$(($actionCount + $actions))

            # Count number of Transparent TX's 
	   # temp=$(./listBestBlockTXs.sh | jq -s .["$arrayIndex"] | xargs -i ./txDetailsBestBlockHash.sh {} | jq .vout.[].scriptPubKey.type)
	    
		#if [[ "$temp" == *"\"pubkeyhash\""*  ||  "$temp" == *"\"scripthash\""* ]]; then
    			#transparentCount=$(( $transparentCount + 1))
		#else
    		#	:
		#fi
            #arrayIndex=$(( $arrayIndex + 1 ))
	    #index=$(( $index - 1 ))
	#done  

        #headerSize=$(($blockSize-$sizeCount))

        #echo "This block is $blockSize bytes: [(Header: $headerSize + TXs: $sizeCount) bytes]"
        echo "----------------"
	echo "This block has "$numTXs" transactions" #of which "$((numTXs-transparentCount))" are shielded"
        #echo "This block has $actionCount orchard actions."
	#echo "This block has $inputs total inputs."
	#echo "This block has $outputs total outputs."

        current_block=$latest_block
        #echo $current_block $numTXs $transparentCount $((numTXs-transparentCount)) $answer $difficulty >> TXSummaryNew.md
    fi   
    # Wait for 10 seconds before checking again
    sleep 5
done