#!/bin/bash
# redis status, runs the script every 3 min. and parse
# the cache file on echo following run.
# the redis must listen on 127.0.0.1 or 0.0.0.0

set -e
[[ "$DEBUG" ]] && set -x

PORT=$1
METRIC=$2

if [[ -z "$1" ]]; then
    echo "Must set redis port"
    exit 1
fi

if [[ -z "$2" ]]; then
    echo "Must set metrict item"
    exit 1
fi

CACHETTL="180"  # parse cachefile when update time less than 3 min
CACHEFILE="/tmp/redis_status.txt_$PORT"

redis_info() {
   (echo -en "INFO\r\n"; sleep 1) | nc -w1 127.0.0.1 $1 >> $2 || exit 1
}

if [ -s "$CACHEFILE" ]; then
   TIMECACHE=`stat -c %Y "$CACHEFILE"`
   TIMENOW=`date +%s`
   if [[ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]]; then
       rm -f $CACHEFILE
       redis_info $PORT $CACHEFILE
   fi
else
   redis_info $PORT $CACHEFILE
fi

case $METRIC in
    'uptime_in_seconds')
        cat $CACHEFILE | grep "uptime_in_seconds:" | cut -d':' -f2
        ;;
    'used_memory')
        cat $CACHEFILE | grep "used_memory:" | cut -d':' -f2
        ;;
    'used_memory_peak')
        cat $CACHEFILE | grep "used_memory_peak:" | cut -d':' -f2
        ;;
    'used_memory_rss')
        cat $CACHEFILE | grep "used_memory_rss:" | cut -d':' -f2
        ;;
    'mem_fragmentation_ratio')
        cat $CACHEFILE | grep "mem_fragmentation_ratio:" | cut -d':' -f2
        ;;
    'role')
        cat $CACHEFILE | grep "role:" | cut -d':' -f2
        ;;
    'blocked_clients')
        cat $CACHEFILE | grep "blocked_clients:" | cut -d':' -f2
        ;;
    'connected_clients')
        cat $CACHEFILE | grep "connected_clients:" | cut -d':' -f2
        ;;
    'client_longest_output_list')
        cat $CACHEFILE | grep "client_longest_output_list:" | cut -d':' -f2
        ;;
    'client_biggest_input_buf')
        cat $CACHEFILE | grep "client_biggest_input_buf:" | cut -d':' -f2
        ;;
    'lru_clock')
        cat $CACHEFILE | grep "lru_clock:" | cut -d':' -f2
        ;;
    'total_connections_received')
        cat $CACHEFILE | grep "total_connections_received:" | cut -d':' -f2
        ;;
    'total_commands_processed')
        cat $CACHEFILE | grep "total_commands_processed:" | cut -d':' -f2
        ;;
    'instantaneous_ops_per_sec')
        cat $CACHEFILE | grep "instantaneous_ops_per_sec:" | cut -d':' -f2
        ;;
    'rejected_connections')
        cat $CACHEFILE | grep "rejected_connections:" | cut -d':' -f2
        ;;
    'expired_keys')
        cat $CACHEFILE | grep "expired_keys:" | cut -d':' -f2
        ;;
    'evicted_keys')
        cat $CACHEFILE | grep "evicted_keys:" | cut -d':' -f2
        ;;
    'keyspace_hits')
        cat $CACHEFILE | grep "keyspace_hits:" | cut -d':' -f2
        ;;
    'keyspace_misses')
        cat $CACHEFILE | grep "keyspace_misses:" | cut -d':' -f2
        ;;
    'pubsub_channels')
        cat $CACHEFILE | grep "pubsub_channels:" | cut -d':' -f2
        ;;
    'pubsub_patterns')
        cat $CACHEFILE | grep "pubsub_patterns:" | cut -d':' -f2
        ;;
    'connected_slaves')
        cat $CACHEFILE | grep "connected_slaves:" | cut -d':' -f2
        ;;
    'used_cpu_sys')
        cat $CACHEFILE | grep "used_cpu_sys:" | cut -d':' -f2
        ;;
    'used_cpu_user')
        cat $CACHEFILE | grep "used_cpu_user:" | cut -d':' -f2
        ;;
    'used_cpu_sys_children')
        cat $CACHEFILE | grep "used_cpu_sys_children:" | cut -d':' -f2
        ;;
    'used_cpu_user_children')
        cat $CACHEFILE | grep "used_cpu_user_children:" | cut -d':' -f2
        ;;
    'loading')
        cat $CACHEFILE | grep "loading:" | cut -d':' -f2
        ;;
    'rdb_changes_since_last_save')
        cat $CACHEFILE | grep "rdb_changes_since_last_save:" | cut -d':' -f2
        ;;
    'last_save_time')
        cat $CACHEFILE | grep "last_save_time" | cut -d':' -f2
        ;;
    'rdb_bgsave_in_progress')
        cat $CACHEFILE | grep "rdb_bgsave_in_progress:" | cut -d':' -f2
        ;;
    'aof_rewrite_in_progress')
        cat $CACHEFILE | grep "aof_rewrite_in_progress:" | cut -d':' -f2
        ;;
    'aof_enabled')
        cat $CACHEFILE | grep "aof_enabled:" | cut -d':' -f2
        ;;
    'aof_rewrite_scheduled')
        cat $CACHEFILE | grep "aof_rewrite_scheduled:" | cut -d':' -f2
        ;;
    'slave_ok')
        ROLE=$(cat $CACHEFILE | grep "role" | cut -d':' -f2 | sed -e 's/\r//g')
        SUP=$(cat $CACHEFILE | grep "master_link_status" | cut -d':' -f2 | sed -e 's/\r//g')

        if [[ "$ROLE"x == "masterx" ]]; then
            echo 2
        elif [[ $ROLE == "slave" ]]; then
            if [[ "$SUP"x == "upx" ]]; then
                 echo "1"
            else 
                 echo "0"
            fi
        else
            echo "Unknown role"
            exit 1
        fi
        ;;
    *)
        echo "Not selected metric"
        exit 0
        ;;
esac
