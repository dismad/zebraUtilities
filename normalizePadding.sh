#!/bin/bash

padding="${1}"   #1 represent 1st argument
myvar="${2}"   #2 represent 1st argument


len=${#myvar}
diff=$(( $padding - $len ))
result=""

while [[ $diff -gt 0 ]]
do

    result="$result "
    diff=$(( $diff -1 ))
done

echo -e "$result"

