#!/bin/bash

peers=$(./toCurl.sh getpeerinfo | jq .[].addr | tr -d '"' | wc -l)

echo
echo "-------------------------------------------"
echo "$(./toCurl.sh getpeerinfo | jq .[].addr | tr -d '"')"
echo "-------------------------------------------"
echo
echo "Your Zebrad node has $peers ip's connected."
echo
