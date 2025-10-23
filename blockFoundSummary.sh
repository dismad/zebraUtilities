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


current_block=$(./toCurl.sh getbestblockhash | xargs ./toCurl.sh getblock | jq .height)
now=$(./toCurl.sh getblock $current_block | jq .time)
difficulty=$(./toCurl.sh getblock $current_block | jq .difficulty)

while true
do
    # Get latest block count
    latest_block=$(./toCurl.sh getbestblockhash | xargs ./toCurl.sh getblock | jq .height)
    
    # Check if latest block is greater than current block
    if [ "$latest_block" -gt "$current_block" ]
    then
	# Check for current Difficulty
        difficulty=$(./toCurl.sh getblock $latest_block | jq .difficulty)

	# Record Time
    #newBlockTime=$(date +%s)
	newBlockTime=$(./toCurl.sh getblock $latest_block | jq .time)

    #calculate difference.
    difference=$(( $newBlockTime - $now ))

    # Divide the difference by 3600 to calculate hours/ 60 for minutes
    answer=$(bc <<< "scale=2 ; $difference/60")
    testTime=$(date +%R)  
    blockSize=$(./toCurl.sh getblockcount | xargs -I {} echo {} 2 | xargs ./toCurl.sh getblock | jq .size)
    #blockSize=$(./toCurl.sh getblockcount | xargs ./toCurl.sh getblock | jq .size)

    # Display message with new block number
    echo
    echo -e "${YELLOW}New block found!${NC}"
    ./drawBlock.sh "Block $latest_block: $blockSize bytes"
	echo -e "[$answer minutes since last block ($testTime)] (${RED}Difficulty${NC}: ${DARKGRAY}$difficulty${NC})"
	echo "----------------"
	# List transaction ID's
    echo
	echo "Block $latest_block has $(./listBlockTXs.sh $latest_block | wc -l) transactions: "
	echo
	./listBlockTXs.sh $latest_block | xargs -n1 ./tx_type.sh
    echo
        
    # Reset Time
    now=$newBlockTime

	# loop through TX's of block
    index=$(./listBlockTXs.sh $latest_block | wc -l) 
	numTXs=$(./listBlockTXs.sh $latest_block | wc -l)
	transparentCount=0
    shieldedCount=0
    actionCount=0
    sizeCount=0
    arrayIndex=0

    # Count number of inputs/outputs
    outputs=$(./listBlockTXs.sh $latest_block | xargs -n1 ./txDetails.sh | jq .vout[].n | wc -l)
	inputs=$(./listBlockTXs.sh $latest_block | xargs -n1 ./txDetails.sh | jq .vin[].txid | wc -l)

    # loop through TX's of block
	while [[ index -ge 1 ]]
	do
	    # Count size of tx's
        size=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"]  | xargs -n1 ./txDetails.sh | jq .size)
        sizeCount=$(($sizeCount + $size))

        # Count number of Orchard Actions
        actions=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"] | xargs -n1 ./txDetails.sh | jq .orchard.actions | jq -r 'length')
        actionCount=$(($actionCount + $actions))

        # Get Type of TX's
	    temp=$(./listBlockTXs.sh $latest_block | jq -s .["$arrayIndex"] | xargs -n1 ./tx_type.sh)
	    
	    isSprout=$(echo $temp | grep -o Sprout)
        isSapling=$(echo $temp | grep -o Sapling)
        isOrchard=$(echo $temp | grep -o Orchard)

        if [[ "$isSprout" == "Sprout" ]]; then
            	shieldedCount=$(( $shieldedCount + 1 ))
        elif [[ "$isSapling" == "Sapling" ]]; then
                shieldedCount=$(( $shieldedCount + 1 )) 
        elif [[ "$isOrchard" == "Orchard" ]]; then
                shieldedCount=$(( $shieldedCount + 1 ))
        else
               :  #shieldedCount=$(( $shieldedCount + 1 ))
        fi
        arrayIndex=$(( $arrayIndex + 1 ))
        index=$(( $index - 1 ))
	done  

    headerSize=$(($blockSize-$sizeCount))

    #./drawBlock.sh "$blockSize bytes"
    totalFee=$(./listBestBlockTXs.sh | xargs -n1 ./tx_type.sh | awk '{ print $15}' | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g'| paste -sd+ | bc)

    echo -e "${ORANGE}[(Header: $headerSize + TXs: $sizeCount) bytes]${NC} | ${RED}$totalFee zats in fees.${NC}"
    echo "----------------"
	echo -e "${LIGHTPURPLE}This block has ${LIGHTBLUE}$numTXs${NC} transactions of which $shieldedCount are shielded${NC}"
    echo -e "${LIGHTPURPLE}This block has ${LIGHTBLUE}$actionCount${NC} orchard actions.${NC}"
	echo -e "${LIGHTPURPLE}This block has ${LIGHTBLUE}$inputs${NC} total inputs.${NC}"
	echo -e "${LIGHTPURPLE}This block has ${LIGHTBLUE}$outputs${NC} total outputs.${NC}"
    echo
	echo "waiting..."
        current_block=$latest_block
        #echo $current_block $numTXs $transparentCount $shieldedCount $temp $answer $difficulty >> TXSummaryNew.md
    fi   
    # Wait for 1 seconds before checking again
    sleep 1
done
