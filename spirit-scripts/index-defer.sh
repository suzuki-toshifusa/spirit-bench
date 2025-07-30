#!/bin/bash
# Spirit: インデックス追加スクリプト（defer-cutover使用版）

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: インデックス追加を実行（defer-cutover使用）"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE" 
echo "変更内容: 複合インデックスを defer-cutover で追加"

# 複合インデックス (k, c) の追加
echo "1/1: 複合インデックス idx_k_c を追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD INDEX idx_k_c (k, c(10))" \
  --defer-cutover

if [ $? -eq 0 ]; then
  echo "✓ 複合インデックス idx_k_c の追加が完了しました"
else
  echo "✗ 複合インデックス idx_k_c の追加に失敗しました"
  exit 1
fi
