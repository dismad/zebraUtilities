#!/bin/bash

block="${1}"

./toCurl.sh getblock $block | jq .tx[0]


