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
echo "1/1: テーブル最適化中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="FORCE" \
  # --statement="OPTIMIZE TABLE $TABLE"

if [ $? -eq 0 ]; then
  echo "✓ テーブル最適化が完了しました"
else
  echo "✗ テーブル最適化に失敗しました"
  exit 1
fi

#  主キーの削除
echo "2/2: テーブル名の変更"
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
