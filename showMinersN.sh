#!/bin/bash
#
# show-miners-last-n.sh
# List miner name (from coinbase) for each of the last N blocks
#
set -euo pipefail

RPC_URL="${ZEBRA_RPC_URL:-http://127.0.0.1:18232}"

if [ -t 1 ]; then
    ANON_LABEL=$'\033[38;5;99m▛\033[38;5;141m▜\033[0m \033[38;5;245manon\033[0m'
    ZEBRA_LABEL=$'\033[38;5;255m🦓\033[0m \033[38;5;245mzebra\033[0m'
else
    ANON_LABEL="anon"
    ZEBRA_LABEL="zebra"
fi

# Zebra RPC cookie auth support (Zebra >= 2.0.0)
COOKIE_FILE="${ZEBRA_COOKIE_FILE:-/var/lib/zebrad-rpc/.cookie}"
if [ -z "${ZEBRA_COOKIE_FILE:-}" ] && [ ! -f "$COOKIE_FILE" ]; then
    for d in \
        "${XDG_CACHE_HOME:-$HOME/.cache}/zebra" \
        "$HOME/.cache/zebra" \
        "${XDG_STATE_HOME:-$HOME/.local/state}/zebra" \
        "$HOME/.local/share/zebra" \
        "$HOME/.zebra"; do
        if [ -f "$d/.cookie" ]; then
            COOKIE_FILE="$d/.cookie"
            break
        fi
    done
fi

if [ -n "$COOKIE_FILE" ] && [ ! -f "$COOKIE_FILE" ]; then
    if [ -n "${ZEBRA_COOKIE_FILE:-}" ]; then
        echo "Error: ZEBRA_COOKIE_FILE set but not found: $COOKIE_FILE" >&2
        exit 1
    else
        COOKIE_FILE=""
    fi
elif [ -n "$COOKIE_FILE" ]; then
    echo "Using RPC cookie: $COOKIE_FILE"
fi

