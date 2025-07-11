#!/bin/bash
# sysbench クリーンアップスクリプト

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLES=${TABLES:-1}

echo "Cleanup sysbench test data..."
echo "Host: $HOST, Database: $DATABASE, Tables: $TABLES"

sysbench oltp_read_write \
  --mysql-host=$HOST \
  --mysql-port=$PORT \
  --mysql-user=$USER \
  --mysql-password=$PASSWORD \
  --mysql-db=$DATABASE \
  --tables=$TABLES \
  cleanup

echo "Benchmark cleanup done!"