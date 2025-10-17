#!/bin/bash

./toCurl.sh getbestblockhash | xargs ./toCurl.sh getblock | jq .height