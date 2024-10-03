#!/bin/bash

txID="${1}"   #1 represent 1st argument

rawTx=$(zcash-cli getrawtransaction $txID 1)
isZebra=$(zcash-cli getinfo | jq .subversion | grep -o Zebra)
result=""

if [ "$isZebra" = "Zebra" ];then
	myBlock=$(echo "$rawTx" | jq .height)
	result=$(zcash-cli z_gettreestate $myBlock | jq .time | xargs -i date -d @"{}")
        echo "$result"
else
	./txDetails.sh $txID | jq .time | xargs -i date -d @"{}"
fi
