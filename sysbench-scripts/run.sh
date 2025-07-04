#!/bin/bash
# sysbench 実行スクリプト

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLES=${TABLES:-10}
THREADS=${THREADS:-4}
TIME=${TIME:-600} # 10 minutes

echo "Running sysbench benchmark..."
echo "Host: $HOST, Database: $DATABASE, Tables: $TABLES, Threads: $THREADS, Time: ${TIME}s"

sysbench oltp_read_write \
  --mysql-host=$HOST \
  --mysql-port=$PORT \
  --mysql-user=$USER \
  --mysql-password=$PASSWORD \
  --mysql-db=$DATABASE \
  --tables=$TABLES \
  --threads=$THREADS \
  --time=$TIME \
  --report-interval=10 \
  run

echo "Benchmark completed!"