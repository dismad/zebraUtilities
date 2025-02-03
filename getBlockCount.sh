#!/bin/bash

./toCurl.sh getblockchaininfo | jq .result.blocks
