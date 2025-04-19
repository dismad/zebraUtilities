#!/bin/bash

txID="${1}"    #1 represent 1st argument
block="${2}"   #2 represent 2nd argument
alias="${3}"   #3 represents 3rd argument
command="${4}" #4 4th

if [[ -z $block ]]
then
    rawTx=$(./toCurl.sh getrawtransaction $txID 1)
else
    blockHash=$(./toCurl.sh getblockhash $block)
    rawTx=$(./toCurl.sh getrawtransaction $txID 1 $blockHash)
fi


echo $rawTx | jq 



