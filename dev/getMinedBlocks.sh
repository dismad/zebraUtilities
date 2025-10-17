#!/bin/bash

mymineraddress="${1}"   #1 represent 1st argument

minedBlockCount=$(cat /home/zkhb/.local/state/zebrad.log | grep "sending mined block broadcast" | wc -l)

echo
echo "Since zebrad has be started, you have tried to mine $minedBlockCount blocks!"
echo
echo "Here are some details:"
echo
echo "Finding blocks in logs:"
echo

sleep 3s

cat /home/zkhb/.local/state/zebrad.log | grep "sending mined block broadcast" | grep 'Height\([0-9]+' -Eo | grep '[0-9]+' -Eo | column


echo
echo "Looking on chain for miner details for the blocks above:"
echo

sleep 3s

echo "#  |  Taddrs"
echo "-------------------------------------"
cat /home/zkhb/.local/state/zebrad.log | grep "sending mined block broadcast" | grep 'Height\([0-9]+' -Eo | grep '[0-9]+' -Eo | xargs -n1 ./listBlockTXs.sh | xargs -n1 ./txDetails.sh | jq '.vout[0].scriptPubKey.addresses[0] | select( . != null )' | sort | uniq -c | sort -n | column -t


finalNum=$(cat /home/zkhb/.local/state/zebrad.log | grep "sending mined block broadcast" | grep 'Height\([0-9]+' -Eo | grep '[0-9]+' -Eo | xargs -n1 ./listBlockTXs.sh | xargs -n1 ./txDetails.sh | jq '.vout[0].scriptPubKey.addresses[0] | select( . != null )' | sort | uniq -c | sort -n | column -t | grep $mymineraddress | cut -d "\"" -f1 | grep '[0-9]+' -Eo)


echo
echo "$mymineraddress tried to mine $minedBlockCount but only $finalNum mined blocks confirmed successfully!"
echo 
echo "Digging deeper..."
echo
echo "Taddrs                              | Amounts              | Number of txids"
echo "----------------------------------------------------------------------------"
cat /home/zkhb/.local/state/zebrad.log | grep "sending mined block broadcast" | grep 'Height\([0-9]+' -Eo | grep '[0-9]+' -Eo | xargs -n1 ./listBlockTXs.sh | xargs -n1 ./txDetails.sh | jq '.vout[0].scriptPubKey.addresses[0] | select( . != null )' | sort | uniq -c | sort -n | awk '{ print $2}' | jq -r | xargs -n1 ./getTaddrSummary.sh
echo
echo
echo "done."





