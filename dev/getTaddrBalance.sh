#!/bin/bash

taddr="${1}"    #1 represent 1st argument

formattedInput="'{\"addresses\": [\"$taddr\"]}'"


result=$(echo $formattedInput | xargs ./toCurl.sh getaddressbalance | jq .balance)
result=$(echo "scale=2; $result / 100000000" | bc)



#Find length of valueOut to adjust for even pad spacing
padding=15
len=${#result}
test=$(( $padding - $len ))
mypad=""
while [[ $test -gt 0 ]]
do
    mypad="$mypad "
    test=$(( $test -1 ))
done


#echo "$taddr: $result ZEC"
echo "$result$mypad ZEC"
