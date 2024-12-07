#!/bin/bash

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#RED='\033[0;31m'
#NC='\033[0m' # No Color
#echo -e "I ${RED}love${NC} Zcash"

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DARKGRAY='\033[1;30m'
BLUE='\033[0;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTBLUE='\033[1;34m'
ORANGE='\033[0;33m'


current_block=$(./toCurl.sh getblockcount | jq .result)
now=$(./toCurl.sh getblockcount | jq .result | xargs ./toCurl.sh getblock | jq .result.time)
difficulty=$(./toCurl.sh getdifficulty | jq .result)

while true
do
    # Get latest block count
    latest_block=$(./toCurl.sh getbestblockhash | jq .result | xargs ./toCurl.sh getblock | jq .result.height)
    
    # Check if latest block is greater than current block
    if [ "$latest_block" -gt "$current_block" ]
    then
	# Check for current Difficulty
        difficulty=$(./toCurl.sh getdifficulty | jq .result)

	# Record Time
        newBlockTime=$(date +%s)
	newBlockTime=$(./toCurl.sh getblock $latest_block | jq .result.time)

        #calculate difference.
        difference=$(( $newBlockTime - $now ))

        # Divide the difference by 3600 to calculate hours/ 60 for minutes
        answer=$(bc <<< "scale=2 ; $difference/60")0
        testTime=$(date +%R)

        echo
        echo -e "${YELLOW}New block found!${NC}"
        ./drawBlock.sh "Block $latest_block"
        echo -e "[$answer minutes since last block ($testTime)] (${RED}Difficulty${NC}: ${DARKGRAY}$difficulty${NC})"
        echo "----------------"

	# List transaction ID's
        echo
	echo "Block $latest_block has $(./listBlockTXs.sh $latest_block | wc -l) transactions: "
	echo
	./listBlockTXs.sh $latest_block
        echo
        
        # Reset Time
        now=$newBlockTime

	# loop through TX's of block
        index=$(./listBlockTXs.sh $latest_block | wc -l) 
	numTXs=$(./listBlockTXs.sh $latest_block | wc -l)
	#transparentCount=0
        #actionCount=0
        #sizeCount=0
        #arrayIndex=0
        #blockSize=$(zcash-cli getblockcount | xargs zcash-cli getblock | jq .size)

        # Count number of inputs/outputs
        #outputs=$(./listBlockTXs.sh $latest_block | xargs -n1 ./txDetailsZebra.sh | jq .vout.[].n | wc -l)
	#inputs=$(./listBlockTXs.sh $latest_block | xargs -n1 ./txDetailsZebra.sh | jq .vin.[].txid | wc -l)

        # loop through TX's of block
	#while [[ index -ge 1 ]]
	#do
	    # Count size of tx's
            #size=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"]  | xargs -n1 ./txDetailsZebra.sh | jq .size)
            #sizeCount=$(($sizeCount + $size))

            # Count number of Orchard Actions
            #actions=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"] | xargs -n1 ./txDetailsZebra.sh | jq .orchard.actions | jq -r 'length')
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
	echo -e "${LIGHTPURPLE}This block has ${LIGHTBLUE}$numTXs${NC} transactions${NC}" #of which $shieldedCount are shielded${NC}"


        #echo "This block has $actionCount orchard actions."
	#echo "This block has $inputs total inputs."
	#echo "This block has $outputs total outputs."

        current_block=$latest_block
        #echo $current_block $numTXs $transparentCount $((numTXs-transparentCount)) $answer $difficulty >> TXSummaryNew.md
    fi   
    # Wait for 1 seconds before checking again
    sleep 1
done
