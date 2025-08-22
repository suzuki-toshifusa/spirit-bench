#!/bin/bash
# Spirit: インデックス追加スクリプト（defer-cutover使用版）

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: テ-ブル操作"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE" 
echo "変更内容: テーブル最適化、テーブル名の変更"

# テーブル最適化
echo "1/3: テーブル最適化中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --statement="OPTIMIZE TABLE $TABLE"

if [ $? -eq 0 ]; then
  echo "✓ テーブル最適化（OPTIMIZE TABLE）が完了しました"
else
  echo "✗ テーブル最適化（OPTIMIZE TABLE）に失敗しました"
fi

# テーブル最適化
echo "2/3: テーブル最適化中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="FORCE"

if [ $? -eq 0 ]; then
  echo "✓ テーブル最適化（FORCE）が完了しました"
else
  echo "✗ テーブル最適化（FORCE）に失敗しました"
fi

#  テーブル名の変更
echo "2/3: テーブル名の変更"
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="RENAME TO ${TABLE}_new"

if [ $? -eq 0 ]; then
  echo "✓ テーブル名の変更が完了しました"
else
  echo "✗ テーブル名の変更に失敗しました"
  echo "📝 テーブル処理は完了しました"
fi
