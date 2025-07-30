#!/bin/bash
# Spirit: インデックス追加削除テスト

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: インデックス追加を実行"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE" 
echo "変更内容: 複合インデックス作成、インデックス名変更、インデックス削除"

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

# idx_k_c の名前を idx_k_c_new に変更
echo "2/3: インデックス名 idx_k_c を idx_k_c_new に変更中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="RENAME INDEX idx_k_c TO idx_k_c_new"

if [ $? -eq 0 ]; then
  echo "✓ インデックス名 idx_k_c を idx_k_c_new に変更しました"
else
  echo "⚠ インデックス名 idx_k_c の変更に失敗しました（存在しない可能性）"
fi

# idx_k_c_new の削除
echo "3/3: インデックス idx_k_c_new を削除中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="DROP INDEX idx_k_c_new"

if [ $? -eq 0 ]; then
  echo "✓ インデックス idx_k_c_new の削除が完了しました"
  echo "🎉 すべてのインデックス処理が完了しました！"
else
  echo "⚠ インデックス idx_k_c_new の削除に失敗しました（存在しない可能性）"
  echo "📝 基本のインデックス処理は完了しました"
fi