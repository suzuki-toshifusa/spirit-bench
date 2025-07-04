#!/bin/bash
# Spirit実行例スクリプト

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-test_table}

echo "Spirit Schema Change Example"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE"

# 実行例
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD COLUMN status VARCHAR(50) DEFAULT 'active'"