rpc_call() {
    local method="$1"
    shift
    local params_json
    if [ $# -eq 0 ]; then
        params_json="[]"
    else
        params_json=$(printf '%s\n' "$@" | jq -R '
            if test("^-?[0-9]+(\\.[0-9]+)?$") then tonumber else . end
        ' | jq -s .)
    fi

    local auth_args=()
    if [ -n "$COOKIE_FILE" ] && [ -f "$COOKIE_FILE" ]; then
        auth_args=( --user "$(cat "$COOKIE_FILE")" )
    fi

    local response
    response=$(jq -n \
        --arg method "$method" \
        --argjson params "$params_json" \
        '{jsonrpc: "2.0", id: 1, method: $method, params: $params}' \
    | curl -sS \
        --connect-timeout 5 \
        --max-time 30 \
        -H "Content-Type: application/json" \
        --data-binary @- \
        "${auth_args[@]}" \
        "$RPC_URL") || {
        echo "Error: curl failed talking to $RPC_URL" >&2
        exit 1
    }
    echo "$response"
}

extract_miner() {
    local hex="$1"
    if [ -z "$hex" ]; then
        echo "<no coinbase>"
        return
    fi

    hex=$(printf '%s' "$hex" | tr -cd '0-9a-fA-F')
    if [ -z "$hex" ]; then
        echo "<no coinbase>"
        return
    fi
    if (( ${#hex} % 2 == 1 )); then
        hex="${hex}0"
    fi

    local hex_lc="${hex,,}"

    hex_to_raw() {
        printf '%s' "$1" | xxd -r -p 2>/dev/null | tr -d '\0' || true
    }

    trim() {
        local s="$1"
        s="${s#"${s%%[![:space:]]*}"}"
        s="${s%"${s##*[![:space:]]}"}"
        printf '%s' "$s"
    }

    # Zebra marker 🦓 = f09fa693
    if [[ "$hex_lc" == *f09fa693* ]]; then
        local after="${hex_lc#*f09fa693}"
        if [[ "$after" == 3a20* ]]; then
            after="${after:4}"
        fi
        if [ -z "$after" ]; then
            echo "<zebra>"
            return
        fi
        local ztag
        ztag=$(trim "$(hex_to_raw "$after")")
        if [ -n "$ztag" ]; then
            printf '%s\n' "$ztag"
        else
            echo "<zebra>"
        fi
        return
    fi

    local -a bytes=()
    local i
    for (( i=0; i<${#hex_lc}; i+=2 )); do
        bytes+=( "$((16#${hex_lc:i:2}))" )
    done

    local start=0
    if (( ${#bytes[@]} > 0 )); then
        local n=${bytes[0]}
        if (( n >= 1 && n <= 8 && 1 + n <= ${#bytes[@]} )); then
            start=$((1 + n))
        elif (( n >= 81 && n <= 96 )); then
            start=1
        fi
    fi

    local -a chunks=()
    local cur=""
    local j c
    for (( j=start; j<${#bytes[@]}; j++ )); do
        c=${bytes[j]}
        if (( (c >= 32 && c <= 126) || c >= 128 )); then
            printf -v cur '%s%02x' "$cur" "$c"
        elif [ -n "$cur" ]; then
            chunks+=( "$cur" )
            cur=""
        fi
    done
    [ -n "$cur" ] && chunks+=( "$cur" )

    local last="" chunk decoded filtered k pair val
    for chunk in "${chunks[@]}"; do
        decoded=$(hex_to_raw "$chunk")
        if ! printf '%s' "$decoded" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1; then
            filtered=""
            for (( k=0; k<${#chunk}; k+=2 )); do
                pair=${chunk:k:2}
                val=$((16#$pair))
                if (( val >= 32 && val <= 126 )); then
                    filtered+="$pair"
                fi
            done
            decoded=$(hex_to_raw "$filtered")
        fi
        decoded=$(trim "$decoded")
        if [ -n "$decoded" ] && [[ ! "$decoded" =~ ^[0-9]+$ ]]; then
            last="$decoded"
        fi
    done

    if [ -n "$last" ]; then
        printf '%s\n' "$last"
    else
        echo "<anon>"
    fi
}

# ===================== Main =====================
if [ $# -ne 1 ]; then
    echo "Usage: $0 <n>"
    echo " Shows miner name (from coinbase) for each of the last n blocks by height"
    exit 1
fi

N="$1"
if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -lt 1 ]; then
    echo "Error: n must be a positive integer"
    exit 1
fi

echo "Using RPC: $RPC_URL"

BEST_RESP=$(rpc_call getbestblockhash)
BEST_HASH=$(echo "$BEST_RESP" | jq -r '.result // empty')
if [ -z "$BEST_HASH" ]; then
    echo
    echo "=== RPC Error (getbestblockhash) ==="
    echo "$BEST_RESP" | jq .
    exit 1
fi

CUR_RESP=$(rpc_call getblock "$BEST_HASH" 1)
CURRENT_HEIGHT=$(echo "$CUR_RESP" | jq -r '.result.height // empty')
if [ -z "$CURRENT_HEIGHT" ]; then
    echo
    echo "=== RPC Error (getblock for height) ==="
    echo "$CUR_RESP" | jq .
    exit 1
fi

echo "Current height: $CURRENT_HEIGHT"

START_HEIGHT=$((CURRENT_HEIGHT - N + 1))
if [ "$START_HEIGHT" -lt 0 ]; then
    START_HEIGHT=0
    echo "Note: Adjusted start height to 0 (only $((CURRENT_HEIGHT + 1)) blocks available)"
fi

echo "Miners for blocks $START_HEIGHT to $CURRENT_HEIGHT"
echo
printf "%-12s %s\n" "Height" "Miner"
printf "%-12s %s\n" "------" "-----"

for (( h=CURRENT_HEIGHT; h>=START_HEIGHT; h-- )); do
    HASH_RESP=$(rpc_call getblockhash "$h")
    BLOCK_HASH=$(echo "$HASH_RESP" | jq -r '.result // empty')
    if [ -z "$BLOCK_HASH" ]; then
        err=$(echo "$HASH_RESP" | jq -c '.error // empty')
        printf "%-12s %s\n" "$h" "<hash error: ${err:-unknown}>"
        continue
    fi

    BLOCK_RESP=$(rpc_call getblock "$BLOCK_HASH" 2)
    ERR=$(echo "$BLOCK_RESP" | jq -r '.error // empty')
    if [ -n "$ERR" ]; then
        printf "%-12s %s\n" "$h" "<rpc error: $(echo "$BLOCK_RESP" | jq -c .error)>"
        continue
    fi

    COINBASE_HEX=$(echo "$BLOCK_RESP" | jq -r '.result.tx[0].vin[0].coinbase // empty')
    MINER=$(extract_miner "$COINBASE_HEX")
    case "$MINER" in
        "<anon>")  printf "%-12s %b\n" "$h" "$ANON_LABEL" ;;
        "<zebra>") printf "%-12s %b\n" "$h" "$ZEBRA_LABEL" ;;
        *)         printf "%-12s %s\n" "$h" "$MINER" ;;
    esac
done
