#!/bin/bash

txID="${1}"   #1 represent 1st argument
block="${2}"   #2 represent 1st argument
alias2="${3}"   #3 represents 2nd argument

if [[ -z $block ]]
then
    rawTx=$(./toCurl.sh getrawtransaction $txID 1 | jq .result)

else
    blockHash=$(./toCurl.sh getblockhash $block | jq .result)
    rawTx=$(./toCurl.sh getrawtransaction $txID 1 $blockHash | jq .result)

fi

myBlock=$(echo "$rawTx" | jq .height)

echo
echo "Your transaction is included in block $myBlock"
echo
echo "Here are the block details: "
echo
result=$(echo "$myBlock" | xargs ./toCurl.sh getblock | jq .result)
echo $result | jq .

