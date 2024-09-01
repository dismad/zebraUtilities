#!/bin/bash

peers=$(zcash-cli getpeerinfo | jq .[].addr | tr -d '"' | wc -l)

echo
echo "-------------------------------------------"
echo "$(zcash-cli getpeerinfo | jq .[].addr | tr -d '"')"
echo "-------------------------------------------"
echo
echo "Your Zebrad node has $peers ip's connected."
echo