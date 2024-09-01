#!/bin/bash

txID="${1}"   #1 represent 1st argument
block="${2}"   #2 represent 1st argument
alias2="${3}"   #3 represents 2nd argument

if [[ -z $block ]]
then
    rawTx=$(zcash-cli getrawtransaction $txID 1)
else
    blockHash=$(zcash-cli getblockhash $block)
    rawTx=$(zcash-cli getrawtransaction $txID 1 $blockHash)
fi

myBlock=$(echo "$rawTx" | jq .height)

echo
echo "Your transaction is included in block $myBlock"
echo
echo "Here are the block details: "
echo
result=$(echo "$myBlock" | xargs zcash-cli getblock)
echo $result | jq .
echo

echo "Here is your transaction: "
echo
echo $rawTx | jq .
