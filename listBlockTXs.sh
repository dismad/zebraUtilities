#!/bin/bash

block="${1}"   #1 represent 1st argument

./toCurl.sh getblock $block | jq .result.tx | jq 'reverse'[]
