#!/bin/bash
# sysbench テーブル準備スクリプト

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLES=${TABLES:-1}
TABLE_SIZE=${TABLE_SIZE:-100000}

echo "Preparing sysbench test data..."
echo "Host: $HOST, Database: $DATABASE, Tables: $TABLES, Size: $TABLE_SIZE"

sysbench oltp_read_write \
  --mysql-host=$HOST \
  --mysql-port=$PORT \
  --mysql-user=$USER \
  --mysql-password=$PASSWORD \
  --mysql-db=$DATABASE \
  --tables=$TABLES \
  --table_size=$TABLE_SIZE \
  prepare

echo "Preparation completed!"