#!/bin/bash

./toCurl.sh getblockchaininfo | jq .blocks
