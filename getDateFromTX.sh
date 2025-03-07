#!/bin/bash

txID="${1}"   #1 represent 1st argument

rawTx=$(./toCurl.sh getrawtransaction $txID 1 | jq .result)
isZebra=$(./toCurl.sh getinfo | jq .result.subversion | grep -o Zebra)
result=""

if [ "$isZebra" = "Zebra" ];then
        myBlock=$(echo "$rawTx" | jq .height)
        result=$(./toCurl.sh getblock $myBlock | jq .result.time | xargs -i date -d @"{}")
        echo "$result"
else
        ./txDetailsZebra.sh $txID | jq .time | xargs -i date -d @"{}"
fi

