#!/bin/bash

txID="${1}"   #1 represent 1st argument
block="${2}"   #2 represent 1st argument



if [ -z "$block" ]; then
	block=$(./txDetails.sh $txID | jq .height)
    	rawTx=$(./toCurl.sh getrawtransaction $txID 1)
else 
	blockHash=$(./toCurl.sh getblockhash $block)
	rawTx=$(./toCurl.sh getrawtransaction $txID 1 $blockHash)
fi


rawTx=$(./toCurl.sh getrawtransaction $txID 1)

transparent=$(echo $rawTx | jq .vout[].scriptPubKey.type)
transparent=("${transparent[@]}")

transparent2=$(echo $rawTx | jq .vin[].txid | wc -l )

sprout=$(echo $rawTx | jq .vjoinsplit)
sapling1=$(echo $rawTx | jq .vShieldedSpend)
sapling2=$(echo $rawTx | jq .vShieldedOutput)
orchard1=$(echo $rawTx | jq -r '.orchard.actions | select( . != null )')



# Get Value Out
valueOut1=$(echo $rawTx | jq .valueBalance)
valueOut2=$(echo $rawTx | jq .orchard.valueBalance)
valueOut3=$(echo $rawTx | jq .vout[].valueZat | paste -sd+ | bc)



isCoinbase=$(./txDetails.sh $txID | jq .vin[] | grep coinbase)



if [ -n "$isCoinbase" ] && [ "$isCoinbase" != "[]" ];then
        lockbox=$(./toCurl.sh getblocksubsidy | jq .lockboxstreams[].valueZat)
else
	lockbox="0"
fi


if [ ! "$valueOut1" ];then
    valueOut1="0"
fi

if [ ! "$valueOut2" ];then
    valueOut2="0"
fi

if [ ! "$valueOut3" ];then
    valueOut3="0"
fi

#convert zats to ZEC
valueOut3=$(bc <<< "scale=8 ; $valueOut3/100000000")
lockbox=$(bc <<< "scale=8 ; $lockbox/100000000")



test=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$valueOut1" | bc)
test2=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$valueOut2" | bc)
test3=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$valueOut3" | bc)



# Filter
s1=0 #saplingSpend
s2=0 #saplingOutput
ss=0 #sapling
t1=0 #transparent
c1=0 #sprout
n1=0 #orchard


if [[ "$transparent" == *"\"pubkeyhash\""* ]] || [[ "$transparent" == *"\"scripthash\""* ]]; then
    t1=1
fi

if [[ transparent2 -gt 0 ]]; then
    t1=1
fi

if [[ "$sprout" == "null" ]] || [[ "$sprout" == "[]" ]]; then
    :
else
    c1=1
fi

if [[ -z "$sapling1" ]] || [[ "$sapling1" == "[]" ]]; then
    s1=0
else
    s1=1
    #echo "Sapling Spend tx"
fi

if [[ -z "$sapling2" ]] || [[ "$sapling2" == "[]" ]]; then
    s2=0
else
    s2=1
    #echo "Sapling Output tx"
fi

if [[ s1 -gt 0 ||  s2 -gt 0 ]]; then
    ss=1
else
    :
fi

if [[ -z "$orchard1" ]] || [[ "$orchard1" == "[]" ]]; then
    :
else
    n1=1
fi

myResult=""



if [[ t1 -eq 1 ]]; then
   myResult="Transparent"
   valueOut=$( echo "scale=2 ; $test3 + $lockbox" | bc)
   if [[ c1 -eq 1 ]]; then
      myResult="$myResult,Sprout"
      valueOut=$( echo "scale=2 ; $test + $lockbox" | bc)
   elif [[ ss -eq 1 ]]; then
         myResult="$myResult,Sapling"
         valueOut=$( echo "scale=2 ; $test + $lockbox" | bc)
         if [[ n1 -eq 1 ]]; then
            myResult="$myResult,Orchard"
            valueOut=$( echo "scale=2 ; $test + $test2 + $lockbox" | bc)
         fi
   elif [[ n1 -eq 1 ]]; then
        myResult="$myResult,Orchard"
        valueOut=$( echo "scale=2 ; $test2 + $lockbox" | bc)
   else
        :
   fi
elif [[ c1 -eq 1 ]]; then
     myResult="Sprout"
     if [[ ss -eq 1 ]]; then
        myResult="$myResult,Sapling"
        valueOut=$( echo "scale=2 ; $test + $lockbox" | bc)
     elif [[ n1 -eq 1 ]]; then
           myResult="$myResult,Orchard"
           valueOut=$( echo "scale=2 ; $test + $test2 + $lockbox" | bc)
     else
        :
     fi
elif [[ ss -eq 1 ]]; then
     myResult="Sapling"
     valueOut=$( echo "scale=2 ; $test + $lockbox" | bc)
     if [[ n1 -eq 1 ]]; then
        myResult="$myResult,Orchard"
        valueOut=$( echo "scale=2 ; $test + $test2 + $lockbox" | bc)
     fi
elif [[ n1 -eq 1 ]]; then
     myResult="Orchard"
     valueOut=$( echo "scale=2 ; $test2 + $lockbox" | bc)
else
    :
fi


#Find length of valueOut to adjust for even pad spacing
padding=15
len=${#valueOut}
test=$(( $padding - $len ))
mypad=""
while [[ $test -gt 0 ]]
do
    mypad="$mypad "
    test=$(( $test -1 ))
done


# Get Fee
fee=$(./getTXfee.sh $txID)

# Get transferTX count
t=$(./txDetails.sh $txID | jq -r '.vout | length' | paste -sd+ | bc)
o=$(./txDetails.sh $txID | jq .orchard | jq -r '.actions | length' | paste -sd+ | bc)
s=$(./txDetails.sh $txID | jq -r ' .vShieldedOutput | length ' | paste -sd+ | bc)

myTransferCount=$(echo "$t + $o + $s" | bc)

#Find Length of Fee to adjust for even pad spacing
padding2=15
len=${#fee}
test2=$(( $padding2 - $len ))
mypad2=""
while [[ $test2 -gt 0 ]]
do
    mypad2="$mypad2 "
    test2=$(( $test2 -1 ))
done


#Find Length of TransferCounts for even pad spacing
padding3=4
len=${#myTransferCount}
test3=$(( $padding3 - $len ))
mypad3=""

while [[ $test3 -gt 0 ]]
do
	mypad3="$mypad3 "
	test3=$(( $test3 -1 ))
done



# Get date/time
isZebra=$(./toCurl.sh getinfo | jq .subversion | grep -o Zebra)

if [[ "$isZebra" == "Zebra" ]];
then
	#if in mempool
        isInMempool=$(./inMempool.sh $txID)
	if [[ "$isInMempool" -eq 1 ]] ;then

		testTime="In mempool"
	else
                now=$(echo $rawTx | jq .height | xargs -n1 ./toCurl.sh getblock | jq .time)
                testTime=$(date -d @$now +%c)
	fi
else
	#zcashd case
	now=$(echo $rawTx | jq .time)
        testTime=$(date -d @$now +%c)
fi

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
CYAN='\033[0;36m'
LIGHTGREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTRED='\033[1;31m'
YELLOW='\033[1;33m'


echo -e "${LIGHTRED}$testTime${NC} | ${CYAN}$block${NC} | ${GREEN}$txID${NC} | ${YELLOW}$myTransferCount${NC}$mypad3 | ${RED}$fee${NC}$mypad2 | ${LIGHTPURPLE}$valueOut${NC}$mypad | ${LIGHTBLUE}$myResult${NC}"
