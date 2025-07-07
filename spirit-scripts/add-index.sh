#!/bin/bash
# Spirit: インデックス追加スクリプト（sysbenchテーブル用）

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: インデックス追加を実行"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE" 
echo "変更内容: 複合インデックス、ステータスインデックス、作成日インデックス"

# 複合インデックス (k, c) の追加
echo "1/3: 複合インデックス idx_k_c を追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD INDEX idx_k_c (k, c(10))"

if [ $? -eq 0 ]; then
  echo "✓ 複合インデックス idx_k_c の追加が完了しました"
else
  echo "✗ 複合インデックス idx_k_c の追加に失敗しました"
  exit 1
fi

# statusカラムのインデックス追加（カラムが存在する場合）
echo "2/3: ステータスインデックス idx_status を追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD INDEX idx_status (status)"

if [ $? -eq 0 ]; then
  echo "✓ ステータスインデックス idx_status の追加が完了しました"
else
  echo "⚠ ステータスインデックス idx_status の追加をスキップ（statusカラムが存在しない可能性）"
fi

# created_atカラムのインデックス追加（カラムが存在する場合）
echo "3/3: 作成日インデックス idx_created_at を追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="ADD INDEX idx_created_at (created_at)"

if [ $? -eq 0 ]; then
  echo "✓ 作成日インデックス idx_created_at の追加が完了しました"
  echo "🎉 すべてのインデックス追加が完了しました！"
else
  echo "⚠ 作成日インデックス idx_created_at の追加をスキップ（created_atカラムが存在しない可能性）"
  echo "📝 基本インデックスの追加は完了しました"
fi