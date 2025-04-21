#!/bin/bash

txID="${1}"    #1 represent 1st argument
isShieldedOut=0
isShieldedIn=0


#Check for Orchard
isOrchard=$(./txDetails.sh $txID | jq .orchard)
lenO=${#isOrchard}

#Check for Sapling
isSaplingSpend=$(./txDetails.sh $txID | jq .vShieldedSpend)
isSaplingOutput=$(./txDetails.sh $txID | jq .vShieldedOutput)
isSapling=0

if [[ -z "$isSaplingSpend" ]] || [[ "$isSaplingSpend" == "[]" ]]; then
    #no Sapling Spend
    isSapling=0
else
    isSapling=1
    #echo "Sapling Spend tx"
fi

if [[ -z "$isSaplingOutput" ]] || [[ "$isSaplingOutput" == "[]" ]]; then
    #no Sapling Output
    isSapling=0
else
    isSapling=1
    #echo "Sapling Output tx"
fi

#Check for Sprout
isSprout=$(./txDetails.sh $txID | jq .vjoinsplit)
lenS=${#isSprout}

if [[ "$lenS" -gt 4 ]] ;then
    isShieldedOut=1
fi

#Check vouts
nullCheck=$(./txDetails.sh $txID | jq .vout.[])
if [[ -n "$nullCheck" ]] && [[ "$nullCheck" != "" ]];then
    #Case were tx has both vins and outs
    if [[ $isSapling -eq 1 ]];then
       isShieldedOut=1
    fi
    voutSum=$(./txDetails.sh $txID | jq -r '.vout | .[] | .valueZat' | awk '{s+=$1} END {print s}')
    #If coinbase, add lockbox portion see line 63
else
   isShieldedOut=1
fi

#Check vins
nullCheck=$(./txDetails.sh $txID | jq .vin)

if [[ -n "$nullCheck" ]] && [[ "$nullCheck" != "" ]];then
    isCoinbase=$(./txDetails.sh $txID | jq .vin.[] | grep -o coinbase)
    if [[ "$isCoinbase" = "coinbase" ]];then
    	vinSum=$(./toCurl.sh getblocksubsidy | jq .totalblocksubsidy)
    	vinSum=$(echo "($vinSum * 100000000)/1" | bc)
        lockbox=$(./toCurl.sh getblocksubsidy | jq .lockboxstreams.[].valueZat)
        voutSum=$(echo "$voutSum + $lockbox" | bc )
    else
        if [[ "$nullCheck" == "[]" ]];then
           isShieldedIn=1
        else
           #loop through vins
           length=$(./txDetails.sh $txID | jq -r '.vin | length')
           index=0
           if [ -f temp.md ]; then
    		rm temp.md
	   fi

	   while [[ "$index" -lt "$length" ]]
		   do
		   	tempIndex=$(./txDetails.sh $txID | jq .vin.[$index].vout)
		   	vinSum=$(./txDetails.sh $txID | jq .vin.[$index].txid | xargs -n1 ./txDetails.sh | jq .vout.[$tempIndex].valueZat)
		        echo $vinSum >> temp.md #| awk '{s+=$1} END {print s}')
		        index=$((($index + 1)))
		   done
           
           vinSum=$(cat temp.md | awk '{s+=$1} END {print s}')
        fi
    fi
else
    isShieldedIn=1
fi

# If Shielded, update Sums based on type of Shielding
outValueBalance=0 #voutSum
inValueBalance=0  #vinSum

#Check voutSum first
#echo $isShieldedOut
if [[ "$isShieldedOut" -eq 1 ]];then
    if [[ "$lenS" -gt 4 ]];then
       echo "here"
       outValueBalance=$(./txDetails.sh $txID | jq .vjoinsplit.[].vpub_newZat | awk '{s+=$1} END {print s}')
    elif [[ "$isSapling" -eq 1 ]];then
        outValueBalance=$(./txDetails.sh $txID | jq .valueBalanceZat)
    elif [[ -n "$isOrchard" ]] && [[ "$lenO" -gt 4 ]];then
        outValueBalance=$(./txDetails.sh $txID | jq .orchard.valueBalanceZat)    
    else
        echo "debug"
    fi
    outValueBalance=$(echo "$outValueBalance * -1" | bc) 
fi

#Check vinSum second
if [[ "$isShieldedIn" -eq 1 ]];then
   #if [ "$lenS" -gt 2 ];then
   #   vinSum=$(./txDetails.sh $txID | jq .vjoinsplit.[].vpub_newZat)
   if [[ "$isSapling" -eq 1 ]];then
       inValueBalance=$(./txDetails.sh $txID | jq .valueBalanceZat)
   elif [[ -n "$isOrchard" ]] && [[ "$lenO" -gt 4 ]];then
       inValueBalance=$(./txDetails.sh $txID | jq .orchard.valueBalanceZat)    
   else
       echo "debug"
   fi
fi

if [[ "$isSapling" -eq 0 ]] && [[ -z $vinSum ]];then
    if [[ $inValueBalance -lt 0 ]];then
        inValueBalance=0
    fi
    #finalIn=$inValueBalance
elif [[ "$isSapling" -eq 1 ]];then
    if [[ $inValueBalance -lt 0 ]];then
        inValueBalance=0
    fi 
fi

if [[ "$isSapling" -eq 0 ]] && [[ -z "$voutSum" ]];then
    if [[ "$outValueBalance" -lt 0 ]];then
        outValueBalance=0
    fi
    #finalOut=$outValueBalance
elif [[ "$isSapling" -eq 1 ]];then
    if [[ "$outValueBalance" -lt 0 ]];then
        outValueBalance=0
    fi 
fi



#echo "vinSum: $vinSum"
#echo "inValueBalance: $inValueBalance"

#echo "voutSum: $voutSum"
#echo "outValueBalance: $outValueBalance"
 
#finalOut=$(echo "$voutSum + $outValueBalance" | bc )
#finalIn=$(echo "$vinSum + $inValueBalance" | bc )

finalOut=$((( $voutSum + $outValueBalance )))
finalIn=$((( $vinSum + $inValueBalance )))


#if Coinbase tx, swap signs 
if [[ "$isCoinbase" == "coinbase" ]];then
	fee=$(echo "$finalOut - $finalIn"| bc)
else
	fee=$(echo "$finalIn - $finalOut"| bc)
fi


finalOut=$(echo "scale=2; $finalOut / 100000000" | bc)
finalIn=$(echo "scale=2; $finalIn / 100000000" | bc)

#echo "In  : $vinSum ZEC"
#echo "Out : $voutSum ZEC"
#echo "-------------------"
echo "$fee Zats"

