#!/bin/bash
# Spirit: カラム追加スクリプト（sysbenchテーブル用）

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: カラム追加を実行"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE"
echo "変更内容: created_at TIMESTAMP, status VARCHAR(20), updated_at TIMESTAMP"

# created_atカラムの追加
echo "1/3: created_atカラムを追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" \
  --execute

if [ $? -eq 0 ]; then
  echo "✓ created_atカラムの追加が完了しました"
else
  echo "✗ created_atカラムの追加に失敗しました"
  exit 1
fi

# statusカラムの追加
echo "2/3: statusカラムを追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD COLUMN status VARCHAR(20) DEFAULT 'active'" \
  --execute

if [ $? -eq 0 ]; then
  echo "✓ statusカラムの追加が完了しました"
else
  echo "✗ statusカラムの追加に失敗しました"
  exit 1
fi

# updated_atカラムの追加
echo "3/3: updated_atカラムを追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" \
  --execute

if [ $? -eq 0 ]; then
  echo "✓ updated_atカラムの追加が完了しました"
  echo "🎉 すべてのカラム追加が完了しました！"
else
  echo "✗ updated_atカラムの追加に失敗しました"
  exit 1
fi