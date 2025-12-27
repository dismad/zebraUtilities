#!/bin/bash

txID="${1}"   #1 represent 1st argument
isDebug="${2}"   #2 represent 1st argument


./toCurl.sh getrawtransaction $txID 1 > txidJSON

txJSON=$(cat txidJSON | jq)

#echo "$txJSON"
#rawTx="$txJSON"

block=$(cat txidJSON | jq .height)


transparent=$(cat txidJSON | jq .vout[].scriptPubKey.type)
transparent=("${transparent[@]}")
transparent2=$(cat txidJSON | jq .vin[].txid | wc -l )
transparent3=$(cat txidJSON | jq .vout[].value)
sprout=$(cat txidJSON | jq .vjoinsplit)
sapling1=$(cat txidJSON | jq .vShieldedSpend)
sapling2=$(cat txidJSON | jq .vShieldedOutput)
orchard1=$(cat txidJSON | jq -r '.orchard.actions | select( . != null )')



# Get Value Out
saplingValueOut=$(cat txidJSON | jq .valueBalance)
orchardValueOut=$(cat txidJSON | jq .orchard.valueBalance)
transparentValueOut=$(cat txidJSON | jq .vout[].valueZat | paste -sd+ | bc)



isCoinbase=$(cat txidJSON | jq .vin[] | grep coinbase)



if [ -n "$isCoinbase" ] && [ "$isCoinbase" != "[]" ];then
        lockbox=$(./toCurl.sh getblocksubsidy | jq .lockboxstreams[].valueZat)
        isCoinbase="IsCoinbase"
else
        lockbox=$(printf '%0f' 0.0)
	#lockbox="0"
fi


if [ ! "$saplingValueOut" ];then
    saplingValueOut="0"
fi

if [ ! "$orchardValueOut" ];then
    orchardValueOut="0"
fi

if [ ! "$transparentValueOut" ];then
    transparentValueOut="0"
fi

#convert zats to ZEC
transparentValueOut=$(bc <<< "scale=8 ; $transparentValueOut/100000000")
lockbox=$(bc <<< "scale=8 ; $lockbox/100000000")



finalSapling=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$saplingValueOut" | bc)
finalOrchard=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$orchardValueOut" | bc)
finalTransparent=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$transparentValueOut" | bc)

#echo "$test | $test2 | $test3 | $lockbox"

# Filter

s1=0 #saplingSpend
s2=0 #saplingOutput
ss=0 #sapling
t1=0 #transparent
c1=0 #sprout
n1=0 #orchard

#result="$block | $txID "

if [[ "$transparent" == *"\"pubkeyhash\""* ]] || [[ "$transparent" == *"\"scripthash\""* ]]; then
    t1=1
fi

if [[ $transparent2 -gt 0 ]]; then
    t1=1
fi

if [[ "$transparent3" > "0" ]]; then
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

#echo "test: $test"
#echo "test2: $test2"
#echo "test3: $test3"
#echo "lockbox: $lockbox"



if [[ t1 -eq 1 ]]; then
   myResult="Transparent"
   valueOut=$( echo "scale=2 ; $finalTransparent + $lockbox" | bc)
   if [[ c1 -eq 1 ]]; then
      myResult="$myResult,Sprout"
      valueOut=$( echo "scale=2 ; $finalSapling + $lockbox" | bc)
   elif [[ ss -eq 1 ]]; then
         myResult="$myResult,Sapling"
         valueOut=$( echo "scale=2 ; $finalSapling + $lockbox" | bc)
         if [[ n1 -eq 1 ]]; then
            myResult="$myResult,Orchard"
            valueOut=$( echo "scale=2 ; $finalSapling + $finalOrchard + $lockbox" | bc)
         fi
   elif [[ n1 -eq 1 ]]; then
        myResult="$myResult,Orchard"
        valueOut=$( echo "scale=2 ; $finalOrchard + $lockbox" | bc)
   else
        :
   fi
elif [[ c1 -eq 1 ]]; then
     myResult="Sprout"
     if [[ ss -eq 1 ]]; then
        myResult="$myResult,Sapling"
        valueOut=$( echo "scale=2 ; $finalSapling + $lockbox" | bc)
     elif [[ n1 -eq 1 ]]; then
           myResult="$myResult,Orchard"
           valueOut=$( echo "scale=2 ; $finalSapling + $finalOrchard + $lockbox" | bc)
     else
        :
     fi
elif [[ ss -eq 1 ]]; then
     myResult="Sapling"
     valueOut=$( echo "scale=2 ; $finalSapling + $lockbox" | bc)
     if [[ n1 -eq 1 ]]; then
        myResult="$myResult,Orchard"
        valueOut=$( echo "scale=2 ; $finalSapling + $finalOrchard + $lockbox" | bc)
     fi
elif [[ n1 -eq 1 ]]; then
     myResult="Orchard"
     valueOut=$( echo "scale=2 ; $finalOrchard + $lockbox" | bc)
else
    :
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
LIGHTGRAY='\033[0;37m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
WHITE='\033[1;37m'



if [ "$isDebug" == "true" ]; then
    fee="Fee n/a"
else
    fee=$(./getTXfeeII.sh $txID)
fi

# Get transferTX count
t=$(cat txidJSON | jq -r '.vout | length' | paste -sd+ | bc)
o=$(cat txidJSON | jq .orchard | jq -r '.actions | length' | paste -sd+ | bc)
s=$(cat txidJSON | jq -r ' .vShieldedOutput | length ' | paste -sd+ | bc)

myTransferCount=$(echo "$t + $o + $s" | bc)


# Get date/time
isInMempool=$(./inMempool.sh $txID)
if [[ "$isInMempool" -eq 1 ]] ;then

	testTime="In mempool"
else
        now=$(cat txidJSON | jq .time)
        testTime=$(date -d @$now +%c)
fi

#Find length of vars to adjust for even pad spacing
mypad=$(./normalizePadding.sh 16 $valueOut)
mypad2=$(./normalizePadding.sh 16 $finalTransparent)
mypad3=$(./normalizePadding.sh 4 $myTransferCount)
mypad4=$(./normalizePadding.sh 16 $finalSapling)
mypad5=$(./normalizePadding.sh 16 $finalOrchard)
mypad6=$(./normalizePadding.sh 12 $fee)
mypad7=$(./normalizePadding.sh 10 $lockbox)
mypad8=$(./normalizePadding.sh 27 $myResult)



if [ "$isDebug" == "true" ]; then

	echo -e "$testTime | $block | $txID | $myTransferCount$mypad3 | $fee | $finalTransparent$mypad2 | $finalSapling$mypad4  | $finalOrchard$mypad5  | $myResult | $isCoinbase"
else 
	echo -e "${LIGHTRED}$testTime${NC} | ${CYAN}$block${NC} | ${GREEN}$txID${NC} | ${YELLOW}$myTransferCount${NC}$mypad3 | ${RED}$fee${NC}$mypad6 | ${LIGHTPURPLE}$lockbox${NC}$mypad7 | ${WHITE}$finalTransparent$mypad2${NC} | ${LIGHTGREEN}$finalSapling$mypad4${NC} | ${LIGHTGRAY}$finalOrchard$mypad5${NC} | ${LIGHTBLUE}$myResult$mypad8${NC} | ${ORANGE}$isCoinbase${NC}"
fi

rm txidJSON
